// Context-overflow classification for assistant messages.
//
// Faithful port of `packages/ai/src/utils/overflow.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b`. The behavioral change in this
// sync is #12438: the `request_too_large` error code must match only as a
// complete ASCII identifier, never inside a longer identifier such as
// `my_plugin_request_too_large_flag`. Upstream writes that as the lookbehind
// `(?<![a-z0-9_])request_too_large(?![a-z0-9_])`; Dart's RegExp has no
// lookbehind, so it is expressed as `(?:^|[^a-z0-9_])request_too_large(?![a-z0-9_])`,
// which is equivalent for `hasMatch` detection (the leading start-or-non-identifier
// alternative consumes one character but detection only needs a boolean).
//
// One deliberate deviation: Dart's `AssistantMessage` carries no `provider`
// field, so the Cerebras-only bodyless-400 branch takes the provider as an
// explicit optional argument rather than reading it off the message.

import '../types.dart';

/// Regex patterns that detect context-overflow errors across providers.
///
/// Ported verbatim from upstream `OVERFLOW_PATTERNS`, with the #12438
/// identifier-boundary change applied to the `request_too_large` pattern.
final List<RegExp> _overflowPatterns = <RegExp>[
  RegExp(r'prompt (?:is )?too long',
      caseSensitive: false), // Anthropic and z.ai
  RegExp(r'prompt exceeds max length',
      caseSensitive: false), // z.ai CN endpoint
  // Anthropic request byte-size error code, not a longer identifier (#12438).
  RegExp(r'(?:^|[^a-z0-9_])request_too_large(?![a-z0-9_])',
      caseSensitive: false),
  RegExp(r'input is too long for requested model',
      caseSensitive: false), // Amazon Bedrock
  RegExp(r'exceeds the context window', caseSensitive: false), // OpenAI
  RegExp(
    r"exceeds (?:the )?(?:model'?s )?maximum context length(?: of [\d,]+ tokens?|\s*\([\d,]+\))",
    caseSensitive: false,
  ), // OpenAI-compatible proxies (LiteLLM)
  RegExp(r'context window exceeded',
      caseSensitive: false), // LiteLLM pre-call check
  RegExp(r'input token count.*exceeds the maximum',
      caseSensitive: false), // Google
  RegExp(r'maximum prompt length is \d+', caseSensitive: false), // xAI (Grok)
  RegExp(r'reduce the length of the messages', caseSensitive: false), // Groq
  RegExp(r'maximum context length is \d+ tokens',
      caseSensitive: false), // OpenRouter
  RegExp(
    r'exceeds (?:the )?maximum allowed input length of [\d,]+ tokens?',
    caseSensitive: false,
  ), // OpenRouter/Poolside
  RegExp(
    r"input \(\d+ tokens\) is longer than the model'?s context length \(\d+ tokens\)",
    caseSensitive: false,
  ), // Together AI
  RegExp(r'exceeds the limit of \d+', caseSensitive: false), // GitHub Copilot
  RegExp(r'exceeds the available context size',
      caseSensitive: false), // llama.cpp
  RegExp(r'greater than the context length', caseSensitive: false), // LM Studio
  RegExp(r'context window exceeds limit', caseSensitive: false), // MiniMax
  RegExp(r'exceeded model token limit',
      caseSensitive: false), // Kimi For Coding
  RegExp(r'too large for model with \d+ maximum context length',
      caseSensitive: false), // Mistral
  RegExp(
    r'prompt has [\d,]+ tokens?, but the configured context size is [\d,]+ tokens?',
    caseSensitive: false,
  ), // DS4 server
  RegExp(r'model_context_window_exceeded',
      caseSensitive: false), // z.ai finish_reason
  RegExp(r'prompt too long; exceeded (?:max )?context length',
      caseSensitive: false), // Ollama
  RegExp(r'range of input length should be',
      caseSensitive: false), // DashScope / Qwen
  RegExp(r'context[_ ]length[_ ]exceeded',
      caseSensitive: false), // Generic fallback
  RegExp(r'too many tokens', caseSensitive: false), // Generic fallback
  RegExp(r'token limit exceeded', caseSensitive: false), // Generic fallback
  // HTTP 413 means request-size overflow regardless of provider or body text.
  RegExp(r'^(?:[\w -]+ API error \(413\):|413(?:\s|:|$))',
      caseSensitive: false),
];

/// A bodyless 400/413 status, known to indicate overflow only for Cerebras (#9482).
final RegExp _cerebrasBodylessOverflowPattern = RegExp(
    r'^4(?:00|13)\s*(?:status code)?\s*\(no body\)',
    caseSensitive: false);

/// Patterns that indicate non-overflow errors (rate limiting, server errors).
///
/// A message matching any of these is excluded from overflow detection even if
/// it also matches an [_overflowPatterns] entry (e.g. Bedrock's
/// "Throttling error: Too many tokens").
final List<RegExp> _nonOverflowPatterns = <RegExp>[
  RegExp(r'^(Throttling error|Service unavailable):', caseSensitive: false),
  RegExp(r'rate limit', caseSensitive: false),
  RegExp(r'too many requests', caseSensitive: false),
];

/// Returns a copy of the overflow patterns, for testing purposes.
List<RegExp> getOverflowPatterns() => List<RegExp>.of(_overflowPatterns);

/// Whether [message] represents a context-overflow error.
///
/// Handles three cases, matching upstream:
/// 1. Error-based overflow: `stopReason` error with a recognizable message.
/// 2. Silent overflow (z.ai style): a successful response whose input plus
///    cache-read tokens exceed [contextWindow].
/// 3. Length-stop overflow (Xiaomi MiMo style): a `maxTokens` stop with zero
///    output whose input plus cache-read tokens fill the context window.
///
/// [provider] is the provider id, used only to attribute a bodyless 400/413 to
/// Cerebras; Dart's [AssistantMessage] does not carry it.
bool isContextOverflow(AssistantMessage message,
    [int? contextWindow, String? provider]) {
  final errorMessage = message.errorMessage;
  if (message.stopReason == StopReason.error && errorMessage != null) {
    final isNonOverflow =
        _nonOverflowPatterns.any((p) => p.hasMatch(errorMessage));
    if (!isNonOverflow) {
      if (_overflowPatterns.any((p) => p.hasMatch(errorMessage))) return true;
      if (provider == 'cerebras' &&
          _cerebrasBodylessOverflowPattern.hasMatch(errorMessage)) {
        return true;
      }
    }
  }

  final usage = message.usage;
  if (contextWindow != null && usage != null) {
    final inputTokens = usage.inputTokens + (usage.cacheReadInputTokens ?? 0);

    // Case 2: silent overflow (z.ai style) on a successful stop.
    if (message.stopReason == StopReason.endTurn &&
        inputTokens > contextWindow) {
      return true;
    }

    // Case 3: length-stop overflow (Xiaomi MiMo style).
    if (message.stopReason == StopReason.maxTokens &&
        usage.outputTokens == 0 &&
        inputTokens >= contextWindow * 0.99) {
      return true;
    }
  }

  return false;
}

/// Whether a length stop ended below the caller or model's intended output limit.
///
/// Such responses may be caused by context pressure or provider-side
/// truncation, so callers can make one bounded compact-and-retry attempt.
/// [desiredMaxOutput] must be the original limit before any context-based
/// clamping.
bool isRecoverableLength(AssistantMessage message, int desiredMaxOutput) {
  final usage = message.usage;
  return message.stopReason == StopReason.maxTokens &&
      desiredMaxOutput > 0 &&
      usage != null &&
      usage.outputTokens < desiredMaxOutput;
}
