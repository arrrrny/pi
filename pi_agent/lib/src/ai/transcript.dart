/// Transcript replay and tool-state resolution ported from upstream
/// `packages/ai/src/utils/transcript.ts` (dart-port slice in arrrrny/pi#65).
///
/// A transcript is a list of messages whose leading system message carries the
/// system prompt and tool declarations. Later system messages change the prompt
/// (`content` appends, `sections` patch by name) and the tool set
/// (`toolsAdded` / `toolsRemoved`). Replaying every system message in order
/// yields the current prompt and tools; the helpers here produce that replayed
/// state and split tool declarations between the top-level request field and
/// in-place changes according to a transport's `TranscriptToolSupport`.
library;

import 'dart:convert';
import 'dart:math' as math;

import 'package:pi/src/types.dart' show ContentBlock, TextBlock;

/// A tool the model may call.
///
/// [parameters] is the JSON Schema of its arguments. [constrainedSampling] is
/// `false` or a configuration object; null means it was never set (upstream's
/// `undefined`), which [toToolDeclaration] omits.
class Tool {
  /// Tool name the model calls.
  final String name;

  /// Human-readable description shown to the model.
  final String description;

  /// JSON Schema of the tool's arguments.
  final Map<String, dynamic> parameters;

  /// Constrained-sampling config, or `false` to disable it; null when unset.
  final Object? constrainedSampling;

  /// Creates a tool declaration.
  const Tool({
    required this.name,
    required this.description,
    required this.parameters,
    this.constrainedSampling,
  });
}

/// A reference to a tool by name, used to remove it from the transcript.
class ToolReference {
  /// Name of the referenced tool.
  final String name;

  /// Creates a tool reference.
  const ToolReference(this.name);
}

/// A message in a transcript. Only [SystemMessage] entries carry replay data;
/// every other role is a [GenericTranscriptMessage] the replay helpers ignore.
sealed class TranscriptMessage {
  /// Creates a transcript message.
  const TranscriptMessage();

  /// The message role (e.g. `system`, `user`, `assistant`).
  String get role;
}

/// A non-system transcript message (user, assistant, tool result, ...).
class GenericTranscriptMessage extends TranscriptMessage {
  @override
  final String role;

  /// Creates a non-system transcript message with the given [role].
  const GenericTranscriptMessage(this.role);
}

/// System instructions and tool declarations at one point in the transcript.
///
/// The leading system message is the system prompt; later ones change it.
class SystemMessage extends TranscriptMessage {
  @override
  String get role => 'system';

  /// Instruction text, or text content blocks. On the leading message this is
  /// the base prompt; later, additional instructions.
  final Object content;

  /// Named prompt sections rendered verbatim after [content]. A null value
  /// removes the named section.
  final Map<String, String?>? sections;

  /// Complete definitions of tools that become available at this point.
  final List<Tool>? toolsAdded;

  /// Tools that stop being available at this point.
  final List<ToolReference>? toolsRemoved;

  /// Unix timestamp in milliseconds.
  final int timestamp;

  /// Creates a system message.
  const SystemMessage({
    this.content = '',
    this.sections,
    this.toolsAdded,
    this.toolsRemoved,
    this.timestamp = 0,
  });
}

/// Request input accepted by the public stream entry points. [systemPrompt] and
/// [tools] are shorthand for a leading system message; [normalizeContext] folds
/// them into one before the request reaches a provider.
class Context {
  /// Optional base system prompt.
  final String? systemPrompt;

  /// The conversation messages.
  final List<TranscriptMessage> messages;

  /// Optional tool declarations.
  final List<Tool>? tools;

  /// Creates a request context.
  const Context({
    this.systemPrompt,
    required this.messages,
    this.tools,
  });
}

/// Normalized request context passed to providers: the prompt and tool
/// declarations are carried by the transcript's system messages.
class TranscriptContext {
  /// The normalized messages.
  final List<TranscriptMessage> messages;

  /// Creates a normalized transcript context.
  const TranscriptContext(this.messages);
}

/// The before/after tool state between two complete tool lists.
class ToolStateChanges {
  /// Tools added or whose definition changed.
  final List<Tool> toolsAdded;

  /// Tools removed or whose definition changed.
  final List<ToolReference> toolsRemoved;

  /// Creates a tool-state change record.
  const ToolStateChanges(
      {required this.toolsAdded, required this.toolsRemoved});
}

/// How a transport can express tool changes after the first request.
enum TranscriptToolSupport {
  /// Only the top-level tool list exists; it always holds the current tools.
  none,

  /// Tools can be added at a later message, but not removed or redefined.
  additions,

  /// Every tool is declared in place; a later declaration replaces an earlier
  /// one under the same name.
  changes,
}

/// Split of tool declarations between the top-level request field and in-place
/// changes.
class TranscriptTools {
  /// Tools sent in the top-level request field.
  final List<Tool> requestTools;

  /// Number of leading system messages whose tool changes [requestTools]
  /// already holds.
  final int foldedSystemMessages;

  /// Creates a tool-split record.
  const TranscriptTools({
    required this.requestTools,
    required this.foldedSystemMessages,
  });
}

/// Extract and join text from message content with [separator] (upstream
/// `contentText`). Image, thinking and tool-call blocks are ignored.
String contentText(Object content, [String separator = '\n']) {
  if (content is String) return content;
  if (content is List<ContentBlock>) {
    return content
        .whereType<TextBlock>()
        .map((block) => block.text)
        .join(separator);
  }
  return '';
}

/// Render a system message as a complete prompt: its content followed by its
/// non-null sections, joined by a blank line (upstream `getSystemMessageText`).
String getSystemMessageText(SystemMessage message) {
  final parts = <String>[contentText(message.content)];
  for (final value in message.sections?.values ?? const <String?>[]) {
    if (value != null) parts.add(value);
  }
  return parts.where((part) => part.isNotEmpty).join('\n\n');
}

/// Build the leading system message for a prompt and tool set. Returns null
/// when both are empty, so an empty transcript stays empty.
SystemMessage? createInitialSystemMessage(
  String? systemPrompt,
  List<Tool>? tools,
) {
  final hasSystemPrompt = systemPrompt != null && systemPrompt.isNotEmpty;
  final hasTools = tools != null && tools.isNotEmpty;
  if (!hasSystemPrompt && !hasTools) return null;
  return SystemMessage(
    content: systemPrompt ?? '',
    toolsAdded: hasTools ? tools : null,
    timestamp: 0,
  );
}

/// Fold [Context.systemPrompt] and [Context.tools] into a leading system
/// message. The only entry point that produces a [TranscriptContext].
TranscriptContext normalizeContext(Context context) {
  final initialMessage =
      createInitialSystemMessage(context.systemPrompt, context.tools);
  final messages = initialMessage != null
      ? <TranscriptMessage>[initialMessage, ...context.messages]
      : context.messages;
  return TranscriptContext(messages);
}

/// Return the leading system message, if the transcript starts with one.
SystemMessage? getInitialSystemMessage(
  List<TranscriptMessage> messages,
) {
  if (messages.isEmpty) return null;
  final first = messages.first;
  return first is SystemMessage ? first : null;
}

/// Drop the leading system message for APIs that carry the prompt outside the
/// message list.
List<TranscriptMessage> withoutInitialSystemMessage(
  List<TranscriptMessage> messages,
) {
  return getInitialSystemMessage(messages) != null
      ? messages.sublist(1)
      : messages;
}

/// Resolve the tools available after applying every transcript delta in order.
List<Tool> getCurrentTools(List<TranscriptMessage> messages) {
  final tools = <String, Tool>{};
  for (final message in messages) {
    if (message is! SystemMessage) continue;
    for (final tool in message.toolsRemoved ?? const <ToolReference>[]) {
      tools.remove(tool.name);
    }
    for (final tool in message.toolsAdded ?? const <Tool>[]) {
      tools[tool.name] = tool;
    }
  }
  return tools.values.toList();
}

/// Replay every system message into one leading system message holding the
/// current prompt and tools. Later `content` is appended to the base prompt,
/// `sections` are patched by name, and tools are resolved with
/// [getCurrentTools].
SystemMessage? getCurrentSystemMessage(List<TranscriptMessage> messages) {
  final content = <String>[];
  final sections = <String, String>{};
  int? timestamp;
  for (final message in messages) {
    if (message is! SystemMessage) continue;
    timestamp ??= message.timestamp;
    final text = contentText(message.content);
    if (text.isNotEmpty) content.add(text);
    for (final entry
        in (message.sections ?? const <String, String?>{}).entries) {
      if (entry.value == null) {
        sections.remove(entry.key);
      } else {
        sections[entry.key] = entry.value!;
      }
    }
  }
  final tools = getCurrentTools(messages);
  if (timestamp == null && tools.isEmpty) return null;
  return SystemMessage(
    content: content.join('\n\n'),
    sections: sections.isNotEmpty ? sections : null,
    toolsAdded: tools.isNotEmpty ? tools : null,
    timestamp: timestamp ?? 0,
  );
}

/// Render the current system prompt text after replaying every system message.
String getCurrentSystemPrompt(List<TranscriptMessage> messages) {
  final message = getCurrentSystemMessage(messages);
  return message != null ? getSystemMessageText(message) : '';
}

/// Rebuild the transcript for APIs without mid-conversation system messages:
/// the replayed system message leads, and every later system message is
/// dropped.
TranscriptContext collapseSystemMessages(TranscriptContext context) {
  final head = getCurrentSystemMessage(context.messages);
  final messages =
      context.messages.where((message) => message is! SystemMessage).toList();
  return TranscriptContext(
    head != null ? <TranscriptMessage>[head, ...messages] : messages,
  );
}

/// Keep later system messages in place when the model accepts them; otherwise
/// collapse them.
TranscriptContext resolveTranscript(
  TranscriptContext context,
  bool? supportsMidConvoSystemMessages,
) {
  return supportsMidConvoSystemMessages == true
      ? context
      : collapseSystemMessages(context);
}

/// Strip executable and display-only fields from a tool before transcript
/// comparison or persistence. The parameters are JSON round-tripped so the
/// declaration compares by serialized bytes (upstream contract).
Tool toToolDeclaration(Tool tool) {
  final parameters =
      jsonDecode(jsonEncode(tool.parameters)) as Map<String, dynamic>;
  return Tool(
    name: tool.name,
    description: tool.description,
    parameters: parameters,
    constrainedSampling: tool.constrainedSampling,
  );
}

/// Whether two tools declare the same interface to the model. Both sides go
/// through [toToolDeclaration] first, so the comparison is exact on the
/// serialized declaration (key order included).
bool declarationsEqual(Tool left, Tool right) {
  return _serializeDeclaration(toToolDeclaration(left)) ==
      _serializeDeclaration(toToolDeclaration(right));
}

String _serializeDeclaration(Tool tool) {
  final declaration = <String, dynamic>{
    'name': tool.name,
    'description': tool.description,
    'parameters': tool.parameters,
    if (tool.constrainedSampling != null)
      'constrainedSampling': tool.constrainedSampling,
  };
  return jsonEncode(declaration);
}

/// Compare two complete tool states. A changed definition is a removal
/// followed by an addition.
ToolStateChanges getToolStateChanges(
  List<Tool> previous,
  List<Tool> current,
) {
  final previousTools = {for (final tool in previous) tool.name: tool};
  final currentTools = {for (final tool in current) tool.name: tool};
  final toolsAdded = current
      .where((tool) {
        final previousTool = previousTools[tool.name];
        return previousTool == null || !declarationsEqual(previousTool, tool);
      })
      .map(toToolDeclaration)
      .toList();
  final toolsRemoved = previous
      .where((tool) {
        final currentTool = currentTools[tool.name];
        return currentTool == null || !declarationsEqual(tool, currentTool);
      })
      .map((tool) => ToolReference(tool.name))
      .toList();
  return ToolStateChanges(toolsAdded: toolsAdded, toolsRemoved: toolsRemoved);
}

/// Every definition referenced by transcript tool state, in first-declaration
/// order.
List<Tool> getDeclaredTools(List<TranscriptMessage> messages) {
  final definitions = <String, Tool>{};
  for (final message in messages) {
    if (message is! SystemMessage) continue;
    for (final tool in message.toolsAdded ?? const <Tool>[]) {
      definitions[tool.name] = tool;
    }
  }
  return definitions.values.toList();
}

/// Whether a tool name was declared twice with different definitions. A
/// transport that can only reference previously declared tools by name cannot
/// replay such a history.
bool hasToolRedefinitions(List<TranscriptMessage> messages) {
  final declared = <String, Tool>{};
  for (final message in messages) {
    if (message is! SystemMessage) continue;
    for (final tool in message.toolsAdded ?? const <Tool>[]) {
      final previous = declared[tool.name];
      if (previous != null && !declarationsEqual(previous, tool)) return true;
      declared[tool.name] = tool;
    }
  }
  return false;
}

/// Whether tool history contains a removal or same-name redeclaration that an
/// addition-only transport cannot replay.
bool hasNonAdditiveToolChanges(List<TranscriptMessage> messages) {
  final systemMessages =
      messages.whereType<SystemMessage>().toList(growable: false);
  return _findLastNonAdditiveToolChange(systemMessages) >= 0;
}

/// Index of the last system message with a removal or same-name redeclaration,
/// or -1.
int _findLastNonAdditiveToolChange(List<SystemMessage> systemMessages) {
  // A name declared before counts as a redeclaration even after its removal.
  final declared = <String>{};
  var last = -1;
  for (var index = 0; index < systemMessages.length; index++) {
    final message = systemMessages[index];
    if ((message.toolsRemoved?.length ?? 0) > 0) last = index;
    for (final tool in message.toolsAdded ?? const <Tool>[]) {
      if (declared.contains(tool.name)) last = index;
      declared.add(tool.name);
    }
  }
  return last;
}

/// Split tool declarations between the top-level request field and in-place
/// changes for a transport with the given [support].
TranscriptTools resolveTranscriptTools(
  List<TranscriptMessage> messages,
  TranscriptToolSupport support,
) {
  final systemMessages =
      messages.whereType<SystemMessage>().toList(growable: false);
  switch (support) {
    case TranscriptToolSupport.none:
      return TranscriptTools(
        requestTools: getCurrentTools(systemMessages),
        foldedSystemMessages: systemMessages.length,
      );
    case TranscriptToolSupport.changes:
      return const TranscriptTools(requestTools: [], foldedSystemMessages: 0);
    case TranscriptToolSupport.additions:
      final folded = math.max(
        getInitialSystemMessage(messages) != null ? 1 : 0,
        _findLastNonAdditiveToolChange(systemMessages) + 1,
      );
      return TranscriptTools(
        requestTools: getCurrentTools(systemMessages.sublist(0, folded)),
        foldedSystemMessages: folded,
      );
  }
}
