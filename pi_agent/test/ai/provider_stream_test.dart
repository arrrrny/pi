// Tests for the provider streaming parsers ported from upstream
// `packages/ai/src/api/*` (parity work in arrrrny/pi#41): Anthropic Messages,
// OpenAI-compatible chat completions, Google Generative AI, and Mistral
// conversations. Fixtures are sanitized scripted payloads in the shape the
// upstream contracts define; no live provider call is involved.
import 'dart:convert';

import 'package:test/test.dart';

import 'package:pi/src/ai/anthropic_stream.dart';
import 'package:pi/src/ai/google_stream.dart';
import 'package:pi/src/ai/mistral_stream.dart';
import 'package:pi/src/ai/openai_stream.dart';
import 'package:pi/src/ai/provider_events.dart';
import 'package:pi/src/ai/sse_decoder.dart';

/// Decode SSE `frames` (raw text blocks separated by a blank line) through
/// the real decoder, feed each to the parser, and finish it. A thrown
/// [ProviderStreamException] becomes the terminal `error` event, exactly
/// like the upstream API's outer catch.
List<ProviderStreamEvent> driveAnthropic(
  AnthropicStreamParser parser,
  List<String> frames,
) {
  final events = <ProviderStreamEvent>[];
  final decoder = SseDecoder();
  try {
    for (final frame in frames) {
      for (final sse in decoder.push(utf8.encode(frame))) {
        events.addAll(parser.feed(sse));
      }
    }
    for (final sse in decoder.end()) {
      events.addAll(parser.feed(sse));
    }
    events.addAll(parser.end());
  } on ProviderStreamException catch (error) {
    parser.message.stopReason = 'error';
    parser.message.errorMessage = error.message;
    events.add(ProviderErrorEvent('error', error.message));
  }
  return events;
}

/// Feed decoded `chunks` through a chunk parser and finish it, converting a
/// thrown [ProviderStreamException] into the terminal `error` event.
List<ProviderStreamEvent> driveChunks(
  OpenAiStreamParser parser,
  List<Object> chunks,
) =>
    _drive(parser.message, chunks, parser.feedChunk, parser.end);

/// Same drive shape for the Google parser.
List<ProviderStreamEvent> driveGoogle(
  GoogleStreamParser parser,
  List<Object> chunks,
) =>
    _drive(parser.message, chunks, parser.feedChunk, parser.end);

/// Same drive shape for the Mistral parser.
List<ProviderStreamEvent> driveMistral(
  MistralStreamParser parser,
  List<Object> chunks,
) =>
    _drive(parser.message, chunks, parser.feedChunk, parser.end);

List<ProviderStreamEvent> _drive(
  ProviderMessageState message,
  List<Object> chunks,
  List<ProviderStreamEvent> Function(Map<String, dynamic>) feed,
  List<ProviderStreamEvent> Function() end,
) {
  final events = <ProviderStreamEvent>[];
  try {
    for (final chunk in chunks) {
      events.addAll(feed(chunk as Map<String, dynamic>));
    }
    events.addAll(end());
  } on ProviderStreamException catch (error) {
    message.stopReason = 'error';
    message.errorMessage = error.message;
    events.add(ProviderErrorEvent('error', error.message));
  }
  return events;
}

List<String> anthropicFrame(String event, Object data) =>
    ['event: $event\ndata: ${jsonEncode(data)}\n\n'];

Matcher errorMessage(Object matcher) => isA<ProviderErrorEvent>()
    .having((e) => e.errorMessage, 'errorMessage', matcher);

void main() {
  group('AnthropicStreamParser', () {
    test('happy path: text, thinking, tool call, usage, stop', () {
      final parser = AnthropicStreamParser();
      final events = driveAnthropic(
        parser,
        [
          ...anthropicFrame('message_start', {
            'type': 'message_start',
            'message': {
              'id': 'msg_1',
              'model': 'claude-x',
              'usage': {
                'input_tokens': 12,
                'output_tokens': 1,
                'cache_read_input_tokens': 3,
                'cache_creation_input_tokens': 4,
              },
            },
          }),
          ...anthropicFrame('content_block_start', {
            'type': 'content_block_start',
            'index': 0,
            'content_block': {'type': 'text', 'text': ''},
          }),
          ...anthropicFrame('content_block_delta', {
            'type': 'content_block_delta',
            'index': 0,
            'delta': {'type': 'text_delta', 'text': 'Hello'},
          }),
          ...anthropicFrame('content_block_delta', {
            'type': 'content_block_delta',
            'index': 0,
            'delta': {'type': 'text_delta', 'text': ' world'},
          }),
          ...anthropicFrame('content_block_stop', {
            'type': 'content_block_stop',
            'index': 0,
          }),
          ...anthropicFrame('content_block_start', {
            'type': 'content_block_start',
            'index': 1,
            'content_block': {
              'type': 'thinking',
              'thinking': '',
              'signature': ''
            },
          }),
          ...anthropicFrame('content_block_delta', {
            'type': 'content_block_delta',
            'index': 1,
            'delta': {'type': 'thinking_delta', 'thinking': 'hmm'},
          }),
          ...anthropicFrame('content_block_delta', {
            'type': 'content_block_delta',
            'index': 1,
            'delta': {'type': 'signature_delta', 'signature': 'sig9'},
          }),
          ...anthropicFrame('content_block_stop', {
            'type': 'content_block_stop',
            'index': 1,
          }),
          ...anthropicFrame('content_block_start', {
            'type': 'content_block_start',
            'index': 2,
            'content_block': {
              'type': 'tool_use',
              'id': 'toolu_1',
              'name': 'shell',
              'input': {},
            },
          }),
          ...anthropicFrame('content_block_delta', {
            'type': 'content_block_delta',
            'index': 2,
            'delta': {'type': 'input_json_delta', 'partial_json': '{"comm'},
          }),
          ...anthropicFrame('content_block_delta', {
            'type': 'content_block_delta',
            'index': 2,
            'delta': {
              'type': 'input_json_delta',
              'partial_json': 'and": "ls"}'
            },
          }),
          ...anthropicFrame('content_block_stop', {
            'type': 'content_block_stop',
            'index': 2,
          }),
          ...anthropicFrame('message_delta', {
            'type': 'message_delta',
            'delta': {'stop_reason': 'tool_use'},
            'usage': {'output_tokens': 7},
          }),
          ...anthropicFrame('message_stop', {'type': 'message_stop'}),
        ],
      );

      expect(events.map((e) => e.type).toList(), [
        'start',
        'text_start',
        'text_delta',
        'text_delta',
        'text_end',
        'thinking_start',
        'thinking_delta',
        'thinking_end',
        'toolcall_start',
        'toolcall_delta',
        'toolcall_delta',
        'toolcall_end',
        'done',
      ]);
      final message = parser.message;
      expect(message.responseId, 'msg_1');
      expect(message.stopReason, 'toolUse');
      expect(message.rawStopReason, 'tool_use');
      expect(message.usage.input, 12);
      expect(message.usage.output, 7);
      expect(message.usage.cacheRead, 3);
      expect(message.usage.cacheWrite, 4);
      expect(message.usage.totalTokens, 12 + 7 + 3 + 4);
      final toolCall = message.content.whereType<ProviderToolCall>().single;
      expect(toolCall.arguments, {'command': 'ls'});
      expect(toolCall.argumentsError, isNull);
      final thinking =
          message.content.whereType<ProviderThinkingBlock>().single;
      expect(thinking.thinking, 'hmm');
      expect(thinking.thinkingSignature, 'sig9');
    });

    test('usage merge preserves message_start input when delta omits it', () {
      final parser = AnthropicStreamParser();
      final events = driveAnthropic(
        parser,
        [
          ...anthropicFrame('message_start', {
            'type': 'message_start',
            'message': {
              'id': 'msg_2',
              'usage': {'input_tokens': 100, 'output_tokens': 1},
            },
          }),
          ...anthropicFrame('message_delta', {
            'type': 'message_delta',
            'delta': {'stop_reason': 'end_turn'},
            'usage': {'output_tokens': 5, 'input_tokens': null},
          }),
          ...anthropicFrame('message_stop', {'type': 'message_stop'}),
        ],
      );
      expect(events.last.type, 'done');
      expect(parser.message.usage.input, 100);
      expect(parser.message.usage.output, 5);
      expect(parser.message.stopReason, 'stop');
    });

    test('refusal maps to error with the explanation', () {
      final parser = AnthropicStreamParser();
      final events = driveAnthropic(
        parser,
        [
          ...anthropicFrame('message_start', {
            'type': 'message_start',
            'message': {
              'id': 'm',
              'usage': {'input_tokens': 1, 'output_tokens': 1},
            },
          }),
          ...anthropicFrame('message_delta', {
            'type': 'message_delta',
            'delta': {
              'stop_reason': 'refusal',
              'stop_details': {'explanation': 'No thanks'},
            },
          }),
          ...anthropicFrame('message_stop', {'type': 'message_stop'}),
        ],
      );
      expect(events.last, errorMessage('No thanks'));
      expect(parser.message.stopReason, 'error');
      expect(parser.message.errorMessage, 'No thanks');
    });

    test('error SSE event surfaces the data as the diagnostic', () {
      final parser = AnthropicStreamParser();
      final events = driveAnthropic(parser, [
        'event: error\ndata: overloaded\n\n',
      ]);
      expect(events, [errorMessage('overloaded')]);
      expect(parser.message.stopReason, 'error');
    });

    test('malformed event JSON throws with diagnostics', () {
      final parser = AnthropicStreamParser();
      final events = driveAnthropic(parser, [
        'event: content_block_delta\ndata: {broken\n\n',
      ]);
      expect(
        events,
        [
          errorMessage(contains(
              'Could not parse Anthropic SSE event content_block_delta'))
        ],
      );
    });

    test('stream ending before message_stop throws', () {
      final parser = AnthropicStreamParser();
      final events = driveAnthropic(parser, [
        ...anthropicFrame('message_start', {
          'type': 'message_start',
          'message': {
            'id': 'm',
            'usage': {'input_tokens': 1, 'output_tokens': 1},
          },
        }),
      ]);
      expect(events.last,
          errorMessage('Anthropic stream ended before message_stop'));
    });

    test('stream ending without a stop reason throws', () {
      final parser = AnthropicStreamParser();
      final events = driveAnthropic(parser, [
        ...anthropicFrame('message_start', {
          'type': 'message_start',
          'message': {
            'id': 'm',
            'usage': {'input_tokens': 1, 'output_tokens': 1},
          },
        }),
        ...anthropicFrame('message_stop', {'type': 'message_stop'}),
      ]);
      expect(events.last,
          errorMessage('Anthropic stream ended without a stop reason'));
    });

    test('unknown stop reason throws', () {
      final parser = AnthropicStreamParser();
      final events = driveAnthropic(parser, [
        ...anthropicFrame('message_start', {
          'type': 'message_start',
          'message': {
            'id': 'm',
            'usage': {'input_tokens': 1, 'output_tokens': 1},
          },
        }),
        ...anthropicFrame('message_delta', {
          'type': 'message_delta',
          'delta': {'stop_reason': 'martian_landing'},
        }),
        ...anthropicFrame('message_stop', {'type': 'message_stop'}),
      ]);
      expect(
          events.last, errorMessage('Unhandled stop reason: martian_landing'));
    });

    test('unknown SSE event names are skipped', () {
      final parser = AnthropicStreamParser();
      final events = driveAnthropic(
        parser,
        [
          'event: ping\ndata: {"type":"ping"}\n\n',
          'event: totally_new\ndata: {"type":"totally_new"}\n\n',
          ...anthropicFrame('message_start', {
            'type': 'message_start',
            'message': {
              'id': 'm',
              'usage': {'input_tokens': 1, 'output_tokens': 1},
            },
          }),
          ...anthropicFrame('message_delta', {
            'type': 'message_delta',
            'delta': {'stop_reason': 'end_turn'},
          }),
          ...anthropicFrame('message_stop', {'type': 'message_stop'}),
        ],
      );
      expect(events.map((e) => e.type), ['start', 'done']);
    });

    test('redacted thinking becomes a placeholder thinking block', () {
      final parser = AnthropicStreamParser();
      final events = driveAnthropic(
        parser,
        [
          ...anthropicFrame('message_start', {
            'type': 'message_start',
            'message': {
              'id': 'm',
              'usage': {'input_tokens': 1, 'output_tokens': 1},
            },
          }),
          ...anthropicFrame('content_block_start', {
            'type': 'content_block_start',
            'index': 0,
            'content_block': {'type': 'redacted_thinking', 'data': 'opaque'},
          }),
          ...anthropicFrame('content_block_stop', {
            'type': 'content_block_stop',
            'index': 0,
          }),
          ...anthropicFrame('message_delta', {
            'type': 'message_delta',
            'delta': {'stop_reason': 'end_turn'},
          }),
          ...anthropicFrame('message_stop', {'type': 'message_stop'}),
        ],
      );
      final thinking =
          parser.message.content.whereType<ProviderThinkingBlock>().single;
      expect(thinking.redacted, isTrue);
      expect(thinking.thinkingSignature, 'opaque');
      expect(events.whereType<ThinkingEnd>().single.content,
          '[Reasoning redacted]');
    });

    test('malformed tool arguments are reported, never silently emptied', () {
      final parser = AnthropicStreamParser();
      driveAnthropic(
        parser,
        [
          ...anthropicFrame('message_start', {
            'type': 'message_start',
            'message': {
              'id': 'm',
              'usage': {'input_tokens': 1, 'output_tokens': 1},
            },
          }),
          ...anthropicFrame('content_block_start', {
            'type': 'content_block_start',
            'index': 0,
            'content_block': {
              'type': 'tool_use',
              'id': 't',
              'name': 'shell',
              'input': {},
            },
          }),
          ...anthropicFrame('content_block_delta', {
            'type': 'content_block_delta',
            'index': 0,
            'delta': {
              'type': 'input_json_delta',
              'partial_json': '{"command": "ls",,'
            },
          }),
          ...anthropicFrame('content_block_stop', {
            'type': 'content_block_stop',
            'index': 0,
          }),
          ...anthropicFrame('message_delta', {
            'type': 'message_delta',
            'delta': {'stop_reason': 'tool_use'},
          }),
          ...anthropicFrame('message_stop', {'type': 'message_stop'}),
        ],
      );
      final toolCall =
          parser.message.content.whereType<ProviderToolCall>().single;
      // Upstream preserves the failure as argumentsError (#3 fix parity).
      expect(toolCall.argumentsError, isNotNull);
      expect(toolCall.argumentsError, contains('Received arguments:'));
    });
  });

  group('OpenAiStreamParser', () {
    test('happy path: text, tool calls by index, usage, finish', () {
      final parser = OpenAiStreamParser(requestedModelId: 'gpt-x');
      final events = driveChunks(
        parser,
        [
          {
            'id': 'chatcmpl-1',
            'model': 'gpt-x',
            'choices': [
              {
                'index': 0,
                'delta': {'role': 'assistant', 'content': 'Hi'}
              }
            ],
          },
          {
            'id': 'chatcmpl-1',
            'model': 'gpt-x',
            'choices': [
              {
                'index': 0,
                'delta': {
                  'tool_calls': [
                    {
                      'index': 0,
                      'id': 'call_1',
                      'function': {'name': 'shell', 'arguments': '{"comm'},
                    }
                  ],
                },
              }
            ],
          },
          {
            'id': 'chatcmpl-1',
            'model': 'gpt-x',
            'choices': [
              {
                'index': 0,
                'delta': {
                  'tool_calls': [
                    {
                      'index': 0,
                      'function': {'arguments': 'and": "ls"}'},
                    }
                  ],
                },
              }
            ],
          },
          {
            'id': 'chatcmpl-1',
            'model': 'gpt-x',
            'choices': [
              {'index': 0, 'delta': {}, 'finish_reason': 'tool_calls'}
            ],
            'usage': {
              'prompt_tokens': 20,
              'completion_tokens': 8,
              'prompt_tokens_details': {'cached_tokens': 4},
              'completion_tokens_details': {'reasoning_tokens': 2},
            },
          },
        ],
      );

      // Open blocks close in content order at the end of the stream.
      expect(events.map((e) => e.type).toList(), [
        'text_start',
        'text_delta',
        'toolcall_start',
        'toolcall_delta',
        'toolcall_delta',
        'text_end',
        'toolcall_end',
        'done',
      ]);
      final message = parser.message;
      expect(message.responseId, 'chatcmpl-1');
      expect(message.stopReason, 'toolUse');
      expect(message.usage.input, 20 - 4);
      expect(message.usage.output, 8);
      expect(message.usage.cacheRead, 4);
      expect(message.usage.reasoning, 2);
      expect(message.usage.totalTokens, 16 + 8 + 4);
      final toolCall = message.content.whereType<ProviderToolCall>().single;
      expect(toolCall.id, 'call_1');
      expect(toolCall.name, 'shell');
      expect(toolCall.arguments, {'command': 'ls'});
    });

    test('reasoning_content precedes text as a thinking block', () {
      final parser = OpenAiStreamParser();
      final events = driveChunks(
        parser,
        [
          {
            'id': 'c',
            'choices': [
              {
                'index': 0,
                'delta': {'reasoning_content': 'think'},
              }
            ],
          },
          {
            'id': 'c',
            'choices': [
              {
                'index': 0,
                'delta': {'content': 'answer'},
              }
            ],
          },
          {
            'id': 'c',
            'choices': [
              {'index': 0, 'delta': {}, 'finish_reason': 'stop'}
            ],
          },
        ],
      );
      expect(events.map((e) => e.type).toList(), [
        'thinking_start',
        'thinking_delta',
        'text_start',
        'text_delta',
        'thinking_end',
        'text_end',
        'done',
      ]);
      expect(parser.message.content.first, isA<ProviderThinkingBlock>());
    });

    test('unknown finish_reason maps to error with the raw reason', () {
      final parser = OpenAiStreamParser();
      final events = driveChunks(parser, [
        {
          'id': 'c',
          'choices': [
            {'index': 0, 'delta': {}, 'finish_reason': 'content_filter'}
          ],
        },
      ]);
      expect(
          events.last, errorMessage('Provider finish_reason: content_filter'));
    });

    test('stream without finish_reason derives stop from content', () {
      final parser = OpenAiStreamParser();
      final events = driveChunks(parser, [
        {
          'id': 'c',
          'choices': [
            {
              'index': 0,
              'delta': {'content': 'hey'}
            }
          ],
        },
      ]);
      expect(events.last.type, 'done');
      expect(parser.message.stopReason, 'stop');
    });

    test('tool-call-only stream without finish_reason derives toolUse', () {
      final parser = OpenAiStreamParser();
      final events = driveChunks(parser, [
        {
          'id': 'c',
          'choices': [
            {
              'index': 0,
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'id': 't',
                    'function': {'name': 'x', 'arguments': '{}'},
                  }
                ],
              },
            }
          ],
        },
      ]);
      expect(events.last.type, 'done');
      expect(parser.message.stopReason, 'toolUse');
    });

    test('supportsFinishReason fails a stream without finish_reason', () {
      final parser = OpenAiStreamParser(supportsFinishReason: true);
      final events = driveChunks(parser, [
        {
          'id': 'c',
          'choices': [
            {
              'index': 0,
              'delta': {'content': 'hey'}
            }
          ],
        },
      ]);
      expect(events.last, errorMessage('Stream ended without finish_reason'));
    });

    test('Moonshot choice.usage fallback parses usage', () {
      final parser = OpenAiStreamParser();
      driveChunks(parser, [
        {
          'id': 'c',
          'choices': [
            {
              'index': 0,
              'delta': {},
              'finish_reason': 'stop',
              'usage': {
                'prompt_tokens': 5,
                'completion_tokens': 3,
              },
            }
          ],
        },
      ]);
      expect(parser.message.usage.input, 5);
      expect(parser.message.usage.output, 3);
      expect(parser.message.usage.totalTokens, 8);
    });

    test('DeepSeek prompt_cache_hit_tokens counts as cache read', () {
      final usage = parseOpenAiChunkUsage({
        'prompt_tokens': 10,
        'completion_tokens': 5,
        'prompt_cache_hit_tokens': 6,
      });
      expect(usage.input, 4);
      expect(usage.cacheRead, 6);
    });

    test('malformed streamed tool arguments are preserved as an error', () {
      final parser = OpenAiStreamParser();
      driveChunks(parser, [
        {
          'id': 'c',
          'choices': [
            {
              'index': 0,
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'id': 't',
                    'function': {'name': 'x', 'arguments': '{oops'},
                  }
                ],
              },
            }
          ],
        },
        {
          'id': 'c',
          'choices': [
            {'index': 0, 'delta': {}, 'finish_reason': 'tool_calls'}
          ],
        },
      ]);
      final toolCall =
          parser.message.content.whereType<ProviderToolCall>().single;
      expect(toolCall.argumentsError, isNotNull);
    });
  });

  group('GoogleStreamParser', () {
    test('text/thought switching, function call, usage, finish', () {
      final parser = GoogleStreamParser(requestedModelId: 'gemini-x');
      final events = driveGoogle(
        parser,
        [
          {
            'responseId': 'r1',
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Thinking out'},
                    {'text': ' loud', 'thought': true},
                  ]
                }
              }
            ],
          },
          {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Visible answer'},
                    {
                      'functionCall': {
                        'name': 'shell',
                        'args': {'command': 'ls'}
                      },
                    },
                  ]
                },
                'finishReason': 'STOP',
              }
            ],
            'usageMetadata': {
              'promptTokenCount': 10,
              'candidatesTokenCount': 5,
              'cachedContentTokenCount': 2,
              'thoughtsTokenCount': 3,
              'totalTokenCount': 18,
            },
          },
        ],
      );

      // Google switches blocks as part types change and closes the open
      // block before a function call part starts.
      expect(events.map((e) => e.type).toList(), [
        'text_start',
        'text_delta',
        'text_end',
        'thinking_start',
        'thinking_delta',
        'thinking_end',
        'text_start',
        'text_delta',
        'text_end',
        'toolcall_start',
        'toolcall_delta',
        'toolcall_end',
        'done',
      ]);
      final message = parser.message;
      expect(message.responseId, 'r1');
      expect(message.stopReason, 'toolUse');
      // input = prompt - cached; output = candidates + thoughts.
      expect(message.usage.input, 8);
      expect(message.usage.output, 8);
      expect(message.usage.cacheRead, 2);
      expect(message.usage.reasoning, 3);
      expect(message.usage.totalTokens, 18);
      final toolCall = message.content.whereType<ProviderToolCall>().single;
      expect(toolCall.name, 'shell');
      expect(toolCall.arguments, {'command': 'ls'});
      expect(toolCall.id, isNotEmpty);
    });

    test('duplicate function call ids get fresh ids', () {
      final parser = GoogleStreamParser();
      driveGoogle(parser, [
        {
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'functionCall': {'name': 'a', 'id': 'dup', 'args': {}},
                  }
                ]
              }
            }
          ]
        },
        {
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'functionCall': {'name': 'a', 'id': 'dup', 'args': {}},
                  }
                ]
              }
            }
          ]
        },
      ]);
      final calls =
          parser.message.content.whereType<ProviderToolCall>().toList();
      expect(calls.length, 2);
      expect(calls[0].id, 'dup');
      expect(calls[1].id, isNot('dup'));
    });

    test('safety finish reason maps to error', () {
      final parser = GoogleStreamParser();
      final events = driveGoogle(parser, [
        {
          'candidates': [
            {
              'content': {'parts': []},
              'finishReason': 'SAFETY',
            }
          ]
        },
      ]);
      expect(events.last, errorMessage('Provider stopped with: SAFETY'));
    });

    test('no finish reason reports the chunk count', () {
      final parser = GoogleStreamParser();
      final events = driveGoogle(parser, [
        {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'hi'},
                ]
              }
            }
          ]
        },
      ]);
      expect(
        events.last,
        errorMessage(
            'Google stream ended without a finish reason after receiving 1 chunk'),
      );
    });

    test('prompt block feedback surfaces the block error', () {
      final parser = GoogleStreamParser();
      final events = driveGoogle(parser, [
        {
          'promptFeedback': {'blockReason': 'SAFETY'},
        },
      ]);
      expect(events.last, errorMessage('Google prompt blocked: SAFETY'));
    });
  });

  group('MistralStreamParser', () {
    test('text, thinking items, tool calls, usage, finish', () {
      final parser = MistralStreamParser();
      final events = driveMistral(
        parser,
        [
          {
            'id': 'm1',
            'choices': [
              {
                'index': 0,
                'delta': {'content': 'Hello'},
              }
            ],
          },
          {
            'id': 'm1',
            'choices': [
              {
                'index': 0,
                'delta': {
                  'content': [
                    {
                      'type': 'thinking',
                      'thinking': [
                        {'text': 'why'},
                      ],
                    },
                  ],
                },
              }
            ],
          },
          {
            'id': 'm1',
            'choices': [
              {
                'index': 0,
                'delta': {
                  'tool_calls': [
                    {
                      'index': 0,
                      'id': 'call_1',
                      'function': {'name': 'shell', 'arguments': '{"command"'},
                    }
                  ],
                },
              }
            ],
          },
          {
            'id': 'm1',
            'choices': [
              {
                'index': 0,
                'delta': {
                  'tool_calls': [
                    {
                      'index': 0,
                      'function': {'arguments': ': "ls"}'},
                    }
                  ],
                },
              }
            ],
          },
          {
            'id': 'm1',
            'choices': [
              {'index': 0, 'delta': {}, 'finish_reason': 'tool_calls'}
            ],
            'usage': {
              'prompt_tokens': 30,
              'completion_tokens': 6,
              'prompt_tokens_details': {'cached_tokens': 10},
              'total_tokens': 26,
            },
          },
        ],
      );

      expect(events.map((e) => e.type).toList(), [
        'text_start',
        'text_delta',
        'text_end',
        'thinking_start',
        'thinking_delta',
        'thinking_end',
        'toolcall_start',
        'toolcall_delta',
        'toolcall_delta',
        'toolcall_end',
        'done',
      ]);
      final message = parser.message;
      expect(message.responseId, 'm1');
      expect(message.stopReason, 'toolUse');
      expect(message.usage.input, 20);
      expect(message.usage.cacheRead, 10);
      expect(message.usage.totalTokens, 26);
      final toolCall = message.content.whereType<ProviderToolCall>().single;
      expect(toolCall.arguments, {'command': 'ls'});
    });

    test('empty text deltas do not split thinking blocks', () {
      final parser = MistralStreamParser();
      driveMistral(parser, [
        {
          'id': 'm',
          'choices': [
            {
              'index': 0,
              'delta': {
                'content': [
                  {
                    'type': 'thinking',
                    'thinking': [
                      {'text': 'one'},
                    ],
                  },
                ],
              },
            }
          ],
        },
        {
          'id': 'm',
          'choices': [
            {
              'index': 0,
              'delta': {'content': ''},
            }
          ],
        },
        {
          'id': 'm',
          'choices': [
            {
              'index': 0,
              'delta': {
                'content': [
                  {
                    'type': 'thinking',
                    'thinking': [
                      {'text': 'two'},
                    ],
                  },
                ],
              },
            }
          ],
        },
        {
          'id': 'm',
          'choices': [
            {'index': 0, 'delta': {}, 'finish_reason': 'stop'}
          ],
        },
      ]);
      final thinking =
          parser.message.content.whereType<ProviderThinkingBlock>().toList();
      expect(thinking.length, 1);
      expect(thinking.single.thinking, 'onetwo');
    });

    test('unknown finish reason maps to Provider stopped with', () {
      final parser = MistralStreamParser();
      final events = driveMistral(parser, [
        {
          'id': 'm',
          'choices': [
            {'index': 0, 'delta': {}, 'finish_reason': 'error'}
          ],
        },
      ]);
      expect(events.last, errorMessage('Provider stopped with: error'));
    });

    test('invalid chunk shape throws', () {
      final parser = MistralStreamParser();
      final events = driveMistral(parser, [
        {'nope': true},
      ]);
      expect(events.last, errorMessage('Invalid Mistral streaming event'));
    });

    test('stream without finish reason throws', () {
      final parser = MistralStreamParser();
      final events = driveMistral(parser, [
        {
          'id': 'm',
          'choices': [
            {
              'index': 0,
              'delta': {'content': 'x'},
            }
          ],
        },
      ]);
      expect(events.last,
          errorMessage('Mistral stream ended without a finish reason'));
    });
  });

  /// Cross-provider handoff (PI-PAR-003 acceptance criterion): an equivalent
  /// tool-call stream delivered by each provider's own wire format assembles
  /// the SAME canonical tool call, so the agent loop's tool-result path is
  /// provider-independent.
  group('cross-provider handoff', () {
    test(
        'all four parsers yield the same canonical toolCall for an equivalent stream',
        () {
      final canonicalCalls = <Map<String, dynamic>>[];

      final anthropic = AnthropicStreamParser();
      driveAnthropic(anthropic, [
        ...anthropicFrame('message_start', {
          'type': 'message_start',
          'message': {
            'id': 'm',
            'usage': {'input_tokens': 1, 'output_tokens': 1},
          },
        }),
        ...anthropicFrame('content_block_start', {
          'type': 'content_block_start',
          'index': 0,
          'content_block': {
            'type': 'tool_use',
            'id': 'call_1',
            'name': 'shell',
            'input': {},
          },
        }),
        ...anthropicFrame('content_block_delta', {
          'type': 'content_block_delta',
          'index': 0,
          'delta': {
            'type': 'input_json_delta',
            'partial_json': '{"command": "ls -la", "cwd": "/tmp"}'
          },
        }),
        ...anthropicFrame(
            'content_block_stop', {'type': 'content_block_stop', 'index': 0}),
        ...anthropicFrame('message_delta', {
          'type': 'message_delta',
          'delta': {'stop_reason': 'tool_use'},
        }),
        ...anthropicFrame('message_stop', {'type': 'message_stop'}),
      ]);
      canonicalCalls.add(anthropic.message.content
          .whereType<ProviderToolCall>()
          .single
          .toJson());

      final openai = OpenAiStreamParser();
      driveChunks(openai, [
        {
          'id': 'c',
          'choices': [
            {
              'index': 0,
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'id': 'call_1',
                    'function': {
                      'name': 'shell',
                      'arguments': '{"command": "ls -la", '
                    },
                  }
                ],
              },
            }
          ],
        },
        {
          'id': 'c',
          'choices': [
            {
              'index': 0,
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'function': {'arguments': '"cwd": "/tmp"}'},
                  }
                ],
              },
            }
          ],
        },
        {
          'id': 'c',
          'choices': [
            {'index': 0, 'delta': {}, 'finish_reason': 'tool_calls'}
          ],
        },
      ]);
      canonicalCalls.add(
          openai.message.content.whereType<ProviderToolCall>().single.toJson());

      final google = GoogleStreamParser();
      driveGoogle(google, [
        {
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'functionCall': {
                      'name': 'shell',
                      'id': 'call_1',
                      'args': {'command': 'ls -la', 'cwd': '/tmp'},
                    },
                  }
                ]
              },
              'finishReason': 'STOP',
            }
          ]
        },
      ]);
      canonicalCalls.add(
          google.message.content.whereType<ProviderToolCall>().single.toJson());

      final mistral = MistralStreamParser();
      driveMistral(mistral, [
        {
          'id': 'm',
          'choices': [
            {
              'index': 0,
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'id': 'call_1',
                    'function': {
                      'name': 'shell',
                      'arguments': '{"command": "ls -la", "cwd": "/tmp"}'
                    },
                  }
                ],
              },
            }
          ],
        },
        {
          'id': 'm',
          'choices': [
            {'index': 0, 'delta': {}, 'finish_reason': 'tool_calls'}
          ],
        },
      ]);
      canonicalCalls.add(mistral.message.content
          .whereType<ProviderToolCall>()
          .single
          .toJson());

      expect(
        canonicalCalls
            .every((c) => c['id'] == 'call_1' && c['name'] == 'shell'),
        isTrue,
      );
      expect(
        canonicalCalls.map(json.encode).toSet().length,
        1,
        reason: 'all providers assemble the same arguments: $canonicalCalls',
      );
      // Every provider reports toolUse, so the loop takes the tool path.
      expect(anthropic.message.stopReason, 'toolUse');
      expect(openai.message.stopReason, 'toolUse');
      expect(google.message.stopReason, 'toolUse');
      expect(mistral.message.stopReason, 'toolUse');
    });
  });
}
