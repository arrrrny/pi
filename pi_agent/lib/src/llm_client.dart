/// LLM client for OpenAI-compatible streaming completions.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'json_parse.dart';
import 'types.dart';
import 'sse_parser.dart';

/// Default base URL for the official OpenAI API.
const String defaultOpenAiBaseUrl = 'https://api.openai.com/v1';

/// Streams a completion from an OpenAI-compatible `/chat/completions` endpoint.
///
/// The model's [Model.baseUrl] selects the endpoint (defaulting to OpenAI),
/// so any server implementing the OpenAI chat-completions API works. Emits
/// [MessageUpdate] as content streams in and a final [MessageEnd] carrying the
/// assembled assistant message (text, tool calls, stop reason, usage).
Stream<AgentEvent> streamLLM({
  required AgentContext context,
  required AgentLoopConfig config,
  required String apiKey,
  required Completer<void>? abortSignal,
}) async* {
  final (url, headers, body) = await _buildRequest(context, config, apiKey);

  final client = http.Client();
  StreamSubscription<void>? abortSub;
  var aborted = false;
  try {
    if (abortSignal != null) {
      abortSub = abortSignal.future.asStream().listen((_) {
        aborted = true;
        client.close();
      });
    }

    final request = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = body;

    final response = await client.send(request);

    if (response.statusCode != 200) {
      // A provider failure is a diagnostic, not model-authored content: it goes
      // into `errorMessage` and must never be rendered as assistant text. The
      // body is clamped because it is persisted into JSONL for the message: a
      // proxy answering with a large HTML error page would otherwise write it
      // in full on every reload (upstream `error-body.ts:110`).
      final errorBody = await response.stream.bytesToString();
      yield _errorEnd(
          '${response.statusCode} - ${_clampErrorBody(errorBody)}',
          StopReason.error);
      return;
    }

    final content = <dynamic>[];
    String? messageId;
    StopReason? stopReason;
    Usage? usage;
    final toolCallBuffers = <int, _ToolCallBuffer>{};
    String? streamError;

    await for (final event in parseSSE(response.stream)) {
      if (aborted || (abortSignal?.isCompleted ?? false)) break;

      final data = event['data'];
      if (data == null || data.isEmpty || data == '[DONE]') continue;

      // A malformed frame is a broken stream, not content to skip: upstream
      // lets the parse error terminate the response
      // (openai-completions.ts:696).
      final changed = _applyChunk(
        jsonDecode(data) as Map<String, dynamic>,
        content: content,
        toolCallBuffers: toolCallBuffers,
        onMessageId: (id) => messageId = id,
        onStopReason: (sr) => stopReason = sr,
        onUsage: (u) => usage = u,
        onErrorMessage: (message) => streamError = message,
      );

      // Surface a message update only when the content actually changed, so
      // trailing keep-alive / usage-only chunks don't emit duplicate updates.
      if (changed) {
        yield MessageUpdate(
          message: AssistantMessage(
            id: messageId,
            content: List<dynamic>.from(content),
          ),
        );
      }
    }

    if (aborted || (abortSignal?.isCompleted ?? false)) {
      yield _errorEnd('Request aborted', StopReason.aborted);
      return;
    }

    // A reason the provider sent but the vocabulary does not know is the more
    // precise diagnostic: report it rather than the generic "no finish reason".
    if (streamError != null) {
      yield _errorEnd(streamError!, StopReason.error);
      return;
    }

    // A stream that ends without a finish reason never reported how it ended,
    // so it cannot be trusted as a clean end: upstream throws instead of
    // reporting one (openai-completions.ts:688-692).
    if (stopReason == null) {
      yield _errorEnd('Stream ended without a finish reason', StopReason.error);
      return;
    }

    final finalContent = <dynamic>[...content];
    for (final tcb in toolCallBuffers.values) {
      if (tcb.name != null && tcb.name!.isNotEmpty) {
        // One full parse of the complete buffer: a partial streaming snapshot
        // never becomes the final arguments, and a malformed one is reported
        // on the block instead of being silently replaced by {}.
        final parsed = parseToolCallArguments(tcb.argumentsBuffer);
        finalContent.add(
          ToolCallBlock(
            id: tcb.id,
            name: tcb.name!,
            arguments: parsed.arguments,
            argumentsError: parsed.argumentsError,
          ),
        );
      }
    }

    yield MessageEnd(
      message: AssistantMessage(
        id: messageId,
        content: finalContent,
        stopReason: stopReason,
        usage: usage,
      ),
    );
  } on http.RequestAbortedException {
    // A cancelled request surfaces through http as this exception; the caller
    // still gets a modelled abort outcome rather than a silent nothing.
    yield _errorEnd('Request aborted', StopReason.aborted);
  } catch (e) {
    // `client.close()` from an abort can also land here as a connection
    // failure, so the abort flag decides the outcome, as upstream does
    // (openai-completions.ts:697).
    yield aborted
        ? _errorEnd('Request aborted', StopReason.aborted)
        : _errorEnd('$e', StopReason.error);
  } finally {
    await abortSub?.cancel();
    client.close();
  }
}

/// Builds the terminal [MessageEnd] for a failed request.
///
/// The diagnostic lives in [AssistantMessage.errorMessage] and the content
/// stays empty, so a consumer can never mistake a provider failure for
/// model-authored text.
MessageEnd _errorEnd(String message, StopReason reason) => MessageEnd(
      message: AssistantMessage(
        content: const [],
        stopReason: reason,
        errorMessage: message,
      ),
    );

/// Maximum provider error text kept in a diagnostic, matching upstream's
/// `MAX_PROVIDER_ERROR_BODY_CHARS` (`error-body.ts:18`).
const int _maxErrorBodyChars = 4000;

/// Caps a provider error body, matching upstream's `truncateErrorText`
/// (`error-body.ts:166`). The diagnostic is persisted into JSONL for the
/// message, so a proxy answering with an HTML error page must not write it in
/// full; a real API error is short and passes through unchanged.
String _clampErrorBody(String text) {
  if (text.length <= _maxErrorBodyChars) return text;
  final kept = text.substring(0, _maxErrorBodyChars);
  return '$kept... [truncated ${text.length - _maxErrorBodyChars} chars]';
}

/// Builds the POST target, headers, and JSON body for one completion request.
Future<(Uri, Map<String, String>, String)> _buildRequest(
  AgentContext context,
  AgentLoopConfig config,
  String apiKey,
) async {
  final base =
      (config.model.baseUrl != null && config.model.baseUrl!.isNotEmpty)
          ? config.model.baseUrl!
          : defaultOpenAiBaseUrl;
  final normalized =
      base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  final url = Uri.parse('$normalized/chat/completions');

  final headers = <String, String>{
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
    'Accept': 'text/event-stream',
    ...?config.extraHeaders,
  };

  final converted = await config.convertToLlm(context.messages);
  final messages = <Map<String, dynamic>>[
    if (context.systemPrompt.isNotEmpty)
      {'role': 'system', 'content': context.systemPrompt},
    ...converted,
  ];

  final tools = context.tools;
  final body = jsonEncode({
    'model': config.model.modelId,
    'messages': messages,
    'stream': true,
    'stream_options': {'include_usage': true},
    if (config.maxTokens != null) 'max_tokens': config.maxTokens,
    if (config.temperature != null) 'temperature': config.temperature,
    if (config.topP != null) 'top_p': config.topP,
    if (tools != null && tools.isNotEmpty)
      'tools': tools.map((t) => t.toApiFormat()).toList(),
  });

  return (url, headers, body);
}

/// Applies one SSE chunk to the accumulating assistant content.
///
/// Returns whether the assistant content changed (text appended or a tool-call
/// argument accumulated), so the caller can emit a message update only then.
bool _applyChunk(
  Map<String, dynamic> json, {
  required List<dynamic> content,
  required Map<int, _ToolCallBuffer> toolCallBuffers,
  required void Function(String?) onMessageId,
  required void Function(StopReason) onStopReason,
  required void Function(Usage) onUsage,
  required void Function(String) onErrorMessage,
}) {
  var changed = false;
  final id = json['id'];
  if (id is String && id.isNotEmpty) onMessageId(id);

  final choices = json['choices'];
  if (choices is List && choices.isNotEmpty) {
    final choice = choices.first;
    if (choice is Map<String, dynamic>) {
      final delta = choice['delta'];
      if (delta is Map<String, dynamic>) {
        final textDelta = delta['content'];
        if (textDelta is String && textDelta.isNotEmpty) {
          content.add(TextBlock(textDelta));
          changed = true;
        }
        final toolCalls = delta['tool_calls'];
        if (toolCalls is List) {
          for (final tc in toolCalls) {
            if (tc is Map<String, dynamic>) {
              _accumulateToolCall(tc, toolCallBuffers);
              changed = true;
            }
          }
        }
      }
      final finishReason = choice['finish_reason'];
      if (finishReason is String) {
        final mapped = _parseStopReason(finishReason);
        if (mapped == null) {
          // An unrecognized reason is a provider failure, not a clean end: it
          // carries the raw value as its diagnostic so the caller can report
          // what the provider actually said (openai-completions.ts:1583-1590).
          onStopReason(StopReason.error);
          onErrorMessage('Provider finish_reason: $finishReason');
        } else {
          onStopReason(mapped);
        }
      }
    }
  }

  final usageJson = json['usage'];
  if (usageJson is Map<String, dynamic>) {
    onUsage(
      Usage(
        inputTokens: (usageJson['prompt_tokens'] as num?)?.toInt() ?? 0,
        outputTokens: (usageJson['completion_tokens'] as num?)?.toInt() ?? 0,
      ),
    );
  }
  return changed;
}

void _accumulateToolCall(
  Map<String, dynamic> tc,
  Map<int, _ToolCallBuffer> buffers,
) {
  final index = (tc['index'] as num?)?.toInt() ?? buffers.length;
  final buffer = buffers.putIfAbsent(index, () => _ToolCallBuffer());

  final id = tc['id'];
  if (id is String && id.isNotEmpty) buffer.id = id;

  final fn = tc['function'];
  if (fn is Map<String, dynamic>) {
    final name = fn['name'];
    if (name is String && name.isNotEmpty) buffer.name = name;
    final args = fn['arguments'];
    if (args is String) buffer.argumentsBuffer += args;
  }
}

/// Maps an OpenAI `finish_reason` to a stop reason, or null when the value is
/// not part of the vocabulary — an unknown reason is a provider failure, never
/// a clean end (upstream `openai-completions.ts:1583-1590`).
StopReason? _parseStopReason(String reason) => switch (reason) {
      'length' || 'max_tokens' => StopReason.maxTokens,
      'tool_calls' || 'function_call' => StopReason.toolUse,
      'content_filter' => StopReason.refused,
      'stop' || 'stop_sequence' || 'end_turn' => StopReason.endTurn,
      _ => null,
    };

class _ToolCallBuffer {
  String id = '';
  String? name;
  String argumentsBuffer = '';

  @override
  String toString() => 'id: $id, name: $name, args: $argumentsBuffer';
}
