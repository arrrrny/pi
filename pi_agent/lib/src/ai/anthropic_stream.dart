// Anthropic Messages streaming-event parsing.
//
// Port of the streaming surface of `packages/ai/src/api/anthropic-messages.ts`
// at upstream `c11a73bfba1310dc4075ad836254ea87003f409b`: the SSE event loop
// of `stream()` (named events `message_start`, `content_block_start`,
// `content_block_delta`, `content_block_stop`, `message_delta`, `message_stop`,
// `error` and `ping`), including block bookkeeping per Anthropic index, usage
// capture and merging, stop-reason mapping, and the terminal checks the API's
// outer catch converts into the canonical `error` outcome.
//
// Not ported here (out of this slice): the HTTP transport, OAuth/federation
// client creation, request building, cache retention/threads, and strict-tool
// fallback bookkeeping — the parser models what a delivered SSE byte stream
// produces, which is the surface the differential scenarios script.

import 'dart:convert';

import 'provider_events.dart';
import 'provider_stop_reason.dart';
import 'sse_decoder.dart';
import 'streaming_json.dart';

/// The SSE event names the Anthropic message stream carries; anything else is
/// skipped without parsing (`ANTHROPIC_MESSAGE_EVENTS` upstream).
const Set<String> anthropicMessageEvents = {
  'message_start',
  'message_delta',
  'message_stop',
  'content_block_start',
  'content_block_delta',
  'content_block_stop',
};

/// Open state of one Anthropic content block index.
class _OpenBlock {
  final int contentIndex;

  /// The argument stream of a `tool_use` block; null for text/thinking.
  final ToolCallArgumentsStream? arguments;
  _OpenBlock(this.contentIndex, [this.arguments]);
}

/// Parses Anthropic Messages SSE events into canonical stream events.
///
/// Feed each [ServerSentEvent] the byte stream decodes, then call [end] once
/// the stream closes. Parsers throw [ProviderStreamException] on the failure
/// shapes upstream throws (an `error` SSE event, malformed event JSON, a
/// stream that ends before `message_stop` or without a stop reason), so a
/// caller's single catch produces the terminal `error` outcome exactly like
/// the upstream API's outer catch does.
class AnthropicStreamParser {
  /// The requested model id, so a differing response model is recorded like
  /// upstream records `event.message.model !== model.id`.
  final String requestedModelId;

  /// Creates a AnthropicStreamParser.
  AnthropicStreamParser({this.requestedModelId = ''});

  /// The message.
  final ProviderMessageState message = ProviderMessageState();
  final Map<int, _OpenBlock> _openBlocks = <int, _OpenBlock>{};
  bool _sawMessageStart = false;
  bool _sawMessageEnd = false;
  bool _finished = false;

  /// Feed one decoded SSE event; returns the canonical events it produced.
  List<ProviderStreamEvent> feed(ServerSentEvent sse) {
    if (sse.event == 'error') {
      // Upstream throws `new Error(sse.data)` — the outer catch folds the
      // message into `errorMessage` unchanged.
      throw ProviderStreamException(sse.data);
    }
    if (!anthropicMessageEvents.contains(sse.event ?? '')) {
      return const <ProviderStreamEvent>[];
    }

    final Object? event;
    try {
      event = jsonDecode(sse.data);
    } on FormatException catch (error) {
      throw ProviderStreamException(
        'Could not parse Anthropic SSE event ${sse.event}: ${error.message}; '
        'data=${sse.data}; raw=${sse.raw.join(r'\n')}',
      );
    }
    if (event is! Map<String, dynamic>) {
      throw ProviderStreamException(
        'Could not parse Anthropic SSE event ${sse.event}: not an object; '
        'data=${sse.data}; raw=${sse.raw.join(r'\n')}',
      );
    }

    switch (event['type'] as String?) {
      case 'message_start':
        _sawMessageStart = true;
        return _onMessageStart(event);
      case 'content_block_start':
        return _onContentBlockStart(event);
      case 'content_block_delta':
        return _onContentBlockDelta(event);
      case 'content_block_stop':
        return _onContentBlockStop(event);
      case 'message_delta':
        return _onMessageDelta(event);
      case 'message_stop':
        _sawMessageEnd = true;
        return const <ProviderStreamEvent>[];
      default:
        return const <ProviderStreamEvent>[];
    }
  }

  /// Finish the stream: the terminal checks and the final `done` event.
  List<ProviderStreamEvent> end() {
    if (_finished) return const <ProviderStreamEvent>[];
    _finished = true;
    if (_sawMessageStart && !_sawMessageEnd) {
      throw ProviderStreamException(
          'Anthropic stream ended before message_stop');
    }
    if (message.stopReason == 'pending') {
      throw ProviderStreamException(
          'Anthropic stream ended without a stop reason');
    }
    if (message.stopReason == 'aborted' || message.stopReason == 'error') {
      throw ProviderStreamException(
          message.errorMessage ?? 'An unknown error occurred');
    }
    return <ProviderStreamEvent>[ProviderDone(message.stopReason)];
  }

  List<ProviderStreamEvent> _onMessageStart(Map<String, dynamic> event) {
    final msg = event['message'];
    if (msg is! Map<String, dynamic>) return const <ProviderStreamEvent>[];
    final id = msg['id'];
    if (id is String && id.isNotEmpty) message.responseId = id;
    final responseModel = msg['model'];
    if (responseModel is String &&
        responseModel.isNotEmpty &&
        message.responseModel == null &&
        responseModel != requestedModelId) {
      message.responseModel = responseModel;
    }
    final usage = msg['usage'];
    if (usage is Map<String, dynamic>) {
      message.usage.input = _num(usage['input_tokens']);
      message.usage.output = _num(usage['output_tokens']);
      message.usage.cacheRead = _num(usage['cache_read_input_tokens']);
      message.usage.cacheWrite = _num(usage['cache_creation_input_tokens']);
      final cacheCreation = usage['cache_creation'];
      if (cacheCreation is Map<String, dynamic>) {
        message.usage.cacheWrite1h =
            _num(cacheCreation['ephemeral_1h_input_tokens']);
      }
      // Anthropic doesn't provide total_tokens, compute from components.
      message.usage.totalTokens = message.usage.input +
          message.usage.output +
          message.usage.cacheRead +
          message.usage.cacheWrite;
    }
    return <ProviderStreamEvent>[ProviderStart()];
  }

  List<ProviderStreamEvent> _onContentBlockStart(Map<String, dynamic> event) {
    final block = event['content_block'];
    if (block is! Map<String, dynamic>) return const <ProviderStreamEvent>[];
    final index = (event['index'] as num?)?.toInt() ?? 0;
    switch (block['type'] as String?) {
      case 'fallback':
        if (message.content.isNotEmpty) {
          throw ProviderStreamException(
              'Anthropic performed an unsupported mid-output model fallback');
        } else {
          return const <ProviderStreamEvent>[];
        }
      case 'text':
        final text = ProviderTextBlock(block['text'] as String? ?? '');
        message.content.add(text);
        _openBlocks[index] = _OpenBlock(message.content.length - 1);
        return <ProviderStreamEvent>[
          TextStart(message.content.length - 1),
        ];
      case 'thinking':
        final thinking = ProviderThinkingBlock(
          block['thinking'] as String? ?? '',
          block['signature'] as String? ?? '',
        );
        message.content.add(thinking);
        _openBlocks[index] = _OpenBlock(message.content.length - 1);
        return <ProviderStreamEvent>[ThinkingStart(message.content.length - 1)];
      case 'redacted_thinking':
        final thinking = ProviderThinkingBlock(
            '[Reasoning redacted]', block['data'] as String? ?? '')
          ..redacted = true;
        message.content.add(thinking);
        _openBlocks[index] = _OpenBlock(message.content.length - 1);
        return <ProviderStreamEvent>[ThinkingStart(message.content.length - 1)];
      case 'tool_use':
        final input = block['input'];
        final toolCall = ProviderToolCall(
          id: block['id'] as String? ?? '',
          name: block['name'] as String? ?? '',
          arguments:
              input is Map<String, dynamic> ? input : <String, dynamic>{},
        );
        message.content.add(toolCall);
        _openBlocks[index] = _OpenBlock(
          message.content.length - 1,
          ToolCallArgumentsStream(),
        );
        return <ProviderStreamEvent>[ToolcallStart(message.content.length - 1)];
      default:
        return const <ProviderStreamEvent>[];
    }
  }

  List<ProviderStreamEvent> _onContentBlockDelta(Map<String, dynamic> event) {
    final delta = event['delta'];
    if (delta is! Map<String, dynamic>) return const <ProviderStreamEvent>[];
    final index = (event['index'] as num?)?.toInt() ?? 0;
    final open = _openBlocks[index];
    if (open == null) return const <ProviderStreamEvent>[];
    final contentIndex = open.contentIndex;
    switch (delta['type'] as String?) {
      case 'text_delta':
        if (message.content[contentIndex] is! ProviderTextBlock) {
          return const <ProviderStreamEvent>[];
        }
        final text = delta['text'] as String?;
        if (text == null) return const <ProviderStreamEvent>[];
        (message.content[contentIndex] as ProviderTextBlock).text += text;
        return <ProviderStreamEvent>[TextDelta(contentIndex, text)];
      case 'thinking_delta':
        if (message.content[contentIndex] is! ProviderThinkingBlock) {
          return const <ProviderStreamEvent>[];
        }
        final text = delta['thinking'] as String?;
        if (text == null) return const <ProviderStreamEvent>[];
        (message.content[contentIndex] as ProviderThinkingBlock).thinking +=
            text;
        return <ProviderStreamEvent>[ThinkingDelta(contentIndex, text)];
      case 'input_json_delta':
        final toolCall = message.content[contentIndex];
        if (toolCall is! ProviderToolCall || open.arguments == null) {
          return const <ProviderStreamEvent>[];
        }
        final partialJson = delta['partial_json'] as String?;
        if (partialJson == null) return const <ProviderStreamEvent>[];
        toolCall.arguments = open.arguments!.append(partialJson);
        return <ProviderStreamEvent>[ToolcallDelta(contentIndex, partialJson)];
      case 'signature_delta':
        final block = message.content[contentIndex];
        if (block is! ProviderThinkingBlock) {
          return const <ProviderStreamEvent>[];
        }
        final signature = delta['signature'] as String?;
        if (signature == null) return const <ProviderStreamEvent>[];
        block.thinkingSignature += signature;
        return const <ProviderStreamEvent>[];
      default:
        return const <ProviderStreamEvent>[];
    }
  }

  List<ProviderStreamEvent> _onContentBlockStop(Map<String, dynamic> event) {
    final index = (event['index'] as num?)?.toInt() ?? 0;
    final open = _openBlocks.remove(index);
    if (open == null) return const <ProviderStreamEvent>[];
    final contentIndex = open.contentIndex;
    final block = message.content[contentIndex];
    if (block is ProviderTextBlock) {
      return <ProviderStreamEvent>[TextEnd(contentIndex, block.text)];
    }
    if (block is ProviderThinkingBlock) {
      return <ProviderStreamEvent>[ThinkingEnd(contentIndex, block.thinking)];
    }
    if (block is ProviderToolCall && open.arguments != null) {
      final finished = open.arguments!.finish();
      block.arguments = finished.arguments;
      block.argumentsError = finished.argumentsError;
      return <ProviderStreamEvent>[ToolcallEnd(contentIndex, block)];
    }
    return const <ProviderStreamEvent>[];
  }

  List<ProviderStreamEvent> _onMessageDelta(Map<String, dynamic> event) {
    final delta = event['delta'];
    if (delta is! Map<String, dynamic>) return const <ProviderStreamEvent>[];
    final events = <ProviderStreamEvent>[];
    final rawReason = delta['stop_reason'];
    if (rawReason is String) {
      message.rawStopReason = rawReason;
      final mapped = mapAnthropicStopReason(
        rawReason,
        refusalExplanation: _refusalExplanation(delta['stop_details']),
      );
      message.stopReason = mapped.stopReason;
      if (mapped.errorMessage != null) {
        message.errorMessage = mapped.errorMessage;
      }
    }
    final usage = event['usage'];
    if (usage is Map<String, dynamic>) {
      // Only update usage fields if present (not null). Preserves input
      // tokens from message_start when proxies omit them in message_delta.
      if (usage['input_tokens'] != null) {
        message.usage.input = _num(usage['input_tokens']);
      }
      if (usage['output_tokens'] != null) {
        message.usage.output = _num(usage['output_tokens']);
      }
      if (usage['cache_read_input_tokens'] != null) {
        message.usage.cacheRead = _num(usage['cache_read_input_tokens']);
      }
      if (usage['cache_creation_input_tokens'] != null) {
        message.usage.cacheWrite = _num(usage['cache_creation_input_tokens']);
      }
      final cacheCreation = usage['cache_creation'];
      if (cacheCreation is Map<String, dynamic> &&
          cacheCreation['ephemeral_1h_input_tokens'] != null) {
        message.usage.cacheWrite1h =
            _num(cacheCreation['ephemeral_1h_input_tokens']);
      }
      // Anthropic reports reasoning tokens as a subset of output tokens.
      final outputDetails = usage['output_tokens_details'];
      if (outputDetails is Map<String, dynamic>) {
        final thinkingTokens = outputDetails['thinking_tokens'];
        if (thinkingTokens != null) {
          message.usage.reasoning = _num(thinkingTokens);
        }
      }
    }
    message.usage.totalTokens = message.usage.input +
        message.usage.output +
        message.usage.cacheRead +
        message.usage.cacheWrite;
    return events;
  }

  String? _refusalExplanation(Object? stopDetails) {
    if (stopDetails is Map<String, dynamic>) {
      final explanation = stopDetails['explanation'];
      if (explanation is String) return explanation;
    }
    return null;
  }
}

int _num(Object? value) => (value as num?)?.toInt() ?? 0;
