import 'types.dart';

/// A queue of pending user messages whose drain behavior depends on a
/// [QueueMode].
///
/// Port of upstream `packages/agent/src/agent.ts` `PendingMessageQueue`
/// (lines 149-180): `all` drains every queued message, while `oneAtATime`
/// drains only the oldest. The mode is mutable and affects messages already
/// queued, so changing it at runtime changes how the next drain behaves.
class PendingMessageQueue {
  final List<AgentMessage> _messages = [];

  /// The current drain mode. Affects messages already queued.
  QueueMode mode;

  /// Creates a queue that drains according to [mode].
  PendingMessageQueue(this.mode);

  /// Appends a message to the queue.
  void enqueue(AgentMessage message) => _messages.add(message);

  /// Whether the queue holds any messages.
  bool hasItems() => _messages.isNotEmpty;

  /// Returns the messages the next drain would remove, without consuming them.
  ///
  /// Returns every message when mode is [QueueMode.all], otherwise only the
  /// oldest.
  List<AgentMessage> peek() {
    if (mode == QueueMode.all) return List<AgentMessage>.from(_messages);
    if (_messages.isEmpty) return <AgentMessage>[];
    return <AgentMessage>[_messages.first];
  }

  /// Removes and returns the messages selected by [peek].
  List<AgentMessage> drain() {
    final drained = peek();
    _messages.removeRange(0, drained.length);
    return drained;
  }

  /// Removes all queued messages.
  void clear() => _messages.clear();
}
