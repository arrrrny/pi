/// Ported from packages/mcp/test/naming.test.ts for pi#83.
///
/// Covers createMcpToolName, mcpNamespace and mcpServerSummary: the names and
/// one-line summaries of MCP tools and their servers' namespaces.
library;

import 'package:pi/mcp.dart';
import 'package:test/test.dart';

void main() {
  group('createMcpToolName', () {
    test('joins server and tool and replaces characters outside [A-Za-z0-9_]',
        () {
      expect(createMcpToolName('docs', 'search'), 'mcp__docs__search');
      expect(
        createMcpToolName('my-server', 'get.item/v2'),
        'mcp__my_server__get_item_v2',
      );
    });

    test('shortens names over 64 characters with a hash of server and tool',
        () {
      final long = createMcpToolName('server', 'x' * 100);
      expect(long.length, 64);
      expect(long, matches(RegExp(r'^mcp__server__x+_[0-9a-f]{8}$')));
      // Names that share their first 55 characters still differ.
      expect(
        createMcpToolName('server', '${'x' * 100}y'),
        isNot(long),
      );
      // The hash covers the unsanitized names, and is stable.
      expect(createMcpToolName('server', 'x' * 100), long);
      expect(
        createMcpToolName('ser-ver', 'x' * 100),
        isNot(createMcpToolName('ser_ver', 'x' * 100)),
      );
    });

    test('adds the hash suffix when the sanitized name is taken', () {
      final taken = createMcpToolName('s', 'a_b');
      expect(taken, 'mcp__s__a_b');
      final second = createMcpToolName('s', 'a-b', (name) => name == taken);
      expect(second, matches(RegExp(r'^mcp__s__a_b_[0-9a-f]{8}$')));
      expect(
        createMcpToolName('s', 'a_b', (name) => name == taken),
        isNot(second),
      );
    });
  });

  group('mcpNamespace', () {
    test('is mcp__<server> with - replaced by _, the prefix of the tool names',
        () {
      expect(mcpNamespace('docs'), 'mcp__docs');
      expect(mcpNamespace('my-server'), 'mcp__my_server');
      expect(mcpNamespace('my-server'), mcpNamespace('my_server'));
      expect(
        createMcpToolName('my-server', 'search')
            .startsWith('${mcpNamespace('my-server')}__'),
        isTrue,
      );
    });
  });

  group('mcpServerSummary', () {
    test(
        'takes the first line of the configured description, else of the instructions',
        () {
      expect(
        mcpServerSummary(' Docs search.\nMore. ', 'Ignored.'),
        'Docs search.',
      );
      expect(
        mcpServerSummary(
          null,
          '\n  Web search for current information.\nDetails.',
        ),
        'Web search for current information.',
      );
      expect(
          mcpServerSummary('  ', 'From instructions.'), 'From instructions.');
      expect(mcpServerSummary(null, null), '');
    });
  });
}
