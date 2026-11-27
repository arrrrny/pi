/// The model-facing content of an MCP result as pi's coding agent shows it:
/// text and images, embedded text resources as text, binary resources saved
/// where the model can read them, and resource links that name the tool
/// reading them.
///
/// Dart port of `packages/mcp/src/model-content.ts` at the registry-pinned SHA.
library;

import 'dart:convert';

import 'protocol/content.dart';

/// Saves binary resources other than images where the model can read them.
/// Without it they are left out.
typedef McpOutputSaver = Future<String> Function(
    List<int> data, String extension);

/// Model-facing content of [server]'s result, before the output limit. A
/// result without content blocks becomes its structured content as JSON, as in
/// [toLlmContent].
Future<List<Map<String, dynamic>>> toMcpModelContent(
  String server, {
  List<Map<String, dynamic>> content = const [],
  Object? structuredContent = unsetStructuredContent,
  McpOutputSaver? saveOutput,
  String? readResourceTool,
}) async {
  if (content.isEmpty) {
    return toLlmContent(structuredContent: structuredContent);
  }
  final result = <Map<String, dynamic>>[];
  for (final block in content) {
    result.addAll(
      await _blockToContent(server, block, saveOutput, readResourceTool),
    );
  }
  return result;
}

/// Model-facing content of one block of [server]'s result.
Future<List<Map<String, dynamic>>> _blockToContent(
  String server,
  Map<String, dynamic> block,
  McpOutputSaver? saveOutput,
  String? readResourceTool,
) async {
  if (block['type'] == 'resource_link') {
    final details = <String>[
      if (block['mimeType'] != null) block['mimeType'] as String,
      if (block['size'] != null) _formatSize(block['size'] as int),
    ];
    final read = readResourceTool != null
        ? '. Read it with $readResourceTool (server "$server")'
        : '';
    final description =
        block['description'] != null ? ': ${block['description']}' : '';
    final title = block['title'] ?? block['name'];
    return [
      {
        'type': 'text',
        'text':
            '[Resource ${block['uri']} "$title"${details.isNotEmpty ? ' (${details.join(', ')})' : ''}$description$read]',
      },
    ];
  }
  if (block['type'] == 'resource') {
    final resource = block['resource'] as Map<String, dynamic>;
    if (resource.containsKey('blob') &&
        !(resource['mimeType'] as String? ?? '').startsWith('image/')) {
      final uri = resource['uri'] as String;
      final mimeType = resource['mimeType'] as String?;
      final blob = resource['blob'] as String;
      final data = base64Decode(blob);
      if (_isTextMimeType(mimeType)) {
        return [
          {'type': 'text', 'text': utf8.decode(data)},
        ];
      }
      if (saveOutput == null) {
        return toLlmContent(content: [block]);
      }
      final kind = '${mimeType ?? 'unknown type'}, ${_formatSize(data.length)}';
      try {
        final path = await saveOutput(data, _extensionOf(uri));
        return [
          {
            'type': 'text',
            'text': '[Binary resource $uri ($kind) saved to $path]',
          },
        ];
      } catch (error) {
        final reason = error is Exception
            ? error.toString().replaceFirst(RegExp(r'^Exception: '), '')
            : '$error';
        return [
          {
            'type': 'text',
            'text':
                '[Binary resource $uri ($kind) could not be saved: $reason]',
          },
        ];
      }
    }
  }
  return toLlmContent(content: [block]);
}

/// A byte count as pi's coding agent shows sizes: `512B`, `2.0KB`, `1.5MB`.
String _formatSize(int bytes) {
  if (bytes < 1024) return '${bytes}B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
}

/// Blobs of these types are shown as text.
bool _isTextMimeType(String? mimeType) {
  if (mimeType == null) return false;
  final type = mimeType.split(';').first.trim().toLowerCase();
  return type.startsWith('text/') ||
      type == 'application/json' ||
      type.endsWith('+json') ||
      type.endsWith('+xml');
}

/// File extension for a saved binary resource: the one its URI ends in, else
/// `.bin`.
String _extensionOf(String uri) {
  final path = Uri.tryParse(uri)?.path ?? uri;
  return RegExp(r'\.[A-Za-z0-9]{1,8}$').firstMatch(path)?[0] ?? '.bin';
}
