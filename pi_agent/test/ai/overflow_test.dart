// Context-overflow classification for assistant messages.
//
// Port of `packages/ai/src/utils/overflow.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b` (`isContextOverflow`,
// `isRecoverableLength`, `getOverflowPatterns`). The headline behavioral change
// in this sync is #12438: `request_too_large` must match only as a complete
// ASCII identifier, never inside a longer identifier. Dart's RegExp has no
// lookbehind, so the upstream `(?<![a-z0-9_])request_too_large(?![a-z0-9_])`
// is ported as `(?:^|[^a-z0-9_])request_too_large(?![a-z0-9_])`, which is
// equivalent for `.hasMatch` detection.

import 'package:pi/ai.dart';
import 'package:test/test.dart';

AssistantMessage _errorMessage(String errorMessage) => AssistantMessage(
      content: const [],
      stopReason: StopReason.error,
      errorMessage: errorMessage,
      usage: const Usage(inputTokens: 0, outputTokens: 0),
    );

AssistantMessage _lengthStop({
  required int input,
  required int cacheRead,
  required int output,
}) =>
    AssistantMessage(
      content: const [],
      stopReason: StopReason.maxTokens,
      usage: Usage(
        inputTokens: input,
        outputTokens: output,
        cacheReadInputTokens: cacheRead,
      ),
    );

void main() {
  group('isContextOverflow', () {
    // The 413 pattern is provider-agnostic, so a Copilot-prefixed string and a
    // non-Copilot string cover both branches; the bare forms cover raw SDK output.
    for (final errorMessage in <String>[
      'github-copilot API error (413): {"message":"failed to parse request","code":""}',
      'custom-provider API error (413): Payload Too Large',
      '413 {"error":{"message":"failed to parse request","code":""}}',
      '413: {"code":"plugin_request_too_large","message":"request too large"}',
      '413',
    ]) {
      test('detects provider-independent request-size overflow: $errorMessage',
          () {
        expect(isContextOverflow(_errorMessage(errorMessage), 1000000), isTrue);
        expect(isContextOverflow(_errorMessage(errorMessage)), isTrue);
      });
    }

    // Regression for #12343: request_too_large is a complete error code.
    for (final errorMessage in <String>[
      'request_too_large',
      '400 {"error":{"type":"request_too_large","message":"Request exceeds the maximum size"}}',
      'Anthropic error: REQUEST_TOO_LARGE',
    ]) {
      test('detects a complete request-size error code: $errorMessage', () {
        expect(isContextOverflow(_errorMessage(errorMessage)), isTrue);
      });
    }

    // Regression for #12343: never match inside a longer identifier.
    for (final errorMessage in <String>[
      '400 {"code":"plugin_request_too_large","message":"plugin input rejected"}',
      '400 invalid_request_error: my_plugin_request_too_large_flag was set',
      'Unknown error code xrequest_too_large',
      'Unknown error code request_too_large2',
      'Unknown error code request_too_large_flag',
    ]) {
      test(
          'does not match request-size codes inside longer identifiers: $errorMessage',
          () {
        expect(isContextOverflow(_errorMessage(errorMessage), 200000), isFalse);
      });
    }

    for (final errorMessage in <String>[
      'github-copilot API error (400): {"message":"failed to parse request","code":""}',
      'custom-provider API error (429): Too many requests',
      'github-copilot API error (400): {"message":"failed to parse request: invalid value 413"}',
      'custom-provider API error (400): upstream mentioned OpenAI API error (413): invalid input',
      'custom-provider API error (4130): invalid input',
      '4130 failed to parse request',
    ]) {
      test('does not mistake unrelated errors for overflow: $errorMessage', () {
        expect(isContextOverflow(_errorMessage(errorMessage)), isFalse);
      });
    }

    test('limits HTTP-status matching to failed responses', () {
      final message = _errorMessage(
        'OpenAI API error (413): {"message":"failed to parse request"}',
      );
      expect(
        isContextOverflow(
          AssistantMessage(
            content: const [],
            stopReason: StopReason.aborted,
            errorMessage: message.errorMessage,
            usage: message.usage,
          ),
        ),
        isFalse,
      );
      expect(
        isContextOverflow(
          AssistantMessage(
            content: const [],
            stopReason: StopReason.endTurn,
            errorMessage: message.errorMessage,
            usage: message.usage,
          ),
        ),
        isFalse,
      );
    });

    test('detects explicit Ollama prompt-too-long errors', () {
      expect(
        isContextOverflow(
          _errorMessage(
            '400 `prompt too long; exceeded max context length by 100918 tokens`',
          ),
          32768,
        ),
        isTrue,
      );
    });

    test('detects Together AI context length errors', () {
      expect(
        isContextOverflow(
          _errorMessage(
            "400 The input (516368 tokens) is longer than the model's context length (262144 tokens).",
          ),
          262144,
        ),
        isTrue,
      );
    });

    test(
        'detects OpenAI-compatible parenthesized maximum context length errors',
        () {
      expect(
        isContextOverflow(
          _errorMessage(
            "Error: 400 Input length (265330) exceeds model's maximum context length (262144).",
          ),
          262144,
        ),
        isTrue,
      );
    });

    test('detects DS4 configured context size errors with and without commas',
        () {
      expect(
        isContextOverflow(
          _errorMessage(
            '400 Prompt has 256468 tokens, but the configured context size is 256000 tokens',
          ),
          256000,
        ),
        isTrue,
      );
      expect(
        isContextOverflow(
          _errorMessage(
            'Prompt has 5,958,968 tokens, but the configured context size is 256,000 tokens',
          ),
          256000,
        ),
        isTrue,
      );
    });

    test('does not treat generic non-overflow Ollama errors as overflow', () {
      expect(
        isContextOverflow(
            _errorMessage('500 `model runner crashed unexpectedly`'), 32768),
        isFalse,
      );
    });

    test('only treats bodyless 400 errors as overflow for Cerebras', () {
      // Regression for #9482. Dart's AssistantMessage carries no provider, so the
      // caller passes it; without it the bodyless 400 is not attributed to Cerebras.
      const errorMessage = '400 status code (no body)';
      expect(
        isContextOverflow(_errorMessage(errorMessage), 131072, 'cerebras'),
        isTrue,
      );
      expect(
        isContextOverflow(_errorMessage(errorMessage), 1000000, 'opencode-go'),
        isFalse,
      );
    });

    test('does not treat Bedrock throttling "Too many tokens" as overflow', () {
      expect(
        isContextOverflow(
          _errorMessage(
            'Throttling error: Too many tokens, please wait before trying again.',
          ),
          200000,
        ),
        isFalse,
      );
    });

    test('does not treat Bedrock service unavailable as overflow', () {
      expect(
        isContextOverflow(
          _errorMessage(
              'Service unavailable: The service is temporarily unavailable.'),
          200000,
        ),
        isFalse,
      );
    });

    test('does not treat generic rate limit / 429 errors as overflow', () {
      expect(
        isContextOverflow(
          _errorMessage('Rate limit exceeded, please retry after 30 seconds.'),
          200000,
        ),
        isFalse,
      );
      expect(
        isContextOverflow(
          _errorMessage('Too many requests. Please slow down.'),
          200000,
        ),
        isFalse,
      );
    });

    test(
        'detects Xiaomi-style overflow (length stop, zero output, filled context)',
        () {
      final message = _lengthStop(input: 58, cacheRead: 1048512, output: 0);
      expect(isContextOverflow(message, 1048576), isTrue);
    });

    test('does not treat normal length stops with output as overflow', () {
      final message = _lengthStop(input: 1000, cacheRead: 0, output: 4096);
      expect(isContextOverflow(message, 200000), isFalse);
    });

    test(
        'does not treat zero-output length stops far below context as overflow',
        () {
      final message = _lengthStop(input: 100, cacheRead: 0, output: 0);
      expect(isContextOverflow(message, 200000), isFalse);
    });
  });

  group('isRecoverableLength', () {
    test('treats a length stop below the desired output limit as recoverable',
        () {
      final message = _lengthStop(input: 3, cacheRead: 253584, output: 16);
      expect(isRecoverableLength(message, 128000), isTrue);
    });

    test('does not recover a length stop that reached the desired output limit',
        () {
      final message = _lengthStop(input: 4062, cacheRead: 0, output: 1024);
      expect(isRecoverableLength(message, 1024), isFalse);
    });

    test(
        'treats zero-output length stops as recoverable without context metadata',
        () {
      final message = _lengthStop(input: 100, cacheRead: 0, output: 0);
      expect(isRecoverableLength(message, 128000), isTrue);
    });
  });

  group('getOverflowPatterns', () {
    test('returns a non-empty list of patterns', () {
      expect(getOverflowPatterns(), isNotEmpty);
    });
  });
}
