// Tests for the provider error, retry, identity, and event-stream ports
// from upstream `packages/ai/src/utils/` (parity work in arrrrny/pi#41).
import 'dart:async';

import 'package:test/test.dart';

import 'package:pi/src/ai/provider_error.dart';
import 'package:pi/src/ai/provider_event_stream.dart';
import 'package:pi/src/ai/provider_events.dart';
import 'package:pi/src/ai/provider_identity.dart';
import 'package:pi/src/ai/provider_retry.dart';

void main() {
  group('normalizeProviderError', () {
    test('status wins from the Mistral shape first', () {
      final norm = normalizeProviderError({
        'message': 'boom',
        'statusCode': 429,
        'status': 500,
      });
      expect(norm.status, 429);
    });

    test('status from the openai/genai shape', () {
      final norm = normalizeProviderError({'message': 'boom', 'status': 401});
      expect(norm.status, 401);
    });

    test('status from the Bedrock metadata shape', () {
      final norm = normalizeProviderError({
        'message': 'boom',
        r'$metadata': {'httpStatusCode': 429},
      });
      expect(norm.status, 429);
    });

    test('openai parsed body object becomes the body text', () {
      final norm = normalizeProviderError({
        'message': '403 status code (no body)',
        'error': {'message': 'forbidden by policy'},
      });
      expect(norm.body, '{"message":"forbidden by policy"}');
      expect(norm.messageCarriesBody, isFalse);
      expect(
        formatProviderError(norm),
        '403 status code (no body)',
      );
    });

    test('body already inside the message is not double-printed', () {
      final bodyText = 'quota exceeded for project';
      final norm = normalizeProviderError({
        'message': 'the request failed: $bodyText',
        'body': bodyText,
      });
      expect(norm.messageCarriesBody, isTrue);
      expect(formatProviderError(norm),
          'the request failed: quota exceeded for project');
    });

    test('format with prefix composes status and body', () {
      final norm = normalizeProviderError({
        'message': 'ignored',
        'status': 429,
        'body': 'slow down',
      });
      expect(formatProviderError(norm), '429: slow down');
      expect(formatProviderError(norm, prefix: 'OpenAI'),
          'OpenAI (429): slow down');
    });

    test('format with prefix interpolates it when the body is in the message',
        () {
      // Regression: the `\$prefix` escape rendered a literal `$prefix` on the
      // branch where the message already carries the body (parity with
      // upstream `error-body.ts`).
      const norm = NormalizedProviderError(
        message: 'the request failed: slow down',
        status: 429,
        body: 'slow down',
        messageCarriesBody: true,
      );
      expect(formatProviderError(norm, prefix: 'OpenAI'),
          'OpenAI (429): the request failed: slow down');
    });

    test('large proxy bodies are truncated to the cap', () {
      final bodyText = 'x' * 5000;
      final norm = normalizeProviderError({
        'message': 'bad gateway',
        'body': bodyText,
      });
      expect(norm.body!.length, lessThan(5000));
      expect(norm.body, contains('[truncated 1000 chars]'));
    });

    test('a non-map throw stringifies', () {
      final norm = normalizeProviderError('plain failure');
      expect(norm.message, '"plain failure"');
    });
  });

  group('retryAssistantCall', () {
    test('disabled policy returns the first response', () async {
      var calls = 0;
      final outcome = await retryAssistantCall(
        () async {
          calls++;
          return const RetryAssistantOutcome('error', 'overloaded');
        },
        const RetryPolicy(enabled: false, maxRetries: 3, baseDelayMs: 1),
        null,
        null,
        (_) async {},
      );
      expect(calls, 1);
      expect(outcome.stopReason, 'error');
    });

    test('retries a transient error then succeeds', () async {
      var calls = 0;
      final scheduled = <int>[];
      final outcome = await retryAssistantCall(
        () async {
          calls++;
          return calls == 1
              ? const RetryAssistantOutcome(
                  'error', 'provider returned an error')
              : const RetryAssistantOutcome('stop');
        },
        const RetryPolicy(enabled: true, maxRetries: 3, baseDelayMs: 100),
        null,
        RetryCallbacks(onRetryScheduled: (a, m, d, e) => scheduled.add(d)),
        (_) async {},
      );
      expect(calls, 2);
      expect(outcome.stopReason, 'stop');
      expect(scheduled, [100]);
    });

    test('backoff doubles and caps at maxAgentDelayMs', () {
      final policy = RetryPolicy(
        enabled: true,
        maxRetries: 10,
        baseDelayMs: 1000,
        maxAgentDelayMs: 5000,
      );
      expect(retryDelayMs(policy, 1), 1000);
      expect(retryDelayMs(policy, 2), 2000);
      expect(retryDelayMs(policy, 3), 4000);
      expect(retryDelayMs(policy, 4), 5000);
      expect(retryDelayMs(policy, 9), 5000);
    });

    test('non-retryable quota errors fail fast', () async {
      var calls = 0;
      final outcome = await retryAssistantCall(
        () async {
          calls++;
          return const RetryAssistantOutcome('error', 'insufficient_quota');
        },
        const RetryPolicy(enabled: true, maxRetries: 5, baseDelayMs: 1),
        null,
        null,
        (_) async {},
      );
      expect(calls, 1);
      expect(outcome.stopReason, 'error');
    });

    test('aborted outcomes are terminal', () async {
      var calls = 0;
      final outcome = await retryAssistantCall(
        () async {
          calls++;
          return const RetryAssistantOutcome('aborted');
        },
        const RetryPolicy(enabled: true, maxRetries: 5, baseDelayMs: 1),
        null,
        null,
        (_) async {},
      );
      expect(calls, 1);
      expect(outcome.stopReason, 'aborted');
    });

    test('abort during backoff yields an aborted outcome', () async {
      final signal = Completer<void>();
      final outcome = await retryAssistantCall(
        () async => const RetryAssistantOutcome('error', 'overloaded'),
        const RetryPolicy(enabled: true, maxRetries: 3, baseDelayMs: 5),
        signal,
        null,
        (ms) async {
          signal.complete();
          await Future<void>.delayed(const Duration(milliseconds: 1));
        },
      );
      expect(outcome.stopReason, 'aborted');
    });

    test('retry budget exhaustion returns the last error', () async {
      var calls = 0;
      var finished = <Object?>[];
      final outcome = await retryAssistantCall(
        () async {
          calls++;
          return RetryAssistantOutcome('error', 'connection refused');
        },
        const RetryPolicy(enabled: true, maxRetries: 2, baseDelayMs: 1),
        null,
        RetryCallbacks(
          onRetryFinished: (success, attempt, finalError) =>
              finished = [success, attempt, finalError],
        ),
        (_) async {},
      );
      // 1 initial + 2 retries.
      expect(calls, 3);
      expect(outcome.stopReason, 'error');
      expect(finished, [false, 2, 'connection refused']);
    });
  });

  group('isRetryableAssistantError', () {
    test('classification across the fleet-critical vocabulary', () {
      bool retryable(String message) =>
          isRetryableAssistantError(RetryAssistantOutcome('error', message));
      expect(retryable('429: too many requests'), isTrue);
      expect(retryable('503 Service Unavailable'), isTrue);
      expect(retryable('Connection error.'), isTrue);
      expect(retryable('read ECONNRESET'), isTrue);
      expect(retryable('Anthropic stream ended before message_stop'), isTrue);
      expect(retryable('Provider finish_reason: error'), isTrue);
      expect(retryable('insufficient_quota: out of budget'), isFalse);
      expect(retryable('GoUsageLimitError'), isFalse);
      expect(retryable('unauthorized: bad api key'), isFalse);
      expect(
        isRetryableAssistantError(const RetryAssistantOutcome('stop')),
        isFalse,
      );
    });
  });

  group('client identity', () {
    test('detailed user agent renders version, platform, runtime, arch', () {
      expect(
        formatUserAgent(
          null,
          platform: 'darwin',
          runtime: 'node/v22.0.0',
          arch: 'arm64',
        ),
        'pi/$piAiVersion (darwin; node/v22.0.0; arm64)',
      );
    });

    test('short mode is just pi', () {
      expect(formatUserAgent(const ClientIdentity(userAgent: 'short')), 'pi');
    });

    test('an object mode renders its custom value', () {
      expect(
        formatUserAgent(
            const ClientIdentity(userAgent: {'custom': 'my-agent/1'})),
        'my-agent/1',
      );
    });

    test('an unknown string mode falls through to detailed', () {
      expect(
        formatUserAgent(
          const ClientIdentity(userAgent: 'my-agent/1', version: '2.0.0'),
          platform: 'darwin',
          runtime: 'node/v22.0.0',
          arch: 'arm64',
        ),
        'pi/2.0.0 (darwin; node/v22.0.0; arm64)',
      );
    });

    test('openrouter attribution headers include categories', () {
      final headers = getAttributionHeaders(
        const ClientIdentityTarget(
            provider: 'openrouter', baseUrl: 'https://openrouter.ai/api'),
        const ClientIdentity(
          attribution: ClientAttribution(
            name: 'pi',
            url: 'https://pi.dev',
            categories: ['cli-agent'],
          ),
        ),
      );
      expect(headers, {
        'HTTP-Referer': 'https://pi.dev',
        'X-OpenRouter-Title': 'pi',
        'X-OpenRouter-Categories': 'cli-agent',
      });
    });

    test('nvidia attribution capitalizes the origin', () {
      final headers = getAttributionHeaders(
        const ClientIdentityTarget(
            provider: 'nvidia', baseUrl: 'https://integrate.api.nvidia.com'),
        const ClientIdentity(
          attribution: ClientAttribution(name: 'pi', url: 'https://pi.dev'),
        ),
      );
      expect(headers, {'X-BILLING-INVOKE-ORIGIN': 'Pi'});
    });

    test('opencode attribution uses the client header', () {
      final headers = getAttributionHeaders(
        const ClientIdentityTarget(
            provider: 'opencode', baseUrl: 'https://opencode.ai'),
        const ClientIdentity(
          attribution: ClientAttribution(name: 'pi', url: 'https://pi.dev'),
        ),
      );
      expect(headers, {'x-opencode-client': 'pi'});
    });

    test('openCode session header rides only opencode targets', () {
      expect(
        getOpenCodeSessionHeaders(
          const ClientIdentityTarget(
              provider: 'opencode', baseUrl: 'https://opencode.ai'),
          'sess-1',
        ),
        {'x-opencode-session': 'sess-1'},
      );
      expect(
        getOpenCodeSessionHeaders(
          const ClientIdentityTarget(
              provider: 'openai', baseUrl: 'https://api.openai.com/v1'),
          'sess-1',
        ),
        isNull,
      );
    });

    test('merge prefers later fields, skips absent ones', () {
      final merged = mergeClientIdentity([
        const ClientIdentity(version: '9', userAgent: 'short'),
        const ClientIdentity(
            attribution: ClientAttribution(name: 'a', url: 'u')),
      ]);
      expect(merged!.version, '9');
      expect(merged.userAgent, 'short');
      expect(merged.attribution!.name, 'a');
    });

    test('identity headers combine user agent and attribution', () {
      final headers = getIdentityHeaders(
        const ClientIdentityTarget(
            provider: 'anthropic', baseUrl: 'https://api.anthropic.com'),
        null,
        platform: 'darwin',
        runtime: 'node/v22.0.0',
        arch: 'arm64',
      );
      expect(headers['User-Agent'],
          'pi/$piAiVersion (darwin; node/v22.0.0; arm64)');
      // No attribution by default.
      expect(headers.length, 1);
    });
  });

  group('AssistantMessageEventStream', () {
    test('push/end iterate in order and resolve the final result', () async {
      final stream = createAssistantMessageEventStream();
      final start = ProviderStart();
      stream.push(ProviderStreamEnvelope(start, ProviderMessageState()));
      final message = ProviderMessageState()..stopReason = 'stop';
      stream.push(ProviderStreamEnvelope(ProviderDone('stop'), message));

      final collected = <String>[];
      await for (final envelope in stream.stream()) {
        collected.add(envelope.event.type);
      }
      expect(collected, ['start', 'done']);
      final result = await stream.result();
      expect(result.stopReason, 'stop');
      expect(result.durationMs, isNotNull);
    });

    test('an error event resolves the result and times the message', () async {
      final stream = createAssistantMessageEventStream();
      final message = ProviderMessageState()
        ..stopReason = 'error'
        ..errorMessage = 'boom';
      stream.push(
          ProviderStreamEnvelope(ProviderErrorEvent('error', 'boom'), message));
      final result = await stream.result();
      expect(result.errorMessage, 'boom');
      expect(result.durationMs, isNotNull);
    });

    test('events pushed after end are dropped', () async {
      final stream = createAssistantMessageEventStream();
      final message = ProviderMessageState();
      stream.end(message);
      stream.push(
          ProviderStreamEnvelope(ProviderStart(), ProviderMessageState()));
      final collected = await stream.stream().toList();
      expect(collected, isEmpty);
      expect(await stream.result(), same(message));
    });
  });
}
