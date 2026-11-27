/// Message conversion utilities.
library;

import 'types.dart';

/// Provider-facing request context shared by the direct LLM client and the
/// proxy adapter.
///
/// Mirrors upstream `normalizeContext()` (packages/ai/src/utils/transcript.ts):
/// the system prompt and the active tools are folded into the transcript, so a
/// proxy-backed agent cannot silently run without its instructions or callable
/// tools — the gap the review found at proxy.dart:104-110.
class ProviderRequestContext {
  /// Creates a request context from converted messages and tool declarations.
  const ProviderRequestContext({
    required this.messages,
    required this.tools,
  });

  /// Converted messages with the system prompt prepended, when present.
  final List<Map<String, dynamic>> messages;

  /// Serialized declarations of the tools active in this context.
  final List<Map<String, dynamic>> tools;

  /// The wire shape the proxy's `context` field carries: a transcript whose
  /// leading system message also declares the active tools (`toolsAdded`,
  /// transcript.ts:11-33).
  Map<String, dynamic> toWire() {
    final messages = List<Map<String, dynamic>>.from(this.messages);
    if (tools.isNotEmpty) {
      final systemIndex = messages.indexWhere((m) => m['role'] == 'system');
      if (systemIndex >= 0) {
        messages[systemIndex] = <String, dynamic>{
          ...messages[systemIndex],
          'toolsAdded': tools,
        };
      } else {
        messages.insert(0, <String, dynamic>{
          'role': 'system',
          'content': '',
          'toolsAdded': tools,
        });
      }
    }
    return {'messages': messages};
  }
}

/// Folds an [AgentContext] into the provider-facing request shape.
///
/// Both `streamLLM` and `streamProxy` build their requests from this helper,
/// so the direct and proxy paths cannot drift apart (llm_client.dart:208-225).
Future<ProviderRequestContext> normalizeProviderContext(
  AgentContext context,
  Future<List<Map<String, dynamic>>> Function(List<AgentMessage>) convertToLlm,
) async {
  final messages = <Map<String, dynamic>>[
    if (context.systemPrompt.isNotEmpty)
      {'role': 'system', 'content': context.systemPrompt},
    ...(await convertToLlm(context.messages)),
  ];
  final tools = <Map<String, dynamic>>[
    for (final tool in context.tools ?? const <dynamic>[])
      tool.toApiFormat() as Map<String, dynamic>,
  ];
  return ProviderRequestContext(messages: messages, tools: tools);
}

/// Default message converter: filters agent messages to LLM-compatible format.
///
/// Converts UserMessage, AssistantMessage, and ToolResultMessage to
/// the map format expected by OpenAI-compatible and Anthropic APIs.
/// Custom message types are converted to text representations.
Future<List<Map<String, dynamic>>> convertToLlm(
    List<AgentMessage> messages) async {
  final result = <Map<String, dynamic>>[];

  for (final msg in messages) {
    switch (msg) {
      case UserMessage(:final content):
        final textParts =
            content.whereType<TextBlock>().map((b) => b.text).toList();
        final hasImages = content.any((b) => b is ImageBlock);
        if (hasImages) {
          final parts = <Map<String, dynamic>>[];
          for (final block in content) {
            if (block is TextBlock) {
              parts.add({'type': 'text', 'text': block.text});
            } else if (block is ImageBlock) {
              parts.add({
                'type': 'image_url',
                'image_url': {
                  'url': 'data:${block.mediaType};base64,${block.base64Data}'
                },
              });
            }
          }
          result.add({'role': 'user', 'content': parts});
        } else {
          result.add({'role': 'user', 'content': textParts.join()});
        }

      case AssistantMessage(:final content, :final toolCalls):
        if (toolCalls.isNotEmpty) {
          result.add({
            'role': 'assistant',
            'content': content.whereType<TextBlock>().map((b) => b.text).join(),
            'tool_calls': toolCalls
                .map((tc) => {
                      'id': tc.id,
                      'type': 'function',
                      'function': {
                        'name': tc.name,
                        'arguments': jsonEncode(tc.arguments)
                      },
                    })
                .toList(),
          });
        } else {
          result.add({
            'role': 'assistant',
            'content': content.whereType<TextBlock>().map((b) => b.text).join(),
          });
        }

      case ToolResultMessage(:final toolCallId, :final content, :final isError):
        result.add({
          'role': 'tool',
          'tool_call_id': toolCallId,
          'content': content.whereType<TextBlock>().map((b) => b.text).join(),
          if (isError) 'is_error': true,
        });

      case CustomMessage(:final type, :final display):
        result.add({'role': 'user', 'content': '[$type] $display'});
    }
  }

  return result;
}

/// JSON encode helper for tool call arguments.
String jsonEncode(dynamic object) {
  final buffer = StringBuffer();
  _writeJson(object, buffer);
  return buffer.toString();
}

void _writeJson(dynamic object, StringBuffer buffer) {
  if (object == null) {
    buffer.write('null');
  } else if (object is String) {
    buffer.write('"');
    buffer.write(object
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t'));
    buffer.write('"');
  } else if (object is num || object is bool) {
    buffer.write(object);
  } else if (object is List) {
    buffer.write('[');
    for (var i = 0; i < object.length; i++) {
      if (i > 0) buffer.write(',');
      _writeJson(object[i], buffer);
    }
    buffer.write(']');
  } else if (object is Map) {
    buffer.write('{');
    var first = true;
    for (final entry in object.entries) {
      if (!first) buffer.write(',');
      first = false;
      _writeJson(entry.key, buffer);
      buffer.write(':');
      _writeJson(entry.value, buffer);
    }
    buffer.write('}');
  }
}
