import 'package:test/test.dart';
import 'package:pi/src/types.dart';
import 'package:pi/src/pending_queue.dart';

/// Unit tests for PendingMessageQueue, the port of upstream
/// `packages/agent/src/agent.ts` PendingMessageQueue (arrrrny/pi#2).
///
/// The same queue type backs both the steering and the follow-up queue on the
/// Agent, so exercising it directly covers the mode semantics for both.
void main() {
  AgentMessage userMsg(String text) => UserMessage.text(text);

  String textOf(AgentMessage m) => (m as UserMessage)
      .content
      .whereType<TextBlock>()
      .map((b) => b.text)
      .join();

  group('PendingMessageQueue', () {
    test('one-at-a-time peek returns only the oldest', () {
      final q = PendingMessageQueue(QueueMode.oneAtATime);
      q.enqueue(userMsg('a'));
      q.enqueue(userMsg('b'));
      expect(q.peek().map(textOf), ['a']);
    });

    test('all peek returns every message', () {
      final q = PendingMessageQueue(QueueMode.all);
      q.enqueue(userMsg('a'));
      q.enqueue(userMsg('b'));
      expect(q.peek().map(textOf), ['a', 'b']);
    });

    test('one-at-a-time drain removes only the oldest', () {
      final q = PendingMessageQueue(QueueMode.oneAtATime);
      q.enqueue(userMsg('a'));
      q.enqueue(userMsg('b'));
      expect(q.drain().map(textOf), ['a']);
      expect(q.hasItems(), isTrue);
      expect(q.drain().map(textOf), ['b']);
      expect(q.hasItems(), isFalse);
    });

    test('all drain removes every message', () {
      final q = PendingMessageQueue(QueueMode.all);
      q.enqueue(userMsg('a'));
      q.enqueue(userMsg('b'));
      expect(q.drain().map(textOf), ['a', 'b']);
      expect(q.hasItems(), isFalse);
    });

    test('drain on empty queue returns empty', () {
      final q = PendingMessageQueue(QueueMode.oneAtATime);
      expect(q.drain(), isEmpty);
      final q2 = PendingMessageQueue(QueueMode.all);
      expect(q2.drain(), isEmpty);
    });

    test('peek does not consume', () {
      final q = PendingMessageQueue(QueueMode.all);
      q.enqueue(userMsg('a'));
      q.peek();
      q.peek();
      expect(q.hasItems(), isTrue);
      expect(q.drain().map(textOf), ['a']);
    });

    test('mode mutation affects messages already queued', () {
      final q = PendingMessageQueue(QueueMode.oneAtATime);
      q.enqueue(userMsg('a'));
      q.enqueue(userMsg('b'));
      q.mode = QueueMode.all;
      expect(q.drain().map(textOf), ['a', 'b']);
    });

    test('clear empties the queue', () {
      final q = PendingMessageQueue(QueueMode.all);
      q.enqueue(userMsg('a'));
      q.enqueue(userMsg('b'));
      q.clear();
      expect(q.hasItems(), isFalse);
      expect(q.drain(), isEmpty);
    });

    test('hasItems reflects enqueue and drain', () {
      final q = PendingMessageQueue(QueueMode.oneAtATime);
      expect(q.hasItems(), isFalse);
      q.enqueue(userMsg('a'));
      expect(q.hasItems(), isTrue);
      q.drain();
      expect(q.hasItems(), isFalse);
    });
  });
}
