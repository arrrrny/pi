// The canonical provider streaming event vocabulary.
//
// Models the `AssistantMessageEvent` union and the assistant-message state the
// upstream provider APIs assemble while streaming
// (`packages/ai/src/types.ts`, `packages/ai/src/api/*`), using the upstream
// names as data: `start`, `text_start`, `text_delta`, `text_end`,
// `thinking_start`, `thinking_delta`, `thinking_end`, `toolcall_start`,
// `toolcall_delta`, `toolcall_end`, `done`, `error`, and the stop reasons
// `"pending" | "stop" | "length" | "toolUse" | "error" | "aborted" |
// "deferred"`.
//
// The parsers in this library emit these events and assemble one
// [ProviderMessageState]; `toJson` renders the canonical form the differential
// harness compares byte-for-byte across the TypeScript oracle and the Dart
// port.

import 'streaming_json.dart';

/// The assembled assistant message one provider stream produces.
class ProviderMessageState {
  /// Content blocks completed so far, in provider order: plain maps shaped
  /// like the canonical blocks (`text`, `thinking`, `toolCall`).
  final List<Object> content = <Object>[];

  /// The provider's response identifier, when it sent one.
  String? responseId;

  /// The model id the provider reports, when it differs from the request.
  String? responseModel;

  /// The provider's own stop reason, before mapping.
  String? rawStopReason;

  /// The mapped canonical stop reason; `"pending"` until a provider reports
  /// how the stream ended.
  String stopReason = 'pending';

  /// The failure diagnostic when [stopReason] is `"error"` or `"aborted"`.
  String? errorMessage;

  /// Wall-clock duration of the response, stamped by the event stream that
  /// delivered it. Deliberately excluded from [toJson]: the canonical form
  /// the differential harness compares carries no wall-clock values.
  int? durationMs;

  /// Token accounting assembled from the stream's usage reports.
  ProviderUsage usage = ProviderUsage();

  /// Canonical JSON: the shape the differential harness compares.
  Map<String, dynamic> toJson() {
    final blocks = content.map(_blockToJson).toList();
    return {
      'role': 'assistant',
      'content': blocks,
      'stopReason': stopReason,
      'usage': usage.toJson(),
      if (rawStopReason != null) 'rawStopReason': rawStopReason,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (responseId != null) 'responseId': responseId,
      if (responseModel != null) 'responseModel': responseModel,
    };
  }
}

/// Token accounting assembled from a provider stream's usage reports.
class ProviderUsage {
  /// The input.
  int input = 0;

  /// The output.
  int output = 0;

  /// The cacheRead.
  int cacheRead = 0;

  /// The cacheWrite.
  int cacheWrite = 0;

  /// 1-hour cache-write tokens, when a provider reports the TTL breakdown.
  int cacheWrite1h = 0;

  /// Reasoning tokens, when a provider reports them.
  int reasoning = 0;

  /// The provider's total, or the component sum when it does not report one.
  int totalTokens = 0;

  /// Canonical JSON: components plus optional non-zero extras.
  Map<String, dynamic> toJson() => {
        'input': input,
        'output': output,
        'cacheRead': cacheRead,
        'cacheWrite': cacheWrite,
        if (cacheWrite1h != 0) 'cacheWrite1h': cacheWrite1h,
        if (reasoning != 0) 'reasoning': reasoning,
        'totalTokens': totalTokens,
      };
}

/// One streaming event in the canonical vocabulary. Each event renders to the
/// canonical record the differential harness compares; the assistant message
/// snapshot travels only on the terminal record, not on every delta.
sealed class ProviderStreamEvent {
  /// The canonical event name.
  String get type;

  /// Canonical JSON record (without the harness's `seq`).
  Map<String, dynamic> toJson() => {'type': type};
}

/// The value.
class ProviderStart extends ProviderStreamEvent {
  @override
  String get type => 'start';
}

/// The value.
class TextStart extends ProviderStreamEvent {
  /// The contentIndex.
  final int contentIndex;

  /// Creates a TextStart.
  TextStart(this.contentIndex);
  @override
  String get type => 'text_start';
  @override
  Map<String, dynamic> toJson() => {'type': type, 'contentIndex': contentIndex};
}

/// The value.
class TextDelta extends ProviderStreamEvent {
  /// The contentIndex.
  final int contentIndex;

  /// The delta.
  final String delta;

  /// Creates a TextDelta.
  TextDelta(this.contentIndex, this.delta);
  @override
  String get type => 'text_delta';
  @override
  Map<String, dynamic> toJson() =>
      {'type': type, 'contentIndex': contentIndex, 'delta': delta};
}

/// The value.
class TextEnd extends ProviderStreamEvent {
  /// The contentIndex.
  final int contentIndex;

  /// The content.
  final String content;

  /// Creates a TextEnd.
  TextEnd(this.contentIndex, this.content);
  @override
  String get type => 'text_end';
  @override
  Map<String, dynamic> toJson() =>
      {'type': type, 'contentIndex': contentIndex, 'content': content};
}

/// The value.
class ThinkingStart extends ProviderStreamEvent {
  /// The contentIndex.
  final int contentIndex;

  /// Creates a ThinkingStart.
  ThinkingStart(this.contentIndex);
  @override
  String get type => 'thinking_start';
  @override
  Map<String, dynamic> toJson() => {'type': type, 'contentIndex': contentIndex};
}

/// The value.
class ThinkingDelta extends ProviderStreamEvent {
  /// The contentIndex.
  final int contentIndex;

  /// The delta.
  final String delta;

  /// Creates a ThinkingDelta.
  ThinkingDelta(this.contentIndex, this.delta);
  @override
  String get type => 'thinking_delta';
  @override
  Map<String, dynamic> toJson() =>
      {'type': type, 'contentIndex': contentIndex, 'delta': delta};
}

/// The value.
class ThinkingEnd extends ProviderStreamEvent {
  /// The contentIndex.
  final int contentIndex;

  /// The content.
  final String content;

  /// Creates a ThinkingEnd.
  ThinkingEnd(this.contentIndex, this.content);
  @override
  String get type => 'thinking_end';
  @override
  Map<String, dynamic> toJson() =>
      {'type': type, 'contentIndex': contentIndex, 'content': content};
}

/// The value.
class ToolcallStart extends ProviderStreamEvent {
  /// The contentIndex.
  final int contentIndex;

  /// Creates a ToolcallStart.
  ToolcallStart(this.contentIndex);
  @override
  String get type => 'toolcall_start';
  @override
  Map<String, dynamic> toJson() => {'type': type, 'contentIndex': contentIndex};
}

/// The value.
class ToolcallDelta extends ProviderStreamEvent {
  /// The contentIndex.
  final int contentIndex;

  /// The delta.
  final String delta;

  /// Creates a ToolcallDelta.
  ToolcallDelta(this.contentIndex, this.delta);
  @override
  String get type => 'toolcall_delta';
  @override
  Map<String, dynamic> toJson() =>
      {'type': type, 'contentIndex': contentIndex, 'delta': delta};
}

/// The value.
class ToolcallEnd extends ProviderStreamEvent {
  /// The contentIndex.
  final int contentIndex;

  /// The toolCall.
  final ProviderToolCall toolCall;

  /// Creates a ToolcallEnd.
  ToolcallEnd(this.contentIndex, this.toolCall);
  @override
  String get type => 'toolcall_end';
  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'contentIndex': contentIndex,
        'toolCall': toolCall.toJson()
      };
}

/// The stream completed cleanly; [reason] is `"stop" | "length" | "toolUse" |
/// "deferred"`.
class ProviderDone extends ProviderStreamEvent {
  /// The reason.
  final String reason;

  /// Creates a ProviderDone.
  ProviderDone(this.reason);
  @override
  String get type => 'done';
  @override
  Map<String, dynamic> toJson() => {'type': type, 'reason': reason};
}

/// The stream failed or was aborted; [reason] is `"aborted" | "error"`.
class ProviderErrorEvent extends ProviderStreamEvent {
  /// The reason.
  final String reason;

  /// The errorMessage.
  final String errorMessage;

  /// Creates a ProviderErrorEvent.
  ProviderErrorEvent(this.reason, this.errorMessage);
  @override
  String get type => 'error';
  @override
  Map<String, dynamic> toJson() =>
      {'type': type, 'reason': reason, 'errorMessage': errorMessage};
}

/// A tool call block inside the assembled message.
class ProviderToolCall {
  /// The id.
  String id;

  /// The name.
  String name;

  /// The arguments.
  Map<String, dynamic> arguments;

  /// The parse failure of the finished argument text, when malformed.
  String? argumentsError;

  /// The ProviderToolCall.
  ProviderToolCall({
    required this.id,
    required this.name,
    required this.arguments,
    this.argumentsError,
  });

  /// Canonical JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (argumentsError != null) 'argumentsError': argumentsError,
        'arguments': argumentsError == null ? arguments : <String, dynamic>{},
      };
}

/// A text block inside the assembled message.
class ProviderTextBlock {
  /// The text.
  String text = '';

  /// Creates a ProviderTextBlock.
  ProviderTextBlock([this.text = '']);
}

/// A thinking block inside the assembled message.
class ProviderThinkingBlock {
  /// The thinking.
  String thinking = '';

  /// The thinkingSignature.
  String thinkingSignature = '';

  /// True for Anthropic's redacted reasoning: the text is a placeholder and
  /// the provider's opaque data rides in [thinkingSignature].
  bool redacted = false;

  /// Creates a ProviderThinkingBlock.
  ProviderThinkingBlock([this.thinking = '', this.thinkingSignature = '']);
}

/// A failure thrown mid-stream by a parser, mirroring the upstream `throw`
/// the provider API's outer catch converts into the terminal `error` event.
/// [message] is the diagnostic that lands in `errorMessage`.
class ProviderStreamException implements Exception {
  /// The message.
  final String message;

  /// Creates a ProviderStreamException.
  ProviderStreamException(this.message);
  @override
  String toString() => message;
}

/// Drives [frames] through [feed] and finishes with [end], converting a
/// thrown [ProviderStreamException] into the canonical terminal `error`
/// outcome the provider APIs' outer catch produces. Returns every event.
///
/// [onException] receives the exception's message and returns the terminal
/// error event; parsers differ in the stop reason an abort maps to, so the
/// caller supplies it.
List<ProviderStreamEvent> driveProviderStream({
  required List<ProviderStreamEvent> Function() feed,
  required List<ProviderStreamEvent> Function() end,
  required ProviderErrorEvent Function(String message) onException,
}) {
  final events = <ProviderStreamEvent>[];
  try {
    events.addAll(feed());
    events.addAll(end());
  } on ProviderStreamException catch (error) {
    events.add(onException(error.message));
  }
  return events;
}

Object _blockToJson(Object block) {
  if (block is ProviderTextBlock) {
    return {'type': 'text', 'text': block.text};
  }
  if (block is ProviderThinkingBlock) {
    return {
      'type': 'thinking',
      'thinking': block.thinking,
      // An unset signature is absent from the canonical form on both sides
      // (Google leaves it null until a thought signature is retained;
      // Anthropic starts it empty).
      if (block.thinkingSignature.isNotEmpty)
        'thinkingSignature': block.thinkingSignature,
      if (block.redacted) 'redacted': true,
    };
  }
  if (block is ProviderToolCall) return block.toJson();
  throw ArgumentError('unknown content block: $block');
}

/// Index of [block] in [state]'s content (always the last pushed block when
/// called right after a push).
int contentIndexOf(ProviderMessageState state, Object block) =>
    state.content.indexOf(block);

/// The argument stream of the tool call at [index], or null.
ToolCallArgumentsStream? argumentsStreamOf(
        Map<Object, ToolCallArgumentsStream> streams, Object key) =>
    streams[key];
