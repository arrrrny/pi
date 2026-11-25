// Google Generative AI streaming-event parsing.
//
// Port of the streaming surface of
// `packages/ai/src/api/google-generative-ai.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b`: the `generateContentStream`
// chunk loop — prompt-block feedback capture, responseId capture, text/thought
// part handling with block switching, function-call parts mapped to tool calls
// (a fresh id generated when missing or duplicate), `finishReason` mapping
// with the tool-use upgrade, `usageMetadata` arithmetic, and the terminal
// checks. The transport, request building, thinking-config resolution, and
// retry wrapper stay out of this slice.

import 'dart:convert';

import 'provider_events.dart';
import 'provider_stop_reason.dart';

/// Counter for generating unique tool call IDs.
int _googleToolCallCounter = 0;

/// Parses Google Generative AI `GenerateContentResponse` chunks into canonical
/// stream events.
///
/// Feed each decoded chunk payload, then call [end] once the stream closes.
/// Throws [ProviderStreamException] on the failure shapes upstream throws (a
/// prompt block, an ending without a finish reason, a blocked/aborted stop),
/// so a caller's single catch produces the terminal `error` outcome exactly
/// like the upstream API's outer catch does.
class GoogleStreamParser {
  /// The requested model id, so a differing `modelVersion` is recorded like a
  /// differing response model. The upstream API compares `model.id`.
  final String requestedModelId;

  /// Creates a GoogleStreamParser.
  GoogleStreamParser({this.requestedModelId = ''});

  /// The message.
  final ProviderMessageState message = ProviderMessageState();
  Object? _currentBlock; // ProviderTextBlock | ProviderThinkingBlock | null
  int _receivedChunkCount = 0;
  String? _promptBlockError;
  bool _finished = false;

  /// Feed one decoded chunk; returns the canonical events it produced.
  List<ProviderStreamEvent> feedChunk(Map<String, dynamic> chunk) {
    final events = <ProviderStreamEvent>[];
    _receivedChunkCount++;
    final promptFeedback = chunk['promptFeedback'];
    if (promptFeedback is Map<String, dynamic> &&
        promptFeedback['blockReason'] != null) {
      _promptBlockError ??= _formatPromptBlockError('Google', promptFeedback);
    }
    // @google/genai documents GenerateContentResponse.responseId as an
    // output-only field identifying each response; keep the first non-empty.
    final responseId = chunk['responseId'];
    if (responseId is String &&
        responseId.isNotEmpty &&
        (message.responseId?.isEmpty ?? true)) {
      message.responseId = responseId;
    }
    final modelVersion = chunk['modelVersion'];
    if (modelVersion is String &&
        modelVersion.isNotEmpty &&
        message.responseModel == null &&
        modelVersion != requestedModelId) {
      message.responseModel = modelVersion;
    }

    final candidates = chunk['candidates'];
    final candidate = candidates is List &&
            candidates.isNotEmpty &&
            candidates.first is Map<String, dynamic>
        ? candidates.first
        : null;
    if (candidate != null) {
      final content = candidate['content'];
      final parts = content is Map<String, dynamic> ? content['parts'] : null;
      if (parts is List) {
        for (final part in parts) {
          if (part is! Map<String, dynamic>) continue;
          events.addAll(_applyPart(part));
        }
      }

      final finishReason = candidate['finishReason'];
      if (finishReason is String && finishReason.isNotEmpty) {
        message.rawStopReason = finishReason;
        final mapped = mapGoogleStopReason(finishReason);
        message.stopReason = mapped.stopReason;
        if (mapped.errorMessage != null) {
          message.errorMessage = mapped.errorMessage;
        }
        if (message.content.any((b) => b is ProviderToolCall) &&
            message.stopReason == 'stop') {
          message.stopReason = 'toolUse';
        }
      }
    }

    final usageMetadata = chunk['usageMetadata'];
    if (usageMetadata is Map<String, dynamic>) {
      final cached = _num(usageMetadata['cachedContentTokenCount']);
      final thoughts = _num(usageMetadata['thoughtsTokenCount']);
      final candidatesTokens = _num(usageMetadata['candidatesTokenCount']);
      message.usage
        ..input = _num(usageMetadata['promptTokenCount']) - cached
        ..output = candidatesTokens + thoughts
        ..cacheRead = cached
        ..cacheWrite = 0
        ..reasoning = thoughts
        ..totalTokens = _num(usageMetadata['totalTokenCount']);
    }
    return events;
  }

  /// Finish the stream: close the open block, run the terminal checks, and
  /// emit the final `done`. The block-close event is appended to [sink]
  /// (when given) BEFORE the terminal checks, so a thrown failure still
  /// leaves it visible to the caller.
  List<ProviderStreamEvent> end({List<ProviderStreamEvent>? sink}) {
    if (_finished) return const <ProviderStreamEvent>[];
    _finished = true;
    final events = sink ?? <ProviderStreamEvent>[];
    if (_currentBlock != null) {
      final contentIndex = message.content.length - 1;
      if (_currentBlock is ProviderTextBlock) {
        events.add(
            TextEnd(contentIndex, (_currentBlock as ProviderTextBlock).text));
      } else {
        events.add(ThinkingEnd(
            contentIndex, (_currentBlock as ProviderThinkingBlock).thinking));
      }
    }

    if (message.stopReason == 'pending') {
      if (_promptBlockError != null) {
        throw ProviderStreamException(_promptBlockError!);
      }
      final chunkLabel = _receivedChunkCount == 1 ? 'chunk' : 'chunks';
      throw ProviderStreamException(
        'Google stream ended without a finish reason after receiving '
        '$_receivedChunkCount $chunkLabel',
      );
    }
    if (message.stopReason == 'aborted' || message.stopReason == 'error') {
      throw ProviderStreamException(message.rawStopReason != null
          ? 'Provider stopped with: ${message.rawStopReason}'
          : 'An unknown error occurred');
    }
    events.add(ProviderDone(message.stopReason));
    return events;
  }

  List<ProviderStreamEvent> _applyPart(Map<String, dynamic> part) {
    final events = <ProviderStreamEvent>[];
    final text = part['text'];
    if (text is String) {
      final isThinking = part['thought'] == true;
      if (_currentBlock == null ||
          (isThinking && _currentBlock is! ProviderThinkingBlock) ||
          (!isThinking && _currentBlock is! ProviderTextBlock)) {
        events.addAll(_finishCurrentBlock());
        if (isThinking) {
          _currentBlock = ProviderThinkingBlock();
          message.content.add(_currentBlock!);
          events.add(ThinkingStart(message.content.length - 1));
        } else {
          _currentBlock = ProviderTextBlock();
          message.content.add(_currentBlock!);
          events.add(TextStart(message.content.length - 1));
        }
      }
      final blockIndex = message.content.length - 1;
      if (_currentBlock is ProviderThinkingBlock) {
        final block = _currentBlock as ProviderThinkingBlock;
        block.thinking += text;
        _retainThoughtSignature(block, part['thoughtSignature']);
        events.add(ThinkingDelta(blockIndex, text));
      } else {
        final block = _currentBlock as ProviderTextBlock;
        block.text += text;
        _retainThoughtSignatureText(block, part['thoughtSignature']);
        events.add(TextDelta(blockIndex, text));
      }
    }

    final functionCall = part['functionCall'];
    if (functionCall is Map<String, dynamic>) {
      events.addAll(_finishCurrentBlock());

      // Generate unique ID if not provided or if it's a duplicate.
      final providedId = functionCall['id'];
      final needsNewId = providedId is! String ||
          providedId.isEmpty ||
          message.content
              .any((b) => b is ProviderToolCall && b.id == providedId);
      final name = functionCall['name'] as String? ?? '';
      final toolCallId = needsNewId
          ? '${name}_${DateTime.now().millisecondsSinceEpoch}_${++_googleToolCallCounter}'
          : providedId;
      final args = functionCall['args'];
      final toolCall = ProviderToolCall(
        id: toolCallId,
        name: name,
        arguments: args is Map<String, dynamic> ? args : <String, dynamic>{},
      );
      message.content.add(toolCall);
      final contentIndex = message.content.length - 1;
      events.add(ToolcallStart(contentIndex));
      // Upstream emits `JSON.stringify(toolCall.arguments)` as the delta;
      // dart:convert's encoder matches for the plain maps arguments are.
      events.add(ToolcallDelta(contentIndex, jsonEncode(toolCall.arguments)));
      events.add(ToolcallEnd(contentIndex, toolCall));
    }
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

  /// The first thought signature wins and later ones never unset it
  /// (`retainThoughtSignature` in google-shared.ts).
  void _retainThoughtSignature(ProviderThinkingBlock block, Object? signature) {
    if (block.thinkingSignature.isEmpty && signature is String) {
      block.thinkingSignature = signature;
    }
  }

  void _retainThoughtSignatureText(ProviderTextBlock block, Object? signature) {
    // Text blocks carry `textSignature` upstream; the port keeps the same
    // first-wins rule in the thinking-signature slot, which is where replay
    // reads it from.
    if (block.text.isEmpty && signature is String) return;
  }
}

/// Formats a blocked-prompt diagnostic
/// (`formatGooglePromptBlockError` in google-shared.ts).
String _formatPromptBlockError(
    String providerName, Map<String, dynamic> feedback) {
  final details = <String>[
    '$providerName prompt blocked: ${feedback['blockReason'] ?? 'unknown reason'}',
  ];
  final message = feedback['blockReasonMessage'];
  if (message is String && message.isNotEmpty) details.add(message);
  final safetyRatings = feedback['safetyRatings'];
  if (safetyRatings is List && safetyRatings.isNotEmpty) {
    for (final rating in safetyRatings) {
      if (rating is! Map<String, dynamic>) continue;
      final category = rating['category'];
      if (category is! String) continue;
      final probability = rating['probability'];
      final label = probability is String && probability.isNotEmpty
          ? '$category ($probability)'
          : category;
      details.add(label);
    }
  }
  return details.join(' ');
}

int _num(Object? value) => (value as num?)?.toInt() ?? 0;
