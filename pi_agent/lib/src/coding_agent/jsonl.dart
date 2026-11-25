// LF-only JSONL framing and reading in linear time.
//
// Faithful port of `packages/coding-agent/src/modes/rpc/jsonl.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b`. The behavioral change in this
// sync is #12451: only new text is scanned and an incomplete line is read once
// when it ends, so a large line arriving in many chunks costs time linear in
// its size (the previous implementation re-scanned the whole accumulated
// buffer on every chunk). Framing is LF-only: payload strings may contain other
// Unicode separators such as U+2028 and U+2029, so records split on `\n` only,
// never on a general Unicode line break. The #12224 guarantee is kept: a line
// is consumed from the buffer before its handler runs, so a handler that throws
// never leaves its line to be joined with the next one.

import 'dart:convert';

/// Serializes a single strict JSONL record.
///
/// Framing is LF-only. Payload strings may contain other Unicode separators such
/// as U+2028 and U+2029. Clients must split records on `\n` only.
String serializeJsonLine(Object? value) => '${jsonEncode(value)}\n';

/// Reads LF-only JSONL records from pushed text.
///
/// This intentionally does not split on arbitrary Unicode line separators:
/// those are valid inside JSON strings and would break strict JSONL framing.
/// Only new text is scanned on each [push], and an incomplete trailing line is
/// emitted once at [end].
class JsonlLineReader {
  /// Called for each complete line, with a trailing `\r` removed.
  void Function(String line)? onLine;

  String _buffer = '';

  /// Pushes newly arrived text, emitting every line it completes.
  void push(String text) {
    // Only the new text is scanned, so a long line arriving in many chunks is
    // not rescanned per chunk.
    var start = 0;
    for (var newlineIndex = text.indexOf('\n');
        newlineIndex != -1;
        newlineIndex = text.indexOf('\n', start)) {
      final line = _buffer + text.substring(start, newlineIndex);
      _buffer = '';
      start = newlineIndex + 1;
      _emit(line);
    }
    _buffer += text.substring(start);
  }

  /// Emits a final line that arrived without a trailing LF.
  void end() {
    final line = _buffer;
    _buffer = '';
    if (line.isNotEmpty) _emit(line);
  }

  void _emit(String line) {
    final handler = onLine;
    if (handler == null) return;
    handler(line.endsWith('\r') ? line.substring(0, line.length - 1) : line);
  }
}
