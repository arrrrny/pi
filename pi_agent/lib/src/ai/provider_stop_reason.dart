// Provider stop-reason maps.
//
// Port of the `mapStopReason` functions of the upstream provider APIs
// (`packages/ai/src/api/anthropic-messages.ts`, `openai-completions.ts`,
// `mistral-conversations.ts`, `google-shared.ts`) at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b`. Each maps the provider's own
// finish vocabulary onto the canonical stop reason, pairing an `"error"`
// outcome with the diagnostic that names what the provider actually said.

import 'provider_events.dart';

/// The mapped outcome: a canonical stop reason plus an optional diagnostic.
class MappedStopReason {
  /// The stopReason.
  final String stopReason;

  /// The errorMessage.
  final String? errorMessage;

  /// Creates a const MappedStopReason.
  const MappedStopReason(this.stopReason, [this.errorMessage]);
}

/// Anthropic Messages: `end_turn`/`pause_turn`/`stop_sequence` → stop,
/// `max_tokens` → length, `tool_use` → toolUse, `refusal` → error with the
/// stop-details explanation, `sensitive` → error. An unknown reason throws —
/// the API may add values, and silently calling one `stop` would be a lie.
MappedStopReason mapAnthropicStopReason(
  String reason, {
  String? refusalExplanation,
}) {
  switch (reason) {
    case 'end_turn':
      return const MappedStopReason('stop');
    case 'max_tokens':
      return const MappedStopReason('length');
    case 'tool_use':
      return const MappedStopReason('toolUse');
    case 'refusal':
      return MappedStopReason(
        'error',
        refusalExplanation ?? 'The model refused to complete the request',
      );
    // Stop is good enough -> resubmit.
    case 'pause_turn':
      return const MappedStopReason('stop');
    // We don't supply stop sequences, so this should never happen.
    case 'stop_sequence':
      return const MappedStopReason('stop');
    // Content flagged by safety filters.
    case 'sensitive':
      return const MappedStopReason(
          'error', 'Provider stopped with: sensitive');
    default:
      throw ProviderStreamException('Unhandled stop reason: $reason');
  }
}

/// OpenAI-compatible chat completions: `null`/`stop`/`end` → stop, `length`
/// → length, `function_call`/`tool_calls` → toolUse, `content_filter` /
/// `network_error` and anything unknown → error carrying the raw reason.
MappedStopReason mapOpenAiStopReason(String? reason) {
  if (reason == null) return const MappedStopReason('stop');
  switch (reason) {
    case 'stop' || 'end':
      return const MappedStopReason('stop');
    case 'length':
      return const MappedStopReason('length');
    case 'function_call' || 'tool_calls':
      return const MappedStopReason('toolUse');
    case 'content_filter':
      return const MappedStopReason(
          'error', 'Provider finish_reason: content_filter');
    case 'network_error':
      return const MappedStopReason(
          'error', 'Provider finish_reason: network_error');
    default:
      return MappedStopReason('error', 'Provider finish_reason: $reason');
  }
}

/// Mistral conversations: `null`/`stop` → stop, `length`/`model_length` →
/// length, `tool_calls` → toolUse, anything unknown → `Provider stopped
/// with: \<reason\>`.
MappedStopReason mapMistralStopReason(String? reason) {
  if (reason == null) return const MappedStopReason('stop');
  switch (reason) {
    case 'stop':
      return const MappedStopReason('stop');
    case 'length' || 'model_length':
      return const MappedStopReason('length');
    case 'tool_calls':
      return const MappedStopReason('toolUse');
    default:
      return MappedStopReason('error', 'Provider stopped with: $reason');
  }
}

/// Google Generative AI: `STOP` → stop, `MAX_TOKENS`/`CONTINUATION` → length,
/// every safety/blocking reason in the vocabulary → error, and an unknown
/// one → `Provider stopped with: \<reason\>`.
MappedStopReason mapGoogleStopReason(String reason) {
  switch (reason) {
    case 'STOP':
      return const MappedStopReason('stop');
    // Per-request token limit reached before generation completed; pi does
    // not resume with the continuation token.
    case 'MAX_TOKENS' || 'CONTINUATION':
      return const MappedStopReason('length');
    case 'BLOCKLIST' ||
          'PROHIBITED_CONTENT' ||
          'SPII' ||
          'SAFETY' ||
          'IMAGE_SAFETY' ||
          'IMAGE_PROHIBITED_CONTENT' ||
          'IMAGE_RECITATION' ||
          'IMAGE_OTHER' ||
          'RECITATION' ||
          'FINISH_REASON_UNSPECIFIED' ||
          'OTHER' ||
          'LANGUAGE' ||
          'MALFORMED_FUNCTION_CALL' ||
          'UNEXPECTED_TOOL_CALL' ||
          'TOO_MANY_TOOL_CALLS' ||
          'NO_IMAGE' ||
          'MISSING_THOUGHT_SIGNATURE' ||
          'MALFORMED_RESPONSE' ||
          'ESCALATION' ||
          'PUP_LIMITED_DISABLED' ||
          'MODEL_ARMOR':
      return const MappedStopReason('error');
    default:
      return MappedStopReason('error', 'Provider stopped with: $reason');
  }
}
