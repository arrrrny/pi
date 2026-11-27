/// Proxy stream adapter.
///
/// Dart port of `packages/agent/src/proxy.ts`: a [streamProxy] function for
/// apps that route LLM calls through a server. The server manages auth and
/// proxies requests to LLM providers, stripping the `partial` field from delta
/// events to reduce bandwidth; this adapter reconstructs the partial assistant
/// message client-side and emits the same [AgentEvent] stream shape as
/// [streamLLM] (`MessageUpdate` as content streams in, a terminal
/// [MessageEnd]).
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'sse_parser.dart';
import 'types.dart';

/// Options for [streamProxy].
///
/// Mirrors the serializable subset of upstream `ProxyStreamOptions`
/// (`packages/agent/src/proxy.ts`): the proxy request body carries these
/// alongside the model and context, plus the auth token and proxy URL that
/// the direct provider path does not need.
class ProxyStreamOptions {
  /// Auth token for the proxy server (sent as a Bearer credential).
  final String authToken;

  /// Proxy server URL (e.g. `https://genai.example.com`).
  final String proxyUrl;

  /// Sampling temperature.
  final double? temperature;

  /// Maximum tokens to generate.
  final int? maxTokens;

  /// Session identifier for continuation.
  final String? sessionId;

  /// Extra headers to send with the proxy request.
  final Map<String, String>? headers;

  /// Request metadata forwarded to the proxy.
  final Map<String, dynamic>? metadata;

  /// Creates proxy stream options.
  const ProxyStreamOptions({
    required this.authToken,
    required this.proxyUrl,
    this.temperature,
    this.maxTokens,
    this.sessionId,
    this.headers,
    this.metadata,
  });

  /// The serializable option fields the proxy request body carries.
  Map<String, dynamic> toBody() => {
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'maxTokens': maxTokens,
        if (sessionId != null) 'sessionId': sessionId,
        if (headers != null) 'headers': headers,
        if (metadata != null) 'metadata': metadata,
      };
}

/// Streams a completion through a proxy server instead of calling an LLM
/// provider directly.
///
/// The server strips the `partial` field from delta events; this reconstructs
/// the partial [AssistantMessage] from the proxy event stream and emits
/// [MessageUpdate] as content changes and a terminal [MessageEnd], exactly like
/// [streamLLM]. A clean EOF without a `done`/`error` event, a non-200 response,
/// and an abort all surface as an error/aborted terminal message rather than a
/// silent end (proxy.ts:223-234).
Stream<AgentEvent> streamProxy({
  required AgentContext context,
  required AgentLoopConfig config,
  required ProxyStreamOptions options,
  Completer<void>? abortSignal,
}) async* {
  final client = http.Client();
  StreamSubscription<void>? abortSub;
  var aborted = false;
  if (abortSignal != null) {
    abortSub = abortSignal.future.asStream().listen((_) {
      aborted = true;
      client.close();
    });
  }

  try {
    final request = http.Request(
      'POST',
      Uri.parse('${options.proxyUrl}/api/stream'),
    )
      ..headers.addAll({
        'Authorization': 'Bearer ${options.authToken}',
        'Content-Type': 'application/json',
        ...?options.headers,
      })
      ..body = jsonEncode({
        'model': {
          'provider': config.model.provider,
          'id': config.model.modelId,
        },
        'context': await config.convertToLlm(context.messages),
        'options': options.toBody(),
      });

    final response = await client.send(request);

    if (response.statusCode != 200) {
      var message =
          'Proxy error: ${response.statusCode} ${response.reasonPhrase}';
      try {
        final errorData = jsonDecode(await response.stream.bytesToString())
            as Map<String, dynamic>;
        final error = errorData['error'];
        if (error is String && error.isNotEmpty) {
          message = 'Proxy error: $error';
        }
      } catch (_) {
        // Couldn't parse the error response; keep the status-line message.
      }
      yield _errorEnd(message, StopReason.error);
      return;
    }

    final partial = _ProxyPartial(config.model);
    final toolArguments = <int, StringBuffer>{};
    var sawTerminalEvent = false;

    await for (final event in parseSSE(response.stream)) {
      if (aborted || (abortSignal?.isCompleted ?? false)) break;

      final data = event['data'];
      if (data == null || data.isEmpty) continue;

      final decoded = jsonDecode(data) as Map<String, dynamic>;
      final change = _processProxyEvent(decoded, partial, toolArguments);
      if (change == true) {
        yield MessageUpdate(message: partial.snapshot());
      }
      final type = decoded['type'];
      if (type == 'done' || type == 'error') sawTerminalEvent = true;
    }

    if (aborted || (abortSignal?.isCompleted ?? false)) {
      yield _errorEnd('Request aborted', StopReason.aborted);
      return;
    }

    if (!sawTerminalEvent) {
      // A clean EOF without a terminal event means the server dropped the
      // response mid-stream (proxy.ts:223-234).
      yield _errorEnd(
        'Connection closed by proxy server before the response completed',
        StopReason.error,
      );
      return;
    }

    yield MessageEnd(message: partial.snapshot());
  } on http.RequestAbortedException {
    yield _errorEnd('Request aborted', StopReason.aborted);
  } catch (e) {
    yield aborted
        ? _errorEnd('Request aborted', StopReason.aborted)
        : _errorEnd('$e', StopReason.error);
  } finally {
    await abortSub?.cancel();
    client.close();
  }
}

/// Mutable accumulator for the partial assistant message rebuilt from proxy
/// events. Content blocks are kept off a growable list indexed by the proxy's
/// `contentIndex`, matching upstream's `partial.content[contentIndex]`.
class _ProxyPartial {
  _ProxyPartial(this.model);

  final Model model;
  final List<dynamic> _content = [];
  StopReason? _stopReason;
  String? _errorMessage;
  Usage? _usage;

  void setContent(int index, dynamic block) {
    while (_content.length <= index) {
      _content.add(null);
    }
    _content[index] = block;
  }

  dynamic contentAt(int index) =>
      index < _content.length ? _content[index] : null;

  AssistantMessage snapshot() => AssistantMessage(
        content: List<dynamic>.from(_content.whereType<dynamic>().toList()),
        stopReason: _stopReason,
        errorMessage: _errorMessage,
        usage: _usage,
      );

  set stopReason(StopReason? value) => _stopReason = value;
  set errorMessage(String? value) => _errorMessage = value;
  set usage(Usage? value) => _usage = value;
}

/// Processes one proxy event, mutating [partial]. Returns whether the partial
/// content changed (so the caller emits a `MessageUpdate`), or null for an
/// event that carries no content change (proxy.ts:261-397).
bool? _processProxyEvent(
  Map<String, dynamic> event,
  _ProxyPartial partial,
  Map<int, StringBuffer> toolArguments,
) {
  switch (event['type']) {
    case 'start':
      return false;
    case 'text_start':
      partial.setContent(event['contentIndex'] as int, TextBlock(''));
      return true;
    case 'text_delta':
      final content = partial.contentAt(event['contentIndex'] as int);
      if (content is TextBlock) {
        final delta = event['delta'] as String;
        partial.setContent(
            event['contentIndex'] as int, TextBlock(content.text + delta));
        return true;
      }
      throw StateError('Received text_delta for non-text content');
    case 'text_end':
      return false;
    case 'thinking_start':
      partial.setContent(event['contentIndex'] as int, ThinkingBlock(''));
      return true;
    case 'thinking_delta':
      final content = partial.contentAt(event['contentIndex'] as int);
      if (content is ThinkingBlock) {
        final delta = event['delta'] as String;
        partial.setContent(
            event['contentIndex'] as int, ThinkingBlock(content.text + delta));
        return true;
      }
      throw StateError('Received thinking_delta for non-thinking content');
    case 'thinking_end':
      return false;
    case 'toolcall_start':
      partial.setContent(
        event['contentIndex'] as int,
        ToolCallBlock(
          id: event['id'] as String,
          name: event['toolName'] as String,
          arguments: const {},
        ),
      );
      toolArguments[event['contentIndex'] as int] = StringBuffer();
      return true;
    case 'toolcall_delta':
      final args = toolArguments[event['contentIndex'] as int];
      if (args != null) {
        args.write(event['delta'] as String);
        return true;
      }
      throw StateError('Received toolcall_delta for non-toolCall content');
    case 'toolcall_end':
      final toolCall = event['toolCall'] as Map<String, dynamic>;
      partial.setContent(
        event['contentIndex'] as int,
        ToolCallBlock(
          id: toolCall['id'] as String,
          name: toolCall['name'] as String,
          arguments:
              (toolCall['arguments'] as Map<String, dynamic>?) ?? const {},
        ),
      );
      toolArguments.remove(event['contentIndex'] as int);
      return true;
    case 'done':
      partial.stopReason = _stopReasonFromWire(event['reason'] as String);
      partial.usage = _usageFromWire(event['usage'] as Map<String, dynamic>);
      return false;
    case 'error':
      partial.stopReason = _stopReasonFromWire(event['reason'] as String);
      partial.errorMessage = event['errorMessage'] as String?;
      partial.usage = _usageFromWire(event['usage'] as Map<String, dynamic>);
      return false;
    default:
      return null;
  }
}

StopReason _stopReasonFromWire(String reason) {
  switch (reason) {
    case 'stop':
      return StopReason.endTurn;
    case 'length':
      return StopReason.maxTokens;
    case 'toolUse':
      return StopReason.toolUse;
    case 'aborted':
      return StopReason.aborted;
    default:
      return StopReason.error;
  }
}

Usage _usageFromWire(Map<String, dynamic> usage) => Usage(
      inputTokens: (usage['input'] as num?)?.toInt() ?? 0,
      outputTokens: (usage['output'] as num?)?.toInt() ?? 0,
      cacheReadInputTokens: (usage['cacheRead'] as num?)?.toInt(),
      cacheCreationInputTokens: (usage['cacheWrite'] as num?)?.toInt(),
    );

MessageEnd _errorEnd(String message, StopReason reason) => MessageEnd(
      message: AssistantMessage(
        content: const [],
        stopReason: reason,
        errorMessage: message,
      ),
    );
