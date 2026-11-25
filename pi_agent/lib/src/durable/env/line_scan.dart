// Computes a `LineScan` from a file's bytes fed in order, so an environment can
// scan any size in bounded memory. Decoded sizes use the same streaming UTF-8
// decoder as decoding the whole file at once.
//
// Port of `packages/durable/src/env/line-scan.ts` at upstream
// `780bf31fcaeb252fa9b68df3964c735eae75bde3`.
library;

import 'dart:convert';

import 'decode.dart';

const int _newline = 0x0a;

/// UTF-8 byte length of decoded text.
int _decodedBytes(String text) => text.isEmpty ? 0 : utf8.encode(text).length;

/// The byte ranges and decoded sizes of a selected line range within a file.
class LineScan {
  /// Newline bytes in the whole file; it has [newlines] + 1 lines.
  final int newlines;

  /// Byte range of the selected lines: from the start of the first to the end of
  /// the last, without the newline that ends it. A selection past the last line
  /// is empty at the end of the file.
  final int start;

  /// The end of the selected range: the end of the last selected line, without
  /// its ending newline.
  final int end;

  /// Where the first selected line ends: its newline, or the end of the file.
  final int firstLineEnd;

  /// Where the last selected line starts.
  final int lastLineStart;

  /// UTF-8 byte length of the decoded selection.
  final int selectedBytes;

  /// UTF-8 byte length of the decoded first selected line.
  final int firstLineBytes;

  /// A scan result covering the whole file's newline count and the selected
  /// line range's byte offsets and decoded sizes.
  const LineScan({
    required this.newlines,
    required this.start,
    required this.end,
    required this.firstLineEnd,
    required this.lastLineStart,
    required this.selectedBytes,
    required this.firstLineBytes,
  });
}

/// Scans a file's bytes, pushed in order, for a line range in bounded memory.
class LineScanner {
  /// `endLine` absent (use [infinity]) means to the end of the file.
  static const int infinity = 0x7fffffffffffffff;

  final int _startLine;
  final int _endLine;
  int _position = 0;
  int _newlines = 0;
  int _lineStart = 0;
  int? _start;
  int? _end;
  int? _firstLineEnd;
  int? _lastLineStart;
  int _selectedBytes = 0;
  int _firstLineBytes = 0;
  RangeDecoder? _selection;
  RangeDecoder? _firstLine;

  /// The first bytes, held until it is known whether they are a byte-order mark.
  List<int>? _head = <int>[];
  bool _bom = false;

  /// [startLine] and [endLine] must be non-negative integers with
  /// `endLine > startLine`; [infinity] (the default) for [endLine]: to the end.
  LineScanner(int startLine, [int endLine = infinity])
      : _startLine = startLine,
        _endLine = endLine {
    if (startLine < 0 || !(endLine > startLine)) {
      throw RangeError('Invalid line range');
    }
    if (startLine == 0) _begin(0);
  }

  /// Feeds the next [chunk] of the file's bytes.
  void push(List<int> chunk) {
    final head = _head;
    if (head != null) {
      final take = _min(3 - head.length, chunk.length);
      head.addAll(chunk.sublist(0, take));
      if (head.length < 3) return;
      _releaseHead();
      chunk = chunk.sublist(take);
    }
    _process(chunk);
  }

  /// Finishes the scan and returns its [LineScan].
  LineScan finish() {
    if (_head != null) _releaseHead();
    final size = _position;
    final start = _start;
    if (start == null) {
      return LineScan(
        newlines: _newlines,
        start: size,
        end: size,
        firstLineEnd: size,
        lastLineStart: size,
        selectedBytes: 0,
        firstLineBytes: 0,
      );
    }
    if (_firstLineEnd == null) _endFirstLine(size);
    if (_end == null) _endSelection(size);
    return LineScan(
      newlines: _newlines,
      start: start,
      end: _end ?? size,
      firstLineEnd: _firstLineEnd ?? size,
      // A selection that reaches past the last line ends with the last line.
      lastLineStart: _lastLineStart ?? _lineStart,
      selectedBytes: _selectedBytes,
      firstLineBytes: _firstLineBytes,
    );
  }

  void _releaseHead() {
    final head = _head ?? <int>[];
    _head = null;
    _bom = startsWithBom(head);
    _process(head);
  }

  void _process(List<int> chunk) {
    final base = _position;
    var from = 0;
    for (var index = chunk.indexOf(_newline);
        index != -1;
        index = chunk.indexOf(_newline, index + 1)) {
      // The newline ends line `_newlines`. It belongs to the selection between
      // selected lines only.
      _feed(chunk, base, from, index);
      final line = _newlines;
      final position = base + index;
      if (line == _startLine) _endFirstLine(position);
      if (line == _endLine - 1) _endSelection(position);
      _feed(chunk, base, index, index + 1);
      from = index + 1;
      _newlines++;
      _lineStart = position + 1;
      if (_newlines == _startLine) _begin(_lineStart);
      if (_newlines == _endLine - 1) _lastLineStart = _lineStart;
    }
    _feed(chunk, base, from, chunk.length);
    _position += chunk.length;
  }

  void _begin(int start) {
    _start = start;
    if (_startLine == _endLine - 1) _lastLineStart = start;
    _selection = rangeDecoder();
    _firstLine = rangeDecoder();
  }

  void _endFirstLine(int position) {
    _firstLineEnd = position;
    final decoder = _firstLine;
    if (decoder != null) _firstLineBytes += _decodedBytes(decoder.decode());
    _firstLine = null;
  }

  void _endSelection(int position) {
    _end = position;
    final decoder = _selection;
    if (decoder != null) _selectedBytes += _decodedBytes(decoder.decode());
    _selection = null;
  }

  /// Feeds `chunk[from, to)`, which starts at file offset `base`, to the
  /// decoders of the ranges still open.
  void _feed(List<int> chunk, int base, int from, int to) {
    // Decoding the whole file drops a leading byte-order mark.
    if (_bom && base + from < 3) from = _min(to, 3 - base);
    if (to <= from) return;
    final bytes = chunk.sublist(from, to);
    final selection = _selection;
    if (selection != null) {
      _selectedBytes += _decodedBytes(selection.decode(bytes));
    }
    final firstLine = _firstLine;
    if (firstLine != null) {
      _firstLineBytes += _decodedBytes(firstLine.decode(bytes));
    }
  }
}

int _min(int a, int b) => a < b ? a : b;
