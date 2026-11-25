// Decoding that matches `new TextDecoder().decode(bytes)` of the whole input
// when the input arrives in pieces. Node's streaming decoder with BOM handling
// can drop a U+FEFF that follows a chunk boundary, not only a leading mark, so
// these decoders turn BOM handling off and drop a leading mark themselves.
//
// Port of `packages/durable/src/env/decode.ts` at upstream
// `780bf31fcaeb252fa9b68df3964c735eae75bde3`. Dart's `Utf8Decoder` strips a
// leading byte-order mark on every `convert` call, so it cannot express
// `ignoreBOM: true` streaming; [RangeDecoder] is the WHATWG UTF-8 decoder
// directly, carrying its state across chunks.
library;

/// A streaming UTF-8 decoder with byte-order-mark handling off, matching
/// `new TextDecoder("utf-8", { ignoreBOM: true })` fed chunk by chunk: an
/// incomplete multi-byte sequence at a chunk boundary is held in the decoder's
/// state until the rest arrives, and an invalid byte becomes U+FFFD.
class RangeDecoder {
  int _codePoint = 0;
  int _bytesSeen = 0;
  int _bytesNeeded = 0;
  int _lower = 0x80;
  int _upper = 0xbf;
  final StringBuffer _out = StringBuffer();

  /// Text for [bytes], holding back an incomplete character; without [bytes],
  /// the end of the stream, which emits U+FFFD for a dangling sequence.
  String decode([List<int>? bytes]) {
    _out.clear();
    if (bytes == null) {
      if (_bytesNeeded != 0) {
        _reset();
        _out.writeCharCode(0xfffd);
      }
      return _out.toString();
    }
    for (final byte in bytes) {
      _handle(byte);
    }
    return _out.toString();
  }

  void _reset() {
    _codePoint = 0;
    _bytesSeen = 0;
    _bytesNeeded = 0;
    _lower = 0x80;
    _upper = 0xbf;
  }

  void _handle(int byte) {
    if (_bytesNeeded == 0) {
      if (byte <= 0x7f) {
        _out.writeCharCode(byte);
        return;
      }
      if (byte >= 0xc2 && byte <= 0xdf) {
        _bytesNeeded = 1;
        _codePoint = byte & 0x1f;
        return;
      }
      if (byte >= 0xe0 && byte <= 0xef) {
        if (byte == 0xe0) {
          _lower = 0xa0;
          _upper = 0xbf;
        } else if (byte == 0xed) {
          _lower = 0x80;
          _upper = 0x9f;
        } else {
          _lower = 0x80;
          _upper = 0xbf;
        }
        _bytesNeeded = 2;
        _codePoint = byte & 0x0f;
        return;
      }
      if (byte >= 0xf0 && byte <= 0xf4) {
        if (byte == 0xf0) {
          _lower = 0x90;
          _upper = 0xbf;
        } else if (byte == 0xf4) {
          _lower = 0x80;
          _upper = 0x8f;
        } else {
          _lower = 0x80;
          _upper = 0xbf;
        }
        _bytesNeeded = 3;
        _codePoint = byte & 0x07;
        return;
      }
      // 0x80-0xC1 and 0xF5-0xFF are never a lead byte.
      _out.writeCharCode(0xfffd);
      return;
    }
    if (byte < _lower || byte > _upper) {
      // A byte outside the expected continuation range ends the sequence in
      // U+FFFD and is reprocessed as a fresh byte.
      _reset();
      _out.writeCharCode(0xfffd);
      _handle(byte);
      return;
    }
    _lower = 0x80;
    _upper = 0xbf;
    _codePoint = (_codePoint << 6) | (byte & 0x3f);
    _bytesSeen++;
    if (_bytesSeen == _bytesNeeded) {
      _out.writeCharCode(_codePoint);
      _reset();
    }
  }
}

/// A streaming decoder for a byte range; callers that start at the beginning of
/// a file skip a leading mark themselves.
RangeDecoder rangeDecoder() => RangeDecoder();

/// Whether decoding the whole input drops its first three bytes as a byte-order
/// mark.
bool startsWithBom(List<int> firstBytes) =>
    firstBytes.length >= 3 &&
    firstBytes[0] == 0xef &&
    firstBytes[1] == 0xbb &&
    firstBytes[2] == 0xbf;

/// Decodes one stream chunk by chunk exactly like decoding all of it at once,
/// dropping a single leading byte-order mark.
class StreamDecoder {
  final RangeDecoder _decoder = RangeDecoder();
  bool _started = false;

  /// Text for [bytes], holding back an incomplete character; without [bytes],
  /// the end of the stream.
  String decode([List<int>? bytes]) {
    final text = _decoder.decode(bytes);
    if (_started || text.isEmpty) return text;
    _started = true;
    // U+FEFF encodes only as EF BB BF, so a leading U+FEFF is exactly a mark.
    return text.startsWith('\ufeff') ? text.substring(1) : text;
  }
}
