import 'dart:io';

import 'package:pi/pi.dart';

/// Real end-to-end tool-calling run: the model requests a tool, the port
/// executes it, feeds the result back, and the model answers.
///
/// Environment: PI_API_KEY (required), PI_BASE_URL, PI_MODEL (optional).
/// Usage: PI_API_KEY=... dart run example/try_tools.dart "your prompt"
Future<void> main(List<String> args) async {
  final apiKey = Platform.environment['PI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('Set PI_API_KEY (optionally PI_BASE_URL, PI_MODEL).');
    exit(2);
  }
  final baseUrl = Platform.environment['PI_BASE_URL'] ?? 'http://localhost:8317/v1';
  final modelId =
      Platform.environment['PI_MODEL'] ?? 'kilo/baidu/ernie-5.5-flash-preview:free';

  final add = AgentTool(
    name: 'add',
    description: 'Add two integers a and b. Returns their sum.',
    parameters: const {
      'type': 'object',
      'properties': {
        'a': {'type': 'integer'},
        'b': {'type': 'integer'},
      },
      'required': ['a', 'b'],
    },
    execute: (id, params, {onUpdate, isAborted}) async {
      final a = (params['a'] as num?)?.toInt() ?? 0;
      final b = (params['b'] as num?)?.toInt() ?? 0;
      stderr.writeln('[execute add: $a + $b]');
      return AgentToolResult(content: [TextBlock('${a + b}')], details: null);
    },
  );

  final agent = Agent(
    model: Model(
      provider: 'openai',
      modelId: modelId,
      contextWindow: 128000,
      baseUrl: baseUrl,
    ),
    systemPrompt:
        'You are a helpful assistant. When a calculation is needed, call the add tool.',
    tools: [add],
    getApiKey: (_) async => apiKey,
  );

  agent.subscribe((event) {
    switch (event) {
      case ToolExecutionStart(toolName: final n, args: final a):
        stderr.writeln('[tool start: $n $a]');
      case ToolExecutionEnd(toolName: final n, isError: final e):
        stderr.writeln('[tool end: $n isError=$e]');
      case MessageUpdate(message: final m):
        if (m is AssistantMessage &&
            m.content.isNotEmpty &&
            m.content.last is TextBlock) {
          stdout.write((m.content.last as TextBlock).text);
        }
      case MessageEnd(message: final m):
        if (m is AssistantMessage && m.toolCalls.isNotEmpty) {
          stderr.writeln('[assistant requested tools: '
              '${m.toolCalls.map((t) => t.name).join(', ')}]');
        }
      default:
        break;
    }
  });

  final prompt = args.isNotEmpty
      ? args.join(' ')
      : 'What is 17 plus 25? Use the add tool to compute it, then state the result.';

  stderr.writeln('>>> $prompt');
  stdout.writeln();
  await agent.prompt(prompt);

  stderr.writeln('\n--- transcript (${agent.state.messages.length} messages) ---');
  for (final m in agent.state.messages) {
    final String text;
    if (m is UserMessage) {
      text = m.content.whereType<TextBlock>().map((b) => b.text).join();
    } else if (m is AssistantMessage) {
      text = m.text;
    } else if (m is ToolResultMessage) {
      text = m.content.whereType<TextBlock>().map((b) => b.text).join();
    } else {
      text = '';
    }
    stderr.writeln('  ${m.runtimeType}: ${text.replaceAll('\n', ' ')}');
  }
}