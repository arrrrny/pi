/// Render stored spans as a chronological forest.
///
/// Port of upstream `packages/telemetry/src/render.ts`. Control characters in
/// ids, names, attribute keys and error messages are escaped; attribute values
/// are JSON-encoded to match the upstream output byte for byte.
library;

import 'types.dart';

final RegExp _control = RegExp(r'[\u0000-\u001f\u007f-\u009f]');

String _escaped(String text) {
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    if (_control.hasMatch(String.fromCharCode(rune))) {
      buffer.write('\\u${rune.toRadixString(16).padLeft(4, '0')}');
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// Formats [value] the way JavaScript stringifies a number in this package's
/// outputs: integral values print without a fractional part.
String _jsNum(num value) {
  if (value is int) return value.toString();
  final d = value.toDouble();
  if (d.isFinite && d == d.truncateToDouble() && d.abs() < 1e21) {
    return d.toInt().toString();
  }
  return d.toString();
}

num _microseconds(num ms) => (ms * 1000).round() / 1000;

String _formatAttributes(SpanAttributes attributes) {
  final buffer = StringBuffer();
  attributes.forEach((key, value) {
    buffer.write(' ${_escaped(key)}=${_json(value)}');
  });
  return buffer.toString();
}

/// Encodes [value] as JSON the way JavaScript's `JSON.stringify` does for the
/// attribute value shapes this package carries (string, number, boolean, or a
/// homogeneous list of those).
String _json(Object? value) {
  if (value == null) return 'null';
  if (value is String) return _jsonString(value);
  if (value is num) return _jsonNumber(value);
  if (value is bool) return value ? 'true' : 'false';
  if (value is List) {
    final buffer = StringBuffer('[');
    for (var i = 0; i < value.length; i++) {
      if (i > 0) buffer.write(',');
      buffer.write(_json(value[i]));
    }
    buffer.write(']');
    return buffer.toString();
  }
  return _jsonString(value.toString());
}

String _jsonString(String text) {
  final buffer = StringBuffer('"');
  for (final rune in text.runes) {
    switch (rune) {
      case 0x22:
        buffer.write('\\"');
        break;
      case 0x5c:
        buffer.write('\\\\');
        break;
      case 0x08:
        buffer.write('\\b');
        break;
      case 0x0c:
        buffer.write('\\f');
        break;
      case 0x0a:
        buffer.write('\\n');
        break;
      case 0x0d:
        buffer.write('\\r');
        break;
      case 0x09:
        buffer.write('\\t');
        break;
      default:
        if (rune < 0x20) {
          buffer.write('\\u${rune.toRadixString(16).padLeft(4, '0')}');
        } else {
          buffer.writeCharCode(rune);
        }
    }
  }
  buffer.write('"');
  return buffer.toString();
}

String _jsonNumber(num value) => _jsNum(value);

/// Renders [spans] as a chronological forest, treating absent parents as roots.
///
/// Lengths of time are milliseconds to the microsecond. Control characters in
/// ids, names, attribute keys and error messages are escaped; attribute values
/// are JSON. Spans merged from stores are deduplicated by global id.
String renderTrace(List<StoredSpan> spans) {
  final byId = <String, StoredSpan>{};
  for (final span in spans) {
    byId[span.id] = span;
  }
  final roots = <StoredSpan>[];
  final children = <String, List<StoredSpan>>{};
  final ordered = [...byId.values]
    ..sort((left, right) => left.startedMs.compareTo(right.startedMs));
  for (final span in ordered) {
    final parentId = span.parentId;
    if (parentId == null || !byId.containsKey(parentId)) {
      roots.add(span);
    } else {
      children.putIfAbsent(parentId, () => []).add(span);
    }
  }

  final lines = <String>[];
  final pending = <({StoredSpan span, int depth})>[
    for (final span in roots.reversed) (span: span, depth: 0),
  ];
  while (pending.isNotEmpty) {
    final entry = pending.removeLast();
    final span = entry.span;
    final depth = entry.depth;
    final indent = '  ' * depth;
    var error = '';
    final status = span.status;
    if (status.isError) {
      error = ' error';
      final e = status.error;
      if (e != null) {
        error += ' ${_escaped(e.name)}: ${_escaped(e.message)}';
      }
    }
    lines.add(
      '$indent${_escaped(span.name)}${_formatAttributes(span.attributes)}'
      ' (${_jsNum(_microseconds(span.endedMs - span.startedMs))}ms)$error',
    );
    for (final event in span.events) {
      lines.add(
        '$indent  · ${_escaped(event.name)}'
        '${_formatAttributes(event.attributes)} (+${_jsNum(_microseconds(event.timeMs))}ms)',
      );
    }
    for (final link in span.links) {
      final ids =
          'trace ${_escaped(link.traceId)} span ${_escaped(link.spanId)}';
      lines.add(
          '$indent  → link $ids${_formatAttributes(link.attributes ?? {})}');
    }
    final descendants = children[span.id] ?? const [];
    for (var index = descendants.length - 1; index >= 0; index--) {
      pending.add((span: descendants[index], depth: depth + 1));
    }
  }
  return lines.join('\n');
}
