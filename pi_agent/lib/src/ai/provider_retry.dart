// Bounded retry on transient provider errors.
//
// Port of `packages/ai/src/utils/retry.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b`: the retry policy (bounded
// attempts with exponential backoff), the delay computation, the transient /
// non-retryable error classification, and the `retryAssistantCall` loop with
// its scheduling callbacks. Abort classification: the canonical `"aborted"`
// stop reason (an aborted stream or an aborted backoff) is terminal and
// never retried.

import 'dart:async';

/// Retry policy: bounded attempts with exponential backoff
/// (`baseDelayMs * 2^(attempt-1)`), each capped at `maxAgentDelayMs`
/// (default 60 seconds).
class RetryPolicy {
  /// The enabled.
  final bool enabled;

  /// Max retry attempts (0 = no retries). The initial call never counts as a
  /// retry.
  final int maxRetries;

  /// Base delay in ms. Per-attempt delay is `baseDelayMs * 2^(attempt-1)`
  /// before the cap.
  final int baseDelayMs;

  /// Cap for retry delays in ms; null uses the default.
  final int? maxAgentDelayMs;

  /// The RetryPolicy.
  const RetryPolicy({
    required this.enabled,
    required this.maxRetries,
    required this.baseDelayMs,
    this.maxAgentDelayMs,
  });
}

/// The default agent-level retry-delay cap.
const int defaultMaxAgentRetryDelayMs = 60000;

/// The delay for retry attempt [attempt] (1-indexed).
int retryDelayMs(RetryPolicy policy, int attempt) {
  final exponent = attempt > 1 ? attempt - 1 : 0;
  final delay = policy.baseDelayMs * _pow2(exponent);
  return delay
      .clamp(0, policy.maxAgentDelayMs ?? defaultMaxAgentRetryDelayMs)
      .toInt();
}

/// `2^n` for the retry backoff, saturated so a large exponent cannot overflow
/// into a negative delay.
int _pow2(int exponent) {
  var value = 1;
  for (var i = 0; i < exponent; i++) {
    final next = value * 2;
    if (next < value) break; // overflow: stay at the saturated value
    value = next;
  }
  return value;
}

/// Callbacks emitted around each retry.
class RetryCallbacks {
  /// Emitted before the backoff sleep of each retry attempt (1-indexed).
  final void Function(
          int attempt, int maxAttempts, int delayMs, String errorMessage)?
      onRetryScheduled;

  /// Emitted after the backoff sleep, immediately before the retried call.
  final void Function()? onRetryAttemptStart;

  /// Emitted once when the loop ends: success if a later call completed
  /// normally.
  final void Function(bool success, int attempt, String? finalError)?
      onRetryFinished;

  /// The RetryCallbacks.
  const RetryCallbacks({
    this.onRetryScheduled,
    this.onRetryAttemptStart,
    this.onRetryFinished,
  });
}

/// The assistant-message outcome shape the retry loop consumes: canonical
/// stop reason plus the diagnostic.
class RetryAssistantOutcome {
  /// The stopReason.
  final String stopReason;

  /// The errorMessage.
  final String? errorMessage;

  /// Creates a const RetryAssistantOutcome.
  const RetryAssistantOutcome(this.stopReason, [this.errorMessage]);
}

/// The abort signal shape the sleep listens to: completing the completer
/// aborts a pending backoff.
typedef AbortSignal = Completer<void>?;

/// Run a single assistant-producing call with bounded retry on transient
/// errors.
///
/// - A successful response is returned immediately. Aborts are terminal and
///   never retried, but reported as unsuccessful if they happen after a
///   retry was scheduled. Aborts during the backoff sleep are normalized to
///   an aborted outcome too, so callers do not care when cancellation
///   happened.
/// - A non-retryable error (per [isRetryableAssistantError], including
///   quota/billing exhaustion) is returned immediately so deterministic
///   errors fail fast.
/// - Otherwise retries up to `maxRetries` times with exponential backoff,
///   emitting [RetryCallbacks.onRetryScheduled] before each sleep,
///   [RetryCallbacks.onRetryAttemptStart] after it, and
///   [RetryCallbacks.onRetryFinished] once at the end.
///
/// When [policy] is null or disabled, the first response is returned
/// unchanged.
///
/// [sleep] injects the backoff wait so tests and the differential harness
/// drive a virtual clock.
Future<RetryAssistantOutcome> retryAssistantCall(
  Future<RetryAssistantOutcome> Function() produce,
  RetryPolicy? policy,
  AbortSignal signal, [
  RetryCallbacks? callbacks,
  Future<void> Function(int ms)? sleep,
]) async {
  Future<void> wait(int ms) async {
    if (sleep != null) {
      await sleep(ms);
      if (signal?.isCompleted ?? false) {
        throw _RetrySleepAbort();
      }
      return;
    }
    await Future<void>.delayed(Duration(milliseconds: ms));
    if (signal?.isCompleted ?? false) throw _RetrySleepAbort();
  }

  final maxAttempts = policy?.enabled ?? false ? policy!.maxRetries : 0;

  var attempt = 0;
  ({int attempt, String errorMessage})? lastRetry;
  while (true) {
    final response = await produce();

    // Abort: terminal but not successful. Never retry an aborted message.
    if (response.stopReason == 'aborted') {
      if (lastRetry != null) {
        callbacks?.onRetryFinished?.call(false, lastRetry.attempt, null);
      }
      return response;
    }

    // Success: non-error, non-abort responses return as-is.
    if (response.stopReason != 'error') {
      if (lastRetry != null) {
        callbacks?.onRetryFinished?.call(true, lastRetry.attempt, null);
      }
      return response;
    }

    // Non-retryable, or budget exhausted: return the final error message.
    if (attempt >= maxAttempts || !isRetryableAssistantError(response)) {
      if (lastRetry != null) {
        callbacks?.onRetryFinished
            ?.call(false, lastRetry.attempt, response.errorMessage);
      }
      return response;
    }

    attempt++;
    lastRetry = (
      attempt: attempt,
      errorMessage: response.errorMessage ?? 'Unknown error'
    );
    final delayMs = retryDelayMs(policy!, attempt);
    callbacks?.onRetryScheduled
        ?.call(attempt, maxAttempts, delayMs, lastRetry.errorMessage);

    // Normalize aborts during retry backoff to the same aborted outcome
    // shape as provider stream aborts.
    try {
      await wait(delayMs);
    } on _RetrySleepAbort {
      callbacks?.onRetryFinished?.call(false, attempt, lastRetry.errorMessage);
      return RetryAssistantOutcome('aborted');
    }
    callbacks?.onRetryAttemptStart?.call();
  }
}

class _RetrySleepAbort implements Exception {}

final RegExp _nonRetryableProviderLimitError = RegExp(
  r'GoUsageLimitError|FreeUsageLimitError|'
  r'Monthly usage limit reached|available balance|'
  // Generic quota/budget/billing exhaustion.
  r'insufficient_quota|out of budget|quota exceeded|billing|'
  r'subscription_sharing_usage_limit_exceeded|'
  r'subscription_sharing_workplace_individual_usage_limit_exceeded|'
  // Zhipu/Z.ai error code 1308: the plan's usage limit is reached, sent as
  // HTTP 429. It resets after hours, not seconds.
  r'"code"\s*:\s*"?1308(?![0-9])',
  caseSensitive: false,
);

final RegExp _retryableProviderError = RegExp(
  r'overloaded|server_busy|servers are currently busy|'
  r'currently experiencing high demand|model is at capacity|'
  r'admission ceiling|'
  r'rate.?limit|too many requests|rate increased too quickly|'
  // Status codes must not be part of a longer word or number, e.g. a request
  // id or byte count. 520, 524 and 525 are Cloudflare's.
  r'(?<![a-z0-9])(?:429|500|502|503|504|520|524|525)(?![a-z0-9])|'
  r'service.?(?:is.?)?(?:temporarily.?)?unavailable|'
  r'provider.?(?:is.?)?temporarily.?unavailable|'
  r'server.?error|internal.?error|'
  r'provider.?returned.?(?:an.?)?error|'
  r'"type"\s*:\s*"api_error"|'
  r'exceeded request buffer limit while retrying upstream|'
  r'unable to forward upstream|'
  r'upstream.?request.?failed|upstream_stream_read_error|'
  r'stream was interrupted|http/?2 stream failed|'
  r'network.?error|connection.?error|connection.?refused|connection.?lost|'
  r'connection.?closed|other side closed|fetch failed|'
  r'request to \S+ failed, reason:|getaddrinfo|'
  r'(?<![a-z0-9_])(?:ECONNRESET|ECONNABORTED|ECONNREFUSED|ETIMEDOUT|EPIPE)(?![a-z0-9_])|'
  r'connection reset by peer|ENOTFOUND|EAI_AGAIN|upstream.?connect|'
  r'reset before headers|socket hang up|socket connection was closed|'
  r'timed? out|timeout|terminated|'
  r'websocket.?closed|websocket.?error|websocket.?connection.?limit.?reached|'
  // Premature stream endings from SDKs and transports.
  r'ended without|stream ended before message_stop|'
  r'stream ended before a terminal response event|'
  r'http2 request did not get a response|'
  r'provider finish_reason: error|provider stopped with: error|'
  r'returned an empty response|stopped before completing the response|'
  r'stream disconnected before completion|cut short after the reply had begun|'
  r'ended the response before it was complete|'
  r'connection to the provider was reset|'
  r'reported a failure while generating the response|'
  r'pending stream has been canceled|'
  r'retry delay|'
  r'you can retry your request|try your request again|'
  r'please retry your request|repeat the request later|'
  r'ResourceExhausted|'
  r'subscription_sharing_usage_unavailable|'
  r'subscription_sharing_user_unavailable',
  caseSensitive: false,
);

/// Classifies whether a failed assistant message looks like a transient
/// provider or transport error, so callers can decide if the last assistant
/// turn should be restarted.
///
/// This does not implement retry policy. Callers handle context overflow
/// separately, then apply their own retry budget, backoff, and reporting
/// before restarting the assistant turn.
bool isRetryableAssistantError(RetryAssistantOutcome message) {
  if (message.stopReason != 'error') return false;
  final errorMessage = message.errorMessage;
  if (errorMessage == null || errorMessage.isEmpty) return false;
  if (_nonRetryableProviderLimitError.hasMatch(errorMessage)) return false;
  return _retryableProviderError.hasMatch(errorMessage);
}
