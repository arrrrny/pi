/// Names of MCP tools and of their servers' namespaces, and the servers'
/// one-line summaries, as models and code mode scripts see them.
///
/// Dart port of `packages/mcp/src/naming.ts` at the registry-pinned SHA.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Provider tool names are limited to 64 characters of `[A-Za-z0-9_-]`.
const int _maxToolNameLength = 64;

/// `mcp__<server>__<tool>`, sanitized and shortened with a hash suffix when
/// too long. Like Codex, everything but `[A-Za-z0-9_]` becomes `_`, so the
/// name is also the identifier code mode scripts call it by. [isTaken]
/// reports names used by a different MCP tool: sanitizing can map two tools
/// to one name (`a-b` and `a_b`), which then get the hash suffix.
String createMcpToolName(
  String server,
  String tool, [
  bool Function(String name)? isTaken,
]) {
  final name = 'mcp__${server}__$tool'.replaceAll(
    RegExp(r'[^A-Za-z0-9_]'),
    '_',
  );
  if (name.length <= _maxToolNameLength &&
      (isTaken == null || !isTaken(name))) {
    return name;
  }
  final hash = sha256
      .convert(utf8.encode('$server\u0000$tool'))
      .toString()
      .substring(0, 8);
  final keep = _maxToolNameLength - hash.length - 1;
  final prefix = name.length <= keep ? name : name.substring(0, keep);
  return '${prefix}_$hash';
}

/// Namespace of a server's tools: `mcp__<server>` with `-` replaced by `_`,
/// like the tool names. Server names that differ only in `-` and `_` share a
/// namespace, so a configuration must not have both.
String mcpNamespace(String server) => 'mcp__${server.replaceAll('-', '_')}';

/// A server's one-line summary for the system prompt: the first line of its
/// configured [description], else of the [instructions] it sent in
/// `initialize`; empty when it has neither.
String mcpServerSummary(String? description, String? instructions) {
  final text = (description?.trim().isNotEmpty ?? false)
      ? description!.trim()
      : (instructions?.trim() ?? '');
  final firstLine = text.split('\n').first;
  return firstLine.trim();
}
