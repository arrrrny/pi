// Streaming server-sent-event decoding in linear time.
//
// Faithful port of `packages/ai/src/utils/sse.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b`. The behavioral change in this
// sync is #12451: only new text is scanned and an incomplete line is read once
// when it ends, so a large event arriving in many chunks costs time linear in
// its size (the previous implementation re-scanned the whole accumulated
// buffer on every chunk). Bytes are decoded through a streaming UTF-8 converter
// so a multibyte character split across chunks is reassembled, matching the
// upstream `TextDecoder(..., {stream:true})` behavior.

import 'dart:convert';

/// One server-sent event: its `event` field, its `data` lines joined by "\n",
/// and its raw lines for diagnostics.
class ServerSentEvent {
  /// The event name, or null when the event carried none.
  final String? event;

  /// The `data` field lines joined by "\n".
  final String data;

  /// The raw field lines that made up this event (comments included).
  final List<String> raw;

  /// Creates a decoded event.
  const ServerSentEvent({
    required this.event,
    required this.data,
    required this.raw,
  });

  @override
  String toString() => 'ServerSentEvent(event: $event, data: $data, raw: $raw)';

  @override
  bool operator ==(Object other) =>
      other is ServerSentEvent &&
      other.event == event &&
      other.data == data &&
      _listEquals(other.raw, raw);

  @override
  int get hashCode => Object.hash(event, data, Object.hashAll(raw));

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Decodes server-sent events from a UTF-8 byte stream.
///
/// Lines end with LF, CRLF or CR, and a blank line ends an event. Only new text
/// is scanned, and an incomplete line is read once when it ends.
class SseDecoder {
  /// The incomplete last line, held as fragments so a line delivered in many
  /// chunks joins only once when it completes (#12451 linear-time guarantee;
  /// repeated `+=` on an immutable string would copy the whole line per chunk).
  final List<String> _pendingParts = <String>[];

  /// The last text ended with CR, so a leading LF of the next text completes it.
  bool _skipLeadingLf = false;

  String? _event;
  final List<String> _data = <String>[];
  final List<String> _raw = <String>[];

  /// Events completed by the most recent [push] / [end] call.
  final List<ServerSentEvent> _emitted = <ServerSentEvent>[];

  final _EventSink _eventSink;
  late final ByteConversionSink _byteSink;

  /// Creates a decoder.
  SseDecoder() : _eventSink = _EventSink() {
    _eventSink._owner = this;
    _byteSink = utf8.decoder.startChunkedConversion(_eventSink);
  }

  /// Takes the next bytes and returns the events they complete.
  List<ServerSentEvent> push(List<int> bytes) {
    _emitted.clear();
    _byteSink.add(bytes);
    return List<ServerSentEvent>.unmodifiable(_emitted);
  }

  /// Ends the stream and returns the remaining events, including a last one the
  /// stream ended without a blank line.
  List<ServerSentEvent> end() {
    _emitted.clear();
    _byteSink.close();
    if (_pendingParts.isNotEmpty) {
      final line = _pendingParts.join();
      _pendingParts.clear();
      _decodeLine(line);
    }
    _skipLeadingLf = false;
    final last = _flush();
    if (last != null) _emitted.add(last);
    return List<ServerSentEvent>.unmodifiable(_emitted);
  }

  void _acceptText(String text) {
    var start = _skipLeadingLf && text.startsWith('\n') ? 1 : 0;
    if (text.isNotEmpty) _skipLeadingLf = false;
    var i = start;
    while (i < text.length) {
      final char = text[i];
      if (char != '\r' && char != '\n') {
        i++;
        continue;
      }
      final event = _decodeLine(
        (_pendingParts..add(text.substring(start, i))).join(),
      );
      _pendingParts.clear();
      if (event != null) _emitted.add(event);
      if (char == '\r') {
        if (i + 1 == text.length) {
          _skipLeadingLf = true;
        } else if (text[i + 1] == '\n') {
          i++;
        }
      }
      start = i + 1;
      i++;
    }
    if (start < text.length) _pendingParts.add(text.substring(start));
  }

  ServerSentEvent? _decodeLine(String line) {
    if (line.isEmpty) return _flush();
    _raw.add(line);
    if (line.startsWith(':')) return null;
    final colon = line.indexOf(':');
    final field = colon == -1 ? line : line.substring(0, colon);
    var value = colon == -1 ? '' : line.substring(colon + 1);
    if (value.startsWith(' ')) value = value.substring(1);
    if (field == 'event') {
      _event = value;
    } else if (field == 'data') {
      _data.add(value);
    }
    return null;
  }

  ServerSentEvent? _flush() {
    if ((_event == null || _event!.isEmpty) && _data.isEmpty) {
      _event = null;
      _raw.clear();
      return null;
    }
    final event = ServerSentEvent(
      event: _event,
      data: _data.join('\n'),
      raw: List<String>.of(_raw),
    );
    _event = null;
    _data.clear();
    _raw.clear();
    return event;
  }
}

/// Bridges decoded UTF-8 text chunks back into the owning [SseDecoder].
class _EventSink extends StringConversionSink {
  late SseDecoder _owner;

  @override
  void add(String chunk) => _owner._acceptText(chunk);

  @override
  void addSlice(String chunk, int start, int end, bool isLast) {
    add(chunk.substring(start, end));
    if (isLast) close();
  }

  @override
  void close() {}
}
