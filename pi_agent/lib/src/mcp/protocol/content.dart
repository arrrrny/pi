/// Tool result content in the shape LLM APIs accept: text and base64 images.
///
/// Dart port of `packages/mcp/src/protocol/content.ts` (`toLlmContent`) at the
/// registry-pinned SHA. Content blocks are JSON maps as they arrive on the
/// wire; the LLM content is text and image maps as `pi-ai` accepts them.
library;

import 'dart:convert';

/// Sentinel for an unset [toLlmContent.structuredContent] / [toMcpModelContent]
/// argument, so an explicit `null` is distinguishable from an omitted one
/// (matching the upstream `!== undefined` check).
const Object unsetStructuredContent = Object();

/// Convert a tool result to text and image content for a model. Text and
/// images pass through, embedded text resources become text, embedded image
/// resources become images, and other blocks (audio, resource links, binary
/// resources) become a short text placeholder. A result without content
/// blocks but with [structuredContent] becomes its JSON, since servers should,
/// but do not always, mirror structured results as text.
///
/// [structuredContent] defaults to [unsetStructuredContent]; pass `null`
/// explicitly to render a JSON `null`, matching the upstream `!== undefined`
/// check.
List<Map<String, dynamic>> toLlmContent({
  List<Map<String, dynamic>> content = const [],
  Object? structuredContent = unsetStructuredContent,
}) {
  final result = content.map(_blockToLlmContent).toList();
  if (result.isEmpty && structuredContent != unsetStructuredContent) {
    result.add({
      'type': 'text',
      'text': const JsonEncoder.withIndent('  ').convert(structuredContent),
    });
  }
  return result;
}

/// Model-facing content of one block of a server's result.
Map<String, dynamic> _blockToLlmContent(Map<String, dynamic> block) {
  switch (block['type']) {
    case 'text':
      return {'type': 'text', 'text': block['text']};
    case 'image':
      return {
        'type': 'image',
        'data': block['data'],
        'mimeType': block['mimeType'],
      };
    case 'audio':
      return {
        'type': 'text',
        'text': '[audio ${block['mimeType']} omitted]',
      };
    case 'resource_link':
      return {
        'type': 'text',
        'text': '${block['name']}: ${block['uri']}',
      };
    case 'resource':
      final resource = block['resource'] as Map<String, dynamic>;
      if (resource.containsKey('text')) {
        return {'type': 'text', 'text': resource['text']};
      }
      final mimeType = resource['mimeType'] as String?;
      if (mimeType != null && mimeType.startsWith('image/')) {
        return {
          'type': 'image',
          'data': resource['blob'],
          'mimeType': mimeType,
        };
      }
      return {
        'type': 'text',
        'text':
            '[binary resource ${resource['uri']} (${mimeType ?? 'unknown type'}) omitted]',
      };
    default:
      return {
        'type': 'text',
        'text': '[unsupported MCP content ${block['type']}]',
      };
  }
}
