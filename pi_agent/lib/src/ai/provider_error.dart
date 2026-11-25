// Shared normalization for provider HTTP error objects.
//
// Port of `packages/ai/src/utils/error-body.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b`. Endpoints behind a proxy or
// gateway may return a non-2xx response whose body the provider SDK cannot
// fold into the error message. This module probes the known SDK field shapes
// (Mistral, `openai`, `@google/genai`, AWS Bedrock) and returns the struct
// each provider composes into its display string. `messageCarriesBody`
// captures the happy path where the message already contains the body, so
// providers can preserve it without double-printing.

import 'dart:convert';

/// Maximum provider error text kept in a diagnostic
/// (`MAX_PROVIDER_ERROR_BODY_CHARS`).
const int maxProviderErrorBodyChars = 4000;

/// The normalized provider error: status, body, message, and whether the
/// message already contains the body.
class NormalizedProviderError {
  /// HTTP status code, when one could be extracted.
  final int? status;

  /// Raw HTTP body reason, already trimmed and truncated to the cap.
  final String? body;

  /// The error message.
  final String message;

  /// True when [message] already contains the body (no separate body to add).
  final bool messageCarriesBody;

  /// The NormalizedProviderError.
  const NormalizedProviderError({
    this.status,
    this.body,
    required this.message,
    required this.messageCarriesBody,
  });
}

/// The SDK error shapes `normalizeProviderError` probes, given as the plain
/// map a thrown error object exposes in Dart. Recognized fields:
/// `message`, `statusCode` (Mistral), `status` (`openai`, `@google/genai`),
/// `$metadata.httpStatusCode` (Bedrock), `$response.statusCode` /
/// `$response.body` (Bedrock), `body` (Mistral raw body string), and
/// `error` (the `openai` SDK's parsed body object).
NormalizedProviderError normalizeProviderError(Object? error) {
  if (error is! Map) {
    return NormalizedProviderError(
      message: error == null ? 'null' : safeJsonStringify(error),
      messageCarriesBody: false,
    );
  }
  final sdkError = Map<String, dynamic>.from(error);
  final status = _extractStatus(sdkError);
  final body = _extractBody(sdkError);
  final messageText = sdkError['message'];
  final message = messageText is String && messageText.isNotEmpty
      ? messageText
      : safeJsonStringify(error);
  final messageCarriesBody = body == null || message.contains(body);
  return NormalizedProviderError(
    status: status,
    body: body,
    message: message,
    messageCarriesBody: messageCarriesBody,
  );
}

/// Probe the HTTP status, first numeric hit wins, in SDK-field order:
/// `statusCode` (Mistral) → `status` (`openai`, `@google/genai`) →
/// `$metadata.httpStatusCode` (Bedrock) → `$response.statusCode` (Bedrock).
int? _extractStatus(Map<String, dynamic> error) {
  final statusCode = error['statusCode'];
  if (statusCode is num) return statusCode.toInt();
  final status = error['status'];
  if (status is num) return status.toInt();
  final metadata = error[r'$metadata'];
  if (metadata is Map) {
    final httpStatusCode =
        Map<String, dynamic>.from(metadata)['httpStatusCode'];
    if (httpStatusCode is num) return httpStatusCode.toInt();
  }
  final response = error[r'$response'];
  if (response is Map) {
    final responseMap = Map<String, dynamic>.from(response);
    final statusCode = responseMap['statusCode'];
    if (statusCode is num) return statusCode.toInt();
  }
  return null;
}

/// Probe the raw body reason, first usable hit wins, in SDK-field order:
/// `body` string (Mistral) → `error` parsed JSON body object (`openai`
/// SDK's `this.error`) → `$response.body` (Bedrock). Empty objects and
/// unread response streams are treated as no body so they do not surface as
/// `"{}"` or serialized stream internals. The chosen body is truncated to
/// the cap.
String? _extractBody(Map<String, dynamic> error) {
  final bodyText = _pickBodyText(error);
  if (bodyText == null) return null;
  final trimmed = bodyText.trim();
  if (trimmed.isEmpty) return null;
  return truncateErrorText(trimmed, maxProviderErrorBodyChars);
}

String? _pickBodyText(Map<String, dynamic> error) {
  final body = error['body'];
  if (body is String) return body;
  if (_isPlainNonEmptyObject(error['error'])) {
    return safeJsonStringify(error['error']);
  }
  final response = error[r'$response'];
  if (response is Map) {
    final responseBody = Map<String, dynamic>.from(response)['body'];
    if (responseBody is String) return responseBody;
    if (_isReadableStreamLike(responseBody)) return null;
    if (_isPlainNonEmptyObject(responseBody)) {
      return safeJsonStringify(responseBody);
    }
  }
  return null;
}

/// A stream-like value (a `pipe` function is the JS tell) is never a body.
/// In Dart the same tell is a `Stream` instance.
bool _isReadableStreamLike(Object? value) => value is Stream;

/// Only a PLAIN object counts as an HTTP body. SDK error fields can hold
/// class instances instead of parsed bodies, and stringifying one produced
/// garbage as the "body", which then REPLACED the real message. In Dart the
/// shape check is: a Map that is not a typed wrapper — maps are plain by
/// construction here, so the check is emptiness.
bool _isPlainNonEmptyObject(Object? value) {
  if (value is! Map) return false;
  return value.isNotEmpty;
}

/// Compose a display string from a normalized error. When the message
/// already carries the body or no body/status was extracted, the message is
/// returned unchanged. Otherwise the status and body are surfaced, with an
/// optional provider prefix.
///
/// - no prefix: `"<status>: <body>"`
/// - prefix:    `"<prefix> (<status>): <body>"`
String formatProviderError(NormalizedProviderError norm, {String? prefix}) {
  if (norm.messageCarriesBody || norm.status == null || norm.body == null) {
    if (prefix != null && norm.status != null) {
      return '$prefix (${norm.status}): ${norm.message}';
    }
    return norm.message;
  }
  return prefix != null
      ? '$prefix (${norm.status}): ${norm.body}'
      : '${norm.status}: ${norm.body}';
}

/// Caps provider error text so a persisted diagnostic never carries a huge
/// proxy error page (`truncateErrorText` upstream).
String truncateErrorText(String text, int maxChars) {
  if (text.length <= maxChars) return text;
  final kept = text.substring(0, maxChars);
  return '$kept... [truncated ${text.length - maxChars} chars]';
}

/// JSON-stringify that never throws and never emits `"undefined"`.
String safeJsonStringify(Object? value) {
  try {
    return jsonEncode(value);
  } catch (_) {
    return value.toString();
  }
}
