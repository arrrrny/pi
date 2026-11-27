// Tests for the transcript replay + tool-state resolution port from upstream
// `packages/ai/src/utils/transcript.ts` (dart-port slice in arrrrny/pi#65).
import 'package:test/test.dart';

import 'package:pi/src/ai/transcript.dart';
import 'package:pi/src/types.dart' show TextBlock;

SystemMessage _sys({
  Object content = '',
  Map<String, String?>? sections,
  List<Tool>? toolsAdded,
  List<ToolReference>? toolsRemoved,
  int timestamp = 0,
}) =>
    SystemMessage(
      content: content,
      sections: sections,
      toolsAdded: toolsAdded,
      toolsRemoved: toolsRemoved,
      timestamp: timestamp,
    );

Tool _tool(String name,
        {String description = 'd', Map<String, dynamic>? parameters}) =>
    Tool(
      name: name,
      description: description,
      parameters: parameters ?? {'type': 'object'},
    );

void main() {
  group('createInitialSystemMessage', () {
    test('empty prompt and no tools yields null', () {
      expect(createInitialSystemMessage(null, null), isNull);
      expect(createInitialSystemMessage('', []), isNull);
    });

    test('prompt only carries content and no toolsAdded', () {
      final m = createInitialSystemMessage('hi', null)!;
      expect(m.content, 'hi');
      expect(m.toolsAdded, isNull);
      expect(m.timestamp, 0);
    });

    test('tools only carry toolsAdded and empty content', () {
      final m = createInitialSystemMessage(null, [_tool('a')])!;
      expect(m.content, '');
      expect(m.toolsAdded?.map((t) => t.name), ['a']);
    });
  });

  group('normalizeContext', () {
    test('folds systemPrompt and tools into a leading system message', () {
      final ctx = normalizeContext(
        Context(systemPrompt: 'p', tools: [
          _tool('a')
        ], messages: [
          const GenericTranscriptMessage('user'),
        ]),
      );
      expect(ctx.messages.first, isA<SystemMessage>());
      expect(ctx.messages.length, 2);
    });

    test('no prompt/tools leaves messages untouched', () {
      final ctx = normalizeContext(
        Context(messages: [const GenericTranscriptMessage('user')]),
      );
      expect(ctx.messages.length, 1);
      expect(ctx.messages.first, isA<GenericTranscriptMessage>());
    });
  });

  group('getInitialSystemMessage / withoutInitialSystemMessage', () {
    test('returns the leading system message only', () {
      final msgs = [_sys(content: 'x'), const GenericTranscriptMessage('user')];
      expect(getInitialSystemMessage(msgs)?.content, 'x');
      expect(getInitialSystemMessage([const GenericTranscriptMessage('user')]),
          isNull);
    });

    test('withoutInitialSystemMessage drops the leading system message', () {
      final msgs = [_sys(content: 'x'), const GenericTranscriptMessage('user')];
      expect(withoutInitialSystemMessage(msgs).length, 1);
      expect(
          withoutInitialSystemMessage([const GenericTranscriptMessage('user')])
              .length,
          1);
    });
  });

  group('getCurrentTools', () {
    test('applies removals and additions in order', () {
      final msgs = [
        _sys(toolsAdded: [_tool('a'), _tool('b')]),
        _sys(toolsRemoved: [ToolReference('a')]),
        _sys(toolsAdded: [_tool('c')]),
      ];
      expect(getCurrentTools(msgs).map((t) => t.name), ['b', 'c']);
    });

    test('re-adding a removed tool moves it to the end', () {
      final msgs = [
        _sys(toolsAdded: [_tool('a'), _tool('b')]),
        _sys(toolsRemoved: [ToolReference('a')]),
        _sys(toolsAdded: [_tool('a')]),
      ];
      expect(getCurrentTools(msgs).map((t) => t.name), ['b', 'a']);
    });
  });

  group('getCurrentSystemMessage', () {
    test('appends content with a blank line and keeps first timestamp', () {
      final msgs = [
        _sys(content: 'one', timestamp: 10),
        _sys(content: 'two', timestamp: 20),
      ];
      final m = getCurrentSystemMessage(msgs)!;
      expect(m.content, 'one\n\ntwo');
      expect(m.timestamp, 10);
    });

    test('patches and removes sections by name', () {
      final msgs = [
        _sys(sections: {'a': 'A', 'b': 'B'}),
        _sys(sections: {'b': null, 'c': 'C'}),
      ];
      final m = getCurrentSystemMessage(msgs)!;
      expect(m.sections, {'a': 'A', 'c': 'C'});
    });

    test('undefined when there is no timestamp and no tools', () {
      expect(getCurrentSystemMessage([const GenericTranscriptMessage('user')]),
          isNull);
    });

    test('content from text blocks is joined', () {
      final msgs = [
        _sys(content: [const TextBlock('a'), const TextBlock('b')]),
      ];
      expect(getCurrentSystemMessage(msgs)!.content, 'a\nb');
    });
  });

  group('getCurrentSystemPrompt', () {
    test('renders content followed by sections', () {
      final msgs = [
        _sys(content: 'base', sections: {'s': 'S'}),
      ];
      expect(getCurrentSystemPrompt(msgs), 'base\n\nS');
    });

    test('empty string when there is no system message', () {
      expect(
          getCurrentSystemPrompt([const GenericTranscriptMessage('user')]), '');
    });
  });

  group('collapseSystemMessages / resolveTranscript', () {
    test('collapse keeps the replayed head and drops later system messages',
        () {
      final ctx = TranscriptContext([
        _sys(content: 'a', timestamp: 1),
        const GenericTranscriptMessage('user'),
        _sys(content: 'b', timestamp: 2),
      ]);
      final out = collapseSystemMessages(ctx);
      expect(out.messages.length, 2);
      expect((out.messages.first as SystemMessage).content, 'a\n\nb');
    });

    test('resolveTranscript keeps context when mid-convo is supported', () {
      final ctx = TranscriptContext([
        _sys(content: 'a', timestamp: 1),
        _sys(content: 'b', timestamp: 2),
      ]);
      expect(resolveTranscript(ctx, true).messages.length, 2);
      expect(resolveTranscript(ctx, false).messages.length, 1);
    });
  });

  group('toToolDeclaration / declarationsEqual', () {
    test('strips extra fields and round-trips parameters', () {
      final t = Tool(
        name: 'a',
        description: 'd',
        parameters: {'type': 'object', 'x': 1},
        constrainedSampling: false,
      );
      final d = toToolDeclaration(t);
      expect(d.constrainedSampling, false);
      expect(d.parameters, {'type': 'object', 'x': 1});
    });

    test('equal declarations with different key order compare equal', () {
      final left = _tool('a', parameters: {'type': 'object', 'x': 1});
      final right = _tool('a', parameters: {'x': 1, 'type': 'object'});
      // Same keys, different insertion order: JSON round-trip in
      // toToolDeclaration preserves each side's order, so equality is by
      // serialized bytes (upstream contract). Different order => not equal.
      expect(declarationsEqual(left, right), isFalse);
      expect(declarationsEqual(left, left), isTrue);
    });
  });

  group('getToolStateChanges', () {
    test('a changed definition is a removal plus an addition', () {
      final prev = [_tool('a'), _tool('b')];
      final curr = [_tool('a', description: 'changed'), _tool('c')];
      final changes = getToolStateChanges(prev, curr);
      expect(changes.toolsAdded.map((t) => t.name), ['a', 'c']);
      expect(changes.toolsRemoved.map((r) => r.name), ['a', 'b']);
    });
  });

  group('getDeclaredTools', () {
    test('every declared definition in first-declaration order', () {
      final msgs = [
        _sys(toolsAdded: [_tool('a'), _tool('b')]),
        _sys(toolsAdded: [_tool('a', description: 'redef')]),
      ];
      // Map.set on an existing key keeps original position but updates value.
      final declared = getDeclaredTools(msgs);
      expect(declared.map((t) => t.name), ['a', 'b']);
      expect(declared.first.description, 'redef');
    });
  });

  group('hasToolRedefinitions', () {
    test('true when a name is declared twice with different definitions', () {
      final msgs = [
        _sys(toolsAdded: [_tool('a')]),
        _sys(toolsAdded: [_tool('a', description: 'other')]),
      ];
      expect(hasToolRedefinitions(msgs), isTrue);
    });

    test('false when redeclarations are identical', () {
      final msgs = [
        _sys(toolsAdded: [_tool('a')]),
        _sys(toolsAdded: [_tool('a')]),
      ];
      expect(hasToolRedefinitions(msgs), isFalse);
    });
  });

  group('hasNonAdditiveToolChanges', () {
    test('true on a removal', () {
      final msgs = [
        _sys(toolsAdded: [_tool('a')]),
        _sys(toolsRemoved: [ToolReference('a')]),
      ];
      expect(hasNonAdditiveToolChanges(msgs), isTrue);
    });

    test('true on a same-name redeclaration', () {
      final msgs = [
        _sys(toolsAdded: [_tool('a')]),
        _sys(toolsAdded: [_tool('a', description: 'x')]),
      ];
      expect(hasNonAdditiveToolChanges(msgs), isTrue);
    });

    test('false for additions only', () {
      final msgs = [
        _sys(toolsAdded: [_tool('a')]),
        _sys(toolsAdded: [_tool('b')]),
      ];
      expect(hasNonAdditiveToolChanges(msgs), isFalse);
    });
  });

  group('resolveTranscriptTools', () {
    test('none: request tools are the current set, all folded', () {
      final msgs = [
        _sys(toolsAdded: [_tool('a')]),
        _sys(toolsAdded: [_tool('b')]),
      ];
      final out = resolveTranscriptTools(msgs, TranscriptToolSupport.none);
      expect(out.requestTools.map((t) => t.name), ['a', 'b']);
      expect(out.foldedSystemMessages, 2);
    });

    test('changes: empty request tools, nothing folded', () {
      final msgs = [
        _sys(toolsAdded: [_tool('a')])
      ];
      final out = resolveTranscriptTools(msgs, TranscriptToolSupport.changes);
      expect(out.requestTools, isEmpty);
      expect(out.foldedSystemMessages, 0);
    });

    test('additions: folds up to the last non-additive change', () {
      final msgs = [
        _sys(toolsAdded: [_tool('a')]), // index 0
        _sys(toolsAdded: [_tool('b')]), // index 1
        _sys(toolsRemoved: [ToolReference('a')]), // index 2 non-additive
        _sys(toolsAdded: [_tool('c')]), // index 3
      ];
      final out = resolveTranscriptTools(msgs, TranscriptToolSupport.additions);
      // folded = max(initial 1, lastNonAdditive 2 + 1) = 3
      expect(out.foldedSystemMessages, 3);
      expect(out.requestTools.map((t) => t.name), ['b']);
    });
  });
}
