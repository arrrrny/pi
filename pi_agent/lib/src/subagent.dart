/// Subagent tools.
///
/// A subagent is a child [Agent] run to completion on behalf of a parent: the
/// parent calls a tool with a task, the child runs its own conversation, and the
/// child's final answer is returned as the tool result. This is the Dart-native
/// equivalent of pi's task/spawn subagents, built on the same agent loop.
library;

import 'types.dart' hide AgentTool;
import 'tools.dart';
import 'agent.dart';

/// Builds a fresh child [Agent] for each subagent invocation.
///
/// The factory decides the child's model, tools, and per-turn `loopStreamFn`, so
/// a subagent can run with the same LLM as the parent or a different one.
typedef SubagentFactory = Agent Function();

/// Extracts the subagent's final answer text from its transcript.
typedef SubagentAnswer = String Function(List<AgentMessage> messages);

/// Default answer extraction: the text of the last assistant message.
String defaultSubagentAnswer(List<AgentMessage> messages) {
  final assistants = messages.whereType<AssistantMessage>().toList();
  return assistants.isEmpty ? '' : assistants.last.text;
}

/// Creates an [AgentTool] that delegates a task to a child agent and returns
/// the child's final answer as the tool result.
///
/// The tool takes a single `task` string argument. Each call builds a fresh
/// child via [childFactory], runs it to completion, and reports the answer.
AgentTool<dynamic, dynamic> subagentTool({
  required String name,
  required String description,
  required SubagentFactory childFactory,
  SubagentAnswer? answer,
}) {
  return AgentTool<dynamic, dynamic>(
    name: name,
    description: description,
    parameters: const {
      'type': 'object',
      'properties': {
        'task': {
          'type': 'string',
          'description': 'The task to delegate to the subagent.',
        },
      },
      'required': ['task'],
    },
    execute: (id, params, {onUpdate, isAborted}) async {
      final rawTask = params['task'];
      final task = rawTask is String ? rawTask : rawTask?.toString() ?? '';

      final child = childFactory();
      await child.prompt(task);

      final messages = child.state.messages;
      final text = (answer ?? defaultSubagentAnswer)(messages);

      return AgentToolResult<dynamic>(
        content: [TextBlock(text)],
        details: {
          'subagent': name,
          'messageCount': messages.length,
        },
      );
    },
  );
}