/// Ported from packages/mcp/test/model-content.test.ts for pi#83.
///
/// Covers toMcpModelContent: the model-facing content of an MCP result (text,
/// images, embedded text resources as text, binary resources saved where the
/// model can read them, resource links that name the tool reading them).
library;

import 'dart:convert';

import 'package:pi/mcp.dart';
import 'package:test/test.dart';

void main() {
  final link = <String, dynamic>{
    'type': 'resource_link',
    'uri': 'docs://guide',
    'name': 'guide',
    'title': 'The Guide',
    'mimeType': 'text/markdown',
    'size': 2048,
    'description': 'How to use it',
  };
  final pdf = <String, dynamic>{
    'type': 'resource',
    'resource': {
      'uri': 'file:///r/report.pdf',
      'mimeType': 'application/pdf',
      'blob': 'JVBERg==',
    },
  };

  group('toMcpModelContent', () {
    test('names the read tool in resource links when there is one', () async {
      expect(
        await toMcpModelContent(
          'docs',
          content: [link],
          readResourceTool: 'read_mcp_resource',
        ),
        [
          {
            'type': 'text',
            'text':
                '[Resource docs://guide "The Guide" (text/markdown, 2.0KB): How to use it. Read it with read_mcp_resource (server "docs")]',
          },
        ],
      );
      expect(
        await toMcpModelContent(
          'docs',
          content: [
            {'type': 'resource_link', 'uri': 'file:///a', 'name': 'a'},
          ],
        ),
        [
          {
            'type': 'text',
            'text': '[Resource file:///a "a"]',
          },
        ],
      );
    });

    test('saves binary resources, shows text blobs as text and keeps images',
        () async {
      final saved = <List<dynamic>>[];
      Future<String> saveOutput(List<int> data, String extension) async {
        saved.add([data, extension]);
        return '/tmp/saved$extension';
      }

      final json = base64Encode(utf8.encode('{"a":1}'));
      final content = <Map<String, dynamic>>[
        pdf,
        {
          'type': 'resource',
          'resource': {
            'uri': 'docs://data',
            'mimeType': 'application/json; charset=utf-8',
            'blob': json,
          },
        },
        {
          'type': 'resource',
          'resource': {
            'uri': 'docs://logo',
            'mimeType': 'image/png',
            'blob': 'AAAA',
          },
        },
        {
          'type': 'resource',
          'resource': {'uri': 'docs://raw', 'blob': 'AAAA'},
        },
      ];
      expect(
        await toMcpModelContent('docs',
            content: content, saveOutput: saveOutput),
        [
          {
            'type': 'text',
            'text':
                '[Binary resource file:///r/report.pdf (application/pdf, 4B) saved to /tmp/saved.pdf]',
          },
          {'type': 'text', 'text': '{"a":1}'},
          {'type': 'image', 'data': 'AAAA', 'mimeType': 'image/png'},
          {
            'type': 'text',
            'text':
                '[Binary resource docs://raw (unknown type, 3B) saved to /tmp/saved.bin]',
          },
        ],
      );
      expect(saved, [
        [base64Decode('JVBERg=='), '.pdf'],
        [base64Decode('AAAA'), '.bin'],
      ]);
    });

    test(
        'leaves binary resources out without a saver, and says why when saving fails',
        () async {
      expect(
        await toMcpModelContent('docs', content: [pdf]),
        [
          {
            'type': 'text',
            'text':
                '[binary resource file:///r/report.pdf (application/pdf) omitted]',
          },
        ],
      );
      Future<String> failing(List<int> data, String extension) async {
        throw Exception('disk full');
      }

      expect(
        await toMcpModelContent('docs', content: [pdf], saveOutput: failing),
        [
          {
            'type': 'text',
            'text':
                '[Binary resource file:///r/report.pdf (application/pdf, 4B) could not be saved: disk full]',
          },
        ],
      );
    });

    test('shows structured content as JSON when there are no content blocks',
        () async {
      expect(
        await toMcpModelContent(
          'docs',
          content: [],
          structuredContent: [
            {'id': 1},
          ],
        ),
        [
          {
            'type': 'text',
            'text': '[\n  {\n    "id": 1\n  }\n]',
          },
        ],
      );
    });
  });
}
