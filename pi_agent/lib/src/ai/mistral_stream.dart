// Mistral conversations streaming-event parsing.
//
// Port of the streaming surface of
// `packages/ai/src/api/mistral-conversations.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b`: the `consumeChatStream` loop
// over Mistral `CompletionChunk` payloads — response id capture, usage with
// the cached-prompt arithmetic, `finish_reason` mapping, text and thinking
// (both the plain string and the `thinking`/`text` item shapes) with block
// switching, empty-delta skipping (GLM sends empty deltas around thinking),
// and tool-call deltas merged by index/id key through
// `ToolCallArgumentsStream`. The HTTP transport, request building, and error
// formatting stay out of this slice.

import 'dart:convert';

import 'provider_events.dart';
import 'provider_stop_reason.dart';
import 'streaming_json.dart';

/// Open state of one Mistral tool call.
class _MistralToolCall {
  final int contentIndex;
  final ToolCallArgumentsStream arguments = ToolCallArgumentsStream();
  _MistralToolCall(this.contentIndex);
}

/// Parses Mistral conversation-stream chunks into canonical stream events.
///
/// Feed each decoded chunk payload (the `data:` JSON of one SSE event; the
/// `[DONE]` sentinel is filtered by the caller), then call [end] once the
/// stream closes. Throws [ProviderStreamException] on the failure shapes
/// upstream throws (an invalid event, an ending without a finish reason, an
/// error stop), so a caller's single catch produces the terminal `error`
/// outcome exactly like the upstream API's outer catch does.
class MistralStreamParser {
  /// The message.
  final ProviderMessageState message = ProviderMessageState();
  Object? _currentBlock; // ProviderTextBlock | ProviderThinkingBlock | null
  final Map<Object, _MistralToolCall> _toolCallsByKey =
      <Object, _MistralToolCall>{};
  bool _finished = false;

  /// Feed one decoded chunk; returns the canonical events it produced.
  List<ProviderStreamEvent> feedChunk(Object chunk) {
    final events = <ProviderStreamEvent>[];
    if (chunk is! Map<String, dynamic>) {
      throw ProviderStreamException('Invalid Mistral streaming event');
    }
    if (chunk['choices'] is! List) {
      throw ProviderStreamException('Invalid Mistral streaming event');
    }

    // Mistral's streamed CompletionChunk carries an id field. Keep the first
    // non-empty one, mirroring how OpenAI-style streaming exposes a stable
    // response identifier per stream.
    final id = chunk['id'];
    if (id is String &&
        id.isNotEmpty &&
        (message.responseId?.isEmpty ?? true)) {
      message.responseId = id;
    }

    final usage = chunk['usage'];
    if (usage is Map<String, dynamic>) {
      final promptTokens = _num(usage['prompt_tokens']);
      final cachedPromptTokens = _cachedPromptTokens(usage, promptTokens);
      message.usage
        ..input = (promptTokens - cachedPromptTokens).clamp(0, 1 << 62).toInt()
        ..output = _num(usage['completion_tokens'])
        ..cacheRead = cachedPromptTokens
        ..cacheWrite = 0
        ..totalTokens = _numOrZero(usage['total_tokens']) != 0
            ? _num(usage['total_tokens'])
            : message.usage.input +
                message.usage.output +
                message.usage.cacheRead +
                message.usage.cacheWrite;
    }

    final choices = chunk['choices'] as List;
    if (choices.isEmpty || choices.first is! Map<String, dynamic>) {
      return events;
    }
    final choice = choices.first as Map<String, dynamic>;

    final finishReason = choice['finish_reason'];
    if (finishReason is String && finishReason.isNotEmpty) {
      message.rawStopReason = finishReason;
      final mapped = mapMistralStopReason(finishReason);
      message.stopReason = mapped.stopReason;
      if (mapped.errorMessage != null) {
        message.errorMessage = mapped.errorMessage;
      }
    }

    final delta = choice['delta'];
    if (delta is! Map<String, dynamic>) return events;

    final content = delta['content'];
    if (content is String) {
      events.addAll(_applyTextDelta(content));
    } else if (content is List) {
      for (final item in content) {
        if (item is String) {
          events.addAll(_applyTextDelta(item));
          continue;
        }
        if (item is Map<String, dynamic>) {
          switch (item['type'] as String?) {
            case 'thinking':
              final parts = item['thinking'];
              final buffer = StringBuffer();
              if (parts is List) {
                for (final part in parts) {
                  final text =
                      part is Map<String, dynamic> ? part['text'] : null;
                  if (text is String && text.isNotEmpty) buffer.write(text);
                }
              }
              events.addAll(_applyThinkingDelta(buffer.toString()));
              continue;
            case 'text':
              final text = item['text'];
              if (text is String) events.addAll(_applyTextDelta(text));
              continue;
            default:
              continue;
          }
        }
      }
    }

    final toolCalls = delta['tool_calls'];
    if (toolCalls is List) {
      for (final toolCall in toolCalls) {
        if (toolCall is! Map<String, dynamic>) continue;
        events.addAll(_applyToolCallDelta(toolCall));
      }
    }
    return events;
  }

  /// Finish the stream: close the open block and every tool call, run the
  /// terminal checks, and emit the final `done`. The close events are
  /// appended to [sink] (when given) BEFORE the terminal checks, so a thrown
  /// failure still leaves them visible to the caller.
  List<ProviderStreamEvent> end({List<ProviderStreamEvent>? sink}) {
    if (_finished) return const <ProviderStreamEvent>[];
    _finished = true;
    final events = sink ?? <ProviderStreamEvent>[];
    events.addAll(_finishCurrentBlock());
    for (final open in _toolCallsByKey.values) {
      final block = message.content[open.contentIndex] as ProviderToolCall;
      final finished = open.arguments.finish();
      block.arguments = finished.arguments;
      block.argumentsError = finished.argumentsError;
      events.add(ToolcallEnd(open.contentIndex, block));
    }

    if (message.stopReason == 'pending') {
      throw ProviderStreamException(
          'Mistral stream ended without a finish reason');
    }
    if (message.stopReason == 'aborted' || message.stopReason == 'error') {
      throw ProviderStreamException(
          message.errorMessage ?? 'An unknown error occurred');
    }
    events.add(ProviderDone(message.stopReason));
    return events;
  }

  List<ProviderStreamEvent> _applyTextDelta(String raw) {
    // GLM models on Mistral send empty content deltas around thinking and
    // tool calls. Opening a block for them splits thinking into multiple
    // blocks, which Mistral rejects on replay.
    if (raw.isEmpty) return const <ProviderStreamEvent>[];
    if (_currentBlock == null || _currentBlock is! ProviderTextBlock) {
      final events = List<ProviderStreamEvent>.of(_finishCurrentBlock());
      _currentBlock = ProviderTextBlock(raw);
      message.content.add(_currentBlock!);
      events.add(TextStart(message.content.length - 1));
      events.add(TextDelta(message.content.length - 1, raw));
      return events;
    }
    final block = _currentBlock as ProviderTextBlock;
    block.text += raw;
    return <ProviderStreamEvent>[TextDelta(message.content.length - 1, raw)];
  }

  List<ProviderStreamEvent> _applyThinkingDelta(String raw) {
    if (raw.isEmpty) return const <ProviderStreamEvent>[];
    if (_currentBlock == null || _currentBlock is! ProviderThinkingBlock) {
      final events = List<ProviderStreamEvent>.of(_finishCurrentBlock());
      _currentBlock = ProviderThinkingBlock(raw);
      message.content.add(_currentBlock!);
      events.add(ThinkingStart(message.content.length - 1));
      events.add(ThinkingDelta(message.content.length - 1, raw));
      return events;
    }
    final block = _currentBlock as ProviderThinkingBlock;
    block.thinking += raw;
    return <ProviderStreamEvent>[
      ThinkingDelta(message.content.length - 1, raw)
    ];
  }

  List<ProviderStreamEvent> _applyToolCallDelta(Map<String, dynamic> toolCall) {
    final events = <ProviderStreamEvent>[];
    if (_currentBlock != null) events.addAll(_finishCurrentBlock());

    final function = toolCall['function'];
    final functionMap =
        function is Map<String, dynamic> ? function : const <String, dynamic>{};
    final id = toolCall['id'];
    final callId = id is String && id.isNotEmpty && id != 'null'
        ? id
        : 'toolcall:${(toolCall['index'] as num?)?.toInt() ?? 0}';
    final rawIndex = toolCall['index'];
    final Object key = rawIndex is num ? rawIndex.toInt() : callId;
    var open = _toolCallsByKey[key];
    if (open == null) {
      message.content.add(ProviderToolCall(
        id: callId,
        name: functionMap['name'] as String? ?? '',
        arguments: <String, dynamic>{},
      ));
      open = _MistralToolCall(message.content.length - 1);
      _toolCallsByKey[key] = open;
      events.add(ToolcallStart(open.contentIndex));
    }

    final rawArguments = functionMap['arguments'];
    final argsDelta = rawArguments is String
        ? rawArguments
        : jsonEncode(rawArguments ?? <String, dynamic>{});
    final block = message.content[open.contentIndex] as ProviderToolCall;
    block.arguments = open.arguments.append(argsDelta);
    events.add(ToolcallDelta(open.contentIndex, argsDelta));
    return events;
  }

  List<ProviderStreamEvent> _finishCurrentBlock() {
    if (_currentBlock == null) return const <ProviderStreamEvent>[];
    final contentIndex = message.content.length - 1;
    final events = <ProviderStreamEvent>[];
    if (_currentBlock is ProviderTextBlock) {
      events.add(
          TextEnd(contentIndex, (_currentBlock as ProviderTextBlock).text));
    } else {
      events.add(ThinkingEnd(
          contentIndex, (_currentBlock as ProviderThinkingBlock).thinking));
    }
    _currentBlock = null;
    return events;
  }
}

/// The cached-prompt tokens of a Mistral usage payload
/// (`getMistralCachedPromptTokens` upstream): the first usable cached-token
/// field wins across the SDK's several shapes, clamped into [0, promptTokens].
int _cachedPromptTokens(Map<String, dynamic> usage, int promptTokens) {
  final detailsCamel = usage['promptTokensDetails'];
  final detailsSnake = usage['prompt_tokens_details'];
  final cached = _numOrNull(detailsCamel is Map<String, dynamic>
          ? detailsCamel['cachedTokens']
          : null) ??
      _numOrNull(detailsSnake is Map<String, dynamic>
          ? detailsSnake['cached_tokens']
          : null) ??
      _numOrNull(usage['numCachedTokens']) ??
      _numOrNull(usage['num_cached_tokens']) ??
      0;
  final finite = cached >= 0 ? cached : 0;
  return finite > promptTokens ? promptTokens : finite;
}

int _num(Object? value) => (value as num?)?.toInt() ?? 0;

int? _numOrNull(Object? value) => (value as num?)?.toInt();

int _numOrZero(Object? value) => _num(value);
