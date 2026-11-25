// OpenAI-compatible chat-completions streaming-event parsing.
//
// Port of the streaming surface of `packages/ai/src/api/openai-completions.ts`
// at upstream `c11a73bfba1310dc4075ad836254ea87003f409b`: the chunk loop of
// `stream()` over `chat.completion.chunk` payloads — response id/model
// capture, chunk- and choice-level usage (the Moonshot `choice.usage`
// fallback), `finish_reason` mapping, reasoning in the `reasoning_content`
// family mapped to thinking blocks, lazy text blocks, index/id-keyed tool-call
// delta merging through `ToolCallArgumentsStream`, and the terminal checks.
//
// Not ported here (out of this slice): the HTTP transport, request building,
// OpenRouter billing/native-finish-reason extras, `reasoning_details` replay
// data, and the custom-tool grammar input path.

import 'provider_events.dart';
import 'provider_stop_reason.dart';
import 'streaming_json.dart';

/// Streaming state of one tool call under assembly.
class _ToolCallStreamState {
  int? streamIndex;
  final ToolCallArgumentsStream arguments = ToolCallArgumentsStream();
  _ToolCallStreamState(this.streamIndex);
}

/// Parses OpenAI-compatible chat-completions chunks into canonical stream
/// events.
///
/// Feed each decoded chunk payload (the `data:` JSON of one SSE event, with
/// the `[DONE]` sentinel filtered by the caller), then call [end] once the
/// stream closes. Parsers throw [ProviderStreamException] on the failure
/// shapes upstream throws (an error finish reason, a stream that ends without
/// `finish_reason`), so a caller's single catch produces the terminal `error`
/// outcome exactly like the upstream API's outer catch does.
class OpenAiStreamParser {
  /// Whether the provider reliably sends a `finish_reason` (`compat
  /// .supportsFinishReason`): when true, a stream that ends without one is a
  /// failure; when false, the ending is derived from the content.
  final bool supportsFinishReason;

  /// The requested model id, so a differing response model is recorded like
  /// upstream records `chunk.model !== model.id`.
  final String? requestedModelId;

  /// The OpenAiStreamParser.
  OpenAiStreamParser(
      {this.supportsFinishReason = false, this.requestedModelId});

  /// The message.
  final ProviderMessageState message = ProviderMessageState();
  final Map<int, _ToolCallStreamState> _toolCallStates =
      <int, _ToolCallStreamState>{};
  final Map<int, int> _toolCallBlocksByStreamIndex = <int, int>{};
  final Map<String, int> _toolCallBlocksById = <String, int>{};
  ProviderTextBlock? _textBlock;
  ProviderThinkingBlock? _thinkingBlock;
  bool _hasFinishReason = false;
  bool _finished = false;

  /// Feed one decoded chunk; returns the canonical events it produced.
  List<ProviderStreamEvent> feedChunk(Map<String, dynamic> chunk) {
    final events = <ProviderStreamEvent>[];
    final id = chunk['id'];
    if (id is String &&
        id.isNotEmpty &&
        (message.responseId?.isEmpty ?? true)) {
      message.responseId = id;
    }
    final model = chunk['model'];
    if (model is String &&
        model.isNotEmpty &&
        message.responseModel == null &&
        model != requestedModelId) {
      message.responseModel = model;
    }

    final rawUsage = chunk['usage'];
    if (rawUsage is Map<String, dynamic>) {
      message.usage = parseOpenAiChunkUsage(rawUsage);
    }

    final choices = chunk['choices'];
    final choice = choices is List &&
            choices.isNotEmpty &&
            choices.first is Map<String, dynamic>
        ? choices.first as Map<String, dynamic>
        : null;
    if (choice == null) return events;

    // Fallback: some providers (e.g., Moonshot) return usage in choice.usage
    // instead of the standard chunk.usage.
    if (rawUsage == null) {
      final choiceUsage = choice['usage'];
      if (choiceUsage is Map<String, dynamic>) {
        message.usage = parseOpenAiChunkUsage(choiceUsage);
      }
    }

    final finishReason = choice['finish_reason'];
    if (finishReason is String && finishReason.isNotEmpty) {
      message.rawStopReason = finishReason;
      final mapped = mapOpenAiStopReason(finishReason);
      message.stopReason = mapped.stopReason;
      if (mapped.errorMessage != null) {
        message.errorMessage = mapped.errorMessage;
      }
      _hasFinishReason = true;
    }

    final delta = choice['delta'];
    if (delta is Map<String, dynamic>) {
      // Handle reasoning before content: some proxies (e.g. LiteLLM)
      // aggregate reasoning and answer into one delta, and the thinking block
      // must precede the text block. Use the first non-empty reasoning field
      // to avoid duplication (e.g., chutes.ai returns reasoning_content and
      // reasoning with same content).
      const reasoningFields = [
        'reasoning_content',
        'reasoning',
        'reasoning_text'
      ];
      String? foundReasoningField;
      for (final field in reasoningFields) {
        final value = delta[field];
        if (value is String && value.isNotEmpty) {
          foundReasoningField = field;
          break;
        }
      }
      if (foundReasoningField != null) {
        final thinkingDelta = delta[foundReasoningField] as String;
        final block = _ensureThinkingBlock(foundReasoningField);
        if (block.thinking.isEmpty && message.content.last == block) {
          events.add(ThinkingStart(message.content.length - 1));
        }
        block.thinking += thinkingDelta;
        events.add(ThinkingDelta(_indexOf(_thinkingBlock!), thinkingDelta));
      }

      final content = delta['content'];
      if (content is String && content.isNotEmpty) {
        final block = _ensureTextBlock();
        if (block.text.isEmpty && message.content.last == block) {
          events.add(TextStart(message.content.length - 1));
        }
        block.text += content;
        events.add(TextDelta(_indexOf(_textBlock!), content));
      }

      final toolCalls = delta['tool_calls'];
      if (toolCalls is List) {
        for (final toolCall in toolCalls) {
          if (toolCall is! Map<String, dynamic>) continue;
          events.addAll(_applyToolCallDelta(toolCall));
        }
      }
    }
    return events;
  }

  /// Finish the stream: close every open block in content order, run the
  /// terminal checks, and emit the final `done`. The block-finish events are
  /// appended to [sink] (when given) BEFORE the terminal checks, so a thrown
  /// failure still leaves the events the upstream stream had already pushed
  /// visible to the caller.
  List<ProviderStreamEvent> end({List<ProviderStreamEvent>? sink}) {
    if (_finished) return const <ProviderStreamEvent>[];
    _finished = true;
    final events = sink ?? <ProviderStreamEvent>[];
    for (final block in List<Object>.from(message.content)) {
      events.addAll(_finishBlock(block));
    }
    if (message.stopReason == 'aborted') {
      throw ProviderStreamException('Request was aborted');
    }
    if (!_hasFinishReason && !supportsFinishReason) {
      message.stopReason = message.content.any((b) => b is ProviderToolCall)
          ? 'toolUse'
          : 'stop';
    }
    if (message.stopReason == 'error') {
      throw ProviderStreamException(
          message.errorMessage ?? 'Provider returned an error stop reason');
    }
    if ((supportsFinishReason && !_hasFinishReason) ||
        message.stopReason == 'pending') {
      throw ProviderStreamException('Stream ended without finish_reason');
    }
    events.add(ProviderDone(message.stopReason));
    return events;
  }

  List<ProviderStreamEvent> _applyToolCallDelta(Map<String, dynamic> toolCall) {
    final function = toolCall['function'];
    final name = function is Map<String, dynamic>
        ? function['name'] as String? ?? ''
        : '';
    final streamIndex =
        toolCall['index'] is num ? (toolCall['index'] as num).toInt() : null;
    final id = toolCall['id'];

    var contentIndex =
        streamIndex != null ? _toolCallBlocksByStreamIndex[streamIndex] : null;
    contentIndex ??=
        id is String && id.isNotEmpty ? _toolCallBlocksById[id] : null;

    final events = <ProviderStreamEvent>[];
    _ToolCallStreamState state;
    if (contentIndex == null) {
      final block = ProviderToolCall(
        id: id is String && id.isNotEmpty ? id : '',
        name: name,
        arguments: <String, dynamic>{},
      );
      message.content.add(block);
      contentIndex = message.content.length - 1;
      state = _ToolCallStreamState(streamIndex);
      _toolCallStates[contentIndex] = state;
      if (streamIndex != null) {
        _toolCallBlocksByStreamIndex[streamIndex] = contentIndex;
      }
      if (id is String && id.isNotEmpty) _toolCallBlocksById[id] = contentIndex;
      events.add(ToolcallStart(contentIndex));
    } else {
      state = _toolCallStates[contentIndex]!;
      if (streamIndex != null && state.streamIndex == null) {
        state.streamIndex = streamIndex;
        _toolCallBlocksByStreamIndex[streamIndex] = contentIndex;
      }
    }

    final block = message.content[contentIndex] as ProviderToolCall;
    if (id is String && id.isNotEmpty && block.id.isEmpty) {
      block.id = id;
      _toolCallBlocksById[id] = contentIndex;
    }
    if (block.name.isEmpty && name.isNotEmpty) block.name = name;

    var deltaText = '';
    final args =
        function is Map<String, dynamic> ? function['arguments'] : null;
    if (args is String) {
      deltaText = args;
      block.arguments = state.arguments.append(deltaText);
    }
    events.add(ToolcallDelta(contentIndex, deltaText));
    return events;
  }

  ProviderTextBlock _ensureTextBlock() {
    if (_textBlock == null) {
      _textBlock = ProviderTextBlock();
      message.content.add(_textBlock!);
    }
    return _textBlock!;
  }

  ProviderThinkingBlock _ensureThinkingBlock(String thinkingSignature) {
    if (_thinkingBlock == null) {
      _thinkingBlock = ProviderThinkingBlock('', thinkingSignature);
      message.content.add(_thinkingBlock!);
    }
    return _thinkingBlock!;
  }

  List<ProviderStreamEvent> _finishBlock(Object block) {
    final contentIndex = _indexOf(block);
    if (block is ProviderTextBlock) {
      return <ProviderStreamEvent>[TextEnd(contentIndex, block.text)];
    }
    if (block is ProviderThinkingBlock) {
      return <ProviderStreamEvent>[ThinkingEnd(contentIndex, block.thinking)];
    }
    if (block is ProviderToolCall) {
      final state = _toolCallStates.remove(contentIndex);
      if (state != null) {
        final finished = state.arguments.finish();
        block.arguments = finished.arguments;
        block.argumentsError = finished.argumentsError;
      }
      return <ProviderStreamEvent>[ToolcallEnd(contentIndex, block)];
    }
    return const <ProviderStreamEvent>[];
  }

  int _indexOf(Object block) => message.content.indexOf(block);
}

/// Token accounting of one OpenAI-compatible usage payload
/// (`parseChunkUsage` upstream). Cached tokens are cache-read tokens:
/// providers disagree on placement — OpenAI/OpenRouter use
/// `prompt_tokens_details.cached_tokens`, DeepSeek uses
/// `prompt_cache_hit_tokens`, Kimi documents top-level `cached_tokens`.
/// Writes ride `prompt_tokens_details.cache_write_tokens` and are never
/// subtracted from `cached_tokens`. OpenAI's `completion_tokens` already
/// includes reasoning tokens.
ProviderUsage parseOpenAiChunkUsage(Map<String, dynamic> rawUsage) {
  final promptTokens = _num(rawUsage['prompt_tokens']);
  final details = rawUsage['prompt_tokens_details'];
  final detailsMap =
      details is Map<String, dynamic> ? details : const <String, dynamic>{};
  final cacheReadTokens = _numOrNull(detailsMap['cached_tokens']) ??
      _numOrNull(rawUsage['prompt_cache_hit_tokens']) ??
      _numOrNull(rawUsage['cached_tokens']) ??
      0;
  final cacheWriteTokens = _num(detailsMap['cache_write_tokens']);
  final input = (promptTokens - cacheReadTokens - cacheWriteTokens)
      .clamp(0, 1 << 62)
      .toInt();
  final outputTokens = _num(rawUsage['completion_tokens']);
  final completionDetails = rawUsage['completion_tokens_details'];
  final completionDetailsMap = completionDetails is Map<String, dynamic>
      ? completionDetails
      : const <String, dynamic>{};
  final reasoningFromDetails = _num(completionDetailsMap['reasoning_tokens']);
  final reasoningTopLevel = _num(rawUsage['reasoning_tokens']);
  final usage = ProviderUsage()
    ..input = input
    ..output = outputTokens
    ..cacheRead = cacheReadTokens
    ..cacheWrite = cacheWriteTokens
    // First non-zero wins, as upstream's `||` chain reads it.
    ..reasoning =
        reasoningFromDetails != 0 ? reasoningFromDetails : reasoningTopLevel
    ..totalTokens = input + outputTokens + cacheReadTokens + cacheWriteTokens;
  return usage;
}

int _num(Object? value) => (value as num?)?.toInt() ?? 0;

int? _numOrNull(Object? value) => (value as num?)?.toInt();
