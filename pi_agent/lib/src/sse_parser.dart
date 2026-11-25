/// SSE (Server-Sent Events) stream parser.
library;

import 'dart:async';
import 'dart:convert';

/// Default cap for one SSE event in bytes, matching the MCP Streamable HTTP
/// transport's `DEFAULT_MAX_MESSAGE_BYTES` (16 MiB,
/// `packages/mcp/src/transports/transport.ts`).
const int defaultMaxSseEventBytes = 16 * 1024 * 1024;

/// Parses a byte stream into SSE events.
///
/// Each event is emitted as a map with optional keys: `data`, `event`, `id`, `retry`.
/// Handles multi-line data, comment lines (starting with `:`), and chunked input.
/// Lines end with CRLF, LF, or a lone CR, including a CRLF split across chunks.
///
/// Only the new text of each chunk is searched for line terminators and the
/// incomplete last line is read once when it ends, so a large event arriving
/// in many chunks costs time linear in its size (upstream #12451).
///
/// [maxEventBytes] caps one event in UTF-8 bytes, as the MCP Streamable HTTP
/// transport's `consumeSseStream` does: the incomplete line's bytes are
/// counted as they arrive and a line that crosses the limit is rejected
/// before its line ending arrives, as is an event whose joined `data` lines
/// cross the limit before the event dispatches. `null` (the default) leaves
/// the stream uncapped.
Stream<Map<String, String>> parseSSE(Stream<List<int>> byteStream,
    {int? maxEventBytes}) {
  return byteStream
      .transform(utf8.decoder)
      .transform(_sseLineScanner(maxEventBytes: maxEventBytes))
      .transform(_sseEvents(maxEventBytes: maxEventBytes));
}

/// Splits decoded SSE text into lines, terminating on CRLF, LF, or a lone CR.
///
/// The incomplete last line is kept append-only and read once when it ends;
/// its UTF-8 byte size is counted as it grows so a line that never ends is
/// rejected at [maxEventBytes] instead of growing without bound.
StreamTransformer<String, String> _sseLineScanner({int? maxEventBytes}) {
  final pendingLine = StringBuffer();
  var pendingLineBytes = 0;
  // A CR that ended a chunk may be the first half of a CRLF; drop the LF when
  // the next chunk provides it.
  var skipLeadingLf = false;
  var closed = false;

  void fail(StateError error, EventSink<String> sink) {
    closed = true;
    sink.addError(error);
    sink.close();
  }

  void consumeLines(String text, EventSink<String> sink) {
    var start = 0;
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char != '\r' && char != '\n') continue;
      sink.add('$pendingLine${text.substring(start, i)}');
      pendingLine.clear();
      pendingLineBytes = 0;
      if (char == '\r') {
        if (i + 1 < text.length) {
          if (text[i + 1] == '\n') i++;
        } else {
          skipLeadingLf = true;
        }
      }
      start = i + 1;
    }
    final rest = text.substring(start);
    pendingLine.write(rest);
    pendingLineBytes += utf8.encode(rest).length;
  }

  return StreamTransformer<String, String>.fromHandlers(
    handleData: (String text, EventSink<String> sink) {
      if (closed) return;
      try {
        if (skipLeadingLf && text.isNotEmpty) {
          if (text.startsWith('\n')) text = text.substring(1);
          skipLeadingLf = false;
        }
        consumeLines(text, sink);
        if (maxEventBytes != null && pendingLineBytes > maxEventBytes) {
          fail(StateError('MCP SSE event exceeds $maxEventBytes bytes'), sink);
        }
      } catch (error) {
        fail(error is StateError ? error : StateError(error.toString()), sink);
      }
    },
    handleDone: (EventSink<String> sink) {
      if (closed) return;
      if (pendingLine.isNotEmpty) {
        sink.add(pendingLine.toString());
        pendingLine.clear();
        pendingLineBytes = 0;
      }
      sink.close();
    },
  );
}

/// Assembles SSE lines into events, mirroring the MCP Streamable HTTP
/// transport's field handling: multi-line `data` joined with "\n", comments
/// skipped, the event's `id` scoped to the dispatched event.
///
/// Bytes of the pending event's data, including the "\n" joins, are counted
/// as `data` lines arrive, so an event streamed as many short `data:` lines
/// without a terminating blank line cannot grow past [maxEventBytes].
StreamTransformer<String, Map<String, String>> _sseEvents(
    {int? maxEventBytes}) {
  final dataBuffer = StringBuffer();
  var dataBytes = 0;
  var eventType = '';
  String? lastEventId;
  String? retry;
  var closed = false;

  void dispatch(EventSink<Map<String, String>> sink) {
    if (dataBuffer.isEmpty) {
      eventType = '';
      lastEventId = null;
      return;
    }
    final event = <String, String>{'data': dataBuffer.toString()};
    if (eventType.isNotEmpty) event['event'] = eventType;
    if (lastEventId != null) event['id'] = lastEventId!;
    if (retry != null) event['retry'] = retry!;
    sink.add(event);
    dataBuffer.clear();
    dataBytes = 0;
    eventType = '';
    lastEventId = null;
  }

  return StreamTransformer<String, Map<String, String>>.fromHandlers(
    handleData: (String line, EventSink<Map<String, String>> sink) {
      if (closed) return;
      try {
        if (line.isEmpty) {
          dispatch(sink);
          return;
        }

        if (line.startsWith(':')) return;

        if (line.startsWith('data:')) {
          final data = line.substring(5);
          final trimmed = data.startsWith(' ') ? data.substring(1) : data;
          if (dataBuffer.isNotEmpty) {
            dataBuffer.write('\n');
            dataBytes += 1;
          }
          dataBuffer.write(trimmed);
          dataBytes += utf8.encode(trimmed).length;
          if (maxEventBytes != null && dataBytes > maxEventBytes) {
            closed = true;
            sink.addError(
                StateError('MCP SSE event exceeds $maxEventBytes bytes'));
            sink.close();
          }
        } else if (line.startsWith('event:')) {
          eventType = line.substring(6).trim();
        } else if (line.startsWith('id:')) {
          lastEventId = line.substring(3).trim();
        } else if (line.startsWith('retry:')) {
          retry = line.substring(6).trim();
        }
      } catch (error) {
        closed = true;
        sink.addError(error);
        sink.close();
      }
    },
    handleDone: (EventSink<Map<String, String>> sink) {
      if (closed) return;
      dispatch(sink);
      sink.close();
    },
  );
}
