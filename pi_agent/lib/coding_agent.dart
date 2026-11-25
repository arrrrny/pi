/// Coding-agent utilities ported from upstream `packages/coding-agent`.
///
/// The value-add of this fork is the Dart port; this library collects the
/// self-contained behavioral utilities ported from `packages/coding-agent/src/`
/// as the daily upstream sync lands them. Each file names the upstream source
/// and commit it ports.
library;

export 'src/coding_agent/compaction.dart';
export 'src/coding_agent/jsonl.dart';
export 'src/coding_agent/shell.dart';
export 'src/types.dart' show
    AgentMessage,
    AssistantMessage,
    ContentBlock,
    CustomMessage,
    MessageEntry,
    SessionTreeEntry,
    TextBlock,
    ThinkingBlock,
    ToolCallBlock,
    ToolResultMessage,
    UserMessage;
