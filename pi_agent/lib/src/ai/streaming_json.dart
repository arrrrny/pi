// Incremental, tolerant JSON parsing and streaming tool-call arguments.
//
// Port of `packages/ai/src/utils/streaming-json.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b`. A provider streams a tool call's
// arguments as partial JSON text; this parser turns the text read so far into
// plain JSON values without ever throwing, and `ToolCallArgumentsStream` keeps
// the raw text so the one authoritative parse happens once, when the call ends
// (`parseToolCallArguments` from `json_parse.dart`).
//
// Parser rules (module comment upstream): output is always plain JSON; a
// container only completes when its closer arrives; the text read so far is a
// prefix, so an unfinished string or number shows its best-effort value; a
// snapshot may lag behind the text by a small copy credit to keep big
// documents cheap (see `snapshot()`).

import '../json_parse.dart';

/// A JSON path into the value read so far, one step per container level.
typedef JsonPath = List<dynamic>;

/// One change the newly appended text made to the value: a `set` (first value
/// or replacement) or an `append` (string characters added) at `path`.
sealed class JsonChange {
  /// The path the change happened at.
  final JsonPath path;

  /// Creates a change record.
  const JsonChange(this.path);

  @override
  bool operator ==(Object other) =>
      other is JsonChange &&
      other.kind == kind &&
      _deepEquals(other.path, path) &&
      _deepEquals(other.changeValue, changeValue);

  @override
  int get hashCode =>
      Object.hash(kind, Object.hashAll(path.map(_canonicalHash)));

  /// The discriminator of this change kind: `"set"` or `"append"`.
  String get kind;

  /// The payload of the change: the new value for `set`, the added text for
  /// `append`. Null when the change carries no payload.
  Object? get changeValue;
}

/// A value was set (or replaced) at [path].
class JsonSet extends JsonChange {
  /// The value now sitting at the path.
  Object? value;

  /// Creates a set change.
  JsonSet(super.path, this.value);

  @override
  String get kind => 'set';

  @override
  Object? get changeValue => value;

  @override
  String toString() => 'JsonSet($path, $value)';
}

/// String characters were appended to the string at [path].
class JsonAppend extends JsonChange {
  /// The characters the appended text added.
  String text;

  /// Creates an append change.
  JsonAppend(super.path, this.text);

  @override
  String get kind => 'append';

  @override
  Object? get changeValue => text;

  @override
  String toString() => 'JsonAppend($path, $text)';
}

/// Where a value starting now lands.
sealed class _Slot {
  const _Slot();
}

class _RootSlot extends _Slot {
  const _RootSlot();
}

class _ElementSlot extends _Slot {
  final int index;
  const _ElementSlot(this.index);
}

class _MemberSlot extends _Slot {
  final String key;
  const _MemberSlot(this.key);
}

/// One open container on the parser's stack.
class _Frame {
  final Object container; // Map<String, dynamic> or List<dynamic>
  final _Slot? slot;
  final JsonPath? path;
  final bool reportsInside;
  int size;
  String? key;

  /// What the frame expects next inside itself: a `key`, the `colon` after it,
  /// a `value`, or the `comma` after a completed member.
  String phase;
  _Frame({
    required this.container,
    required this.slot,
    required this.path,
    required this.reportsInside,
    required this.phase,
  })  : size = 0,
        key = null;
}

/// An unterminated string.
class _OpenString {
  final String target; // "key" or "value"
  final _Slot? slot;
  String text;

  /// Escape read so far: "" for none, otherwise a backslash and up to five
  /// more characters.
  String escape;

  /// Where a value string sits, when its changes are reported.
  final JsonPath? path;

  /// The change this string extends, while it is the newest change.
  JsonChange? change;
  _OpenString({
    required this.target,
    required this.slot,
    required this.path,
  })  : text = '',
        escape = '';
}

/// Changes are reported at most this deep, so a path costs O(1) to build.
const int _maxReportedDepth = 32;

final _RootSlot _rootSlot = const _RootSlot();

/// Copy credit per append and per appended character. The floor keeps small
/// documents fresh at every snapshot.
const int _creditPerAppend = 256;
const int _creditPerCharacter = 8;

/// An unterminated number longer than this is not shown until it ends, so
/// [StreamingJsonParser.snapshot] stays cheap.
const int _maxPendingScalarLength = 64;

final RegExp _number = RegExp(r'^-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?$');
final RegExp _numberWithoutExponentDigits =
    RegExp(r'^(-?(?:0|[1-9]\d*)(?:\.\d+)?)[eE][+-]?$');

const List<(String, Object?)> _literals = [
  ('true', true),
  ('false', false),
  ('null', null),
];

const int _quote = 0x22;
const int _backslash = 0x5c;

const Map<String, String> _simpleEscapes = {
  '"': '"',
  r'\': r'\',
  '/': '/',
  'b': '\b',
  'f': '\f',
  'n': '\n',
  'r': '\r',
  't': '\t',
};

/// Incremental, tolerant JSON parser. See the library comment for its rules.
class StreamingJsonParser {
  Object? _root;
  bool _done = false;
  final List<_Frame> _stack = <_Frame>[];
  _OpenString? _string;
  String _scalar = '';
  _Slot? _scalarSlot;

  /// Sum of `size + 1` over the open path: what a fresh snapshot copies.
  int _pathCost = 0;
  int _credit = 0;
  bool _dirty = false;
  Object? _snapshot;

  /// Changes of the piece being read.
  List<JsonChange> _changes = <JsonChange>[];

  /// Read the next piece of [text]; returns the changes it made, in order.
  /// Costs time linear in `text.length`.
  List<JsonChange> append(String text) {
    _credit += _creditPerAppend + _creditPerCharacter * text.length;
    _changes = <JsonChange>[];
    if (_string != null) _string!.change = null;
    var index = 0;
    while (index < text.length && !_done) {
      final open = _string;
      if (open != null) {
        index = _readString(open, text, index);
      } else if (_scalar.isNotEmpty) {
        index = _readScalar(text, index);
      } else {
        _structural(text[index]);
        index++;
      }
    }
    return List<JsonChange>.unmodifiable(_changes);
  }

  /// The value of the text read so far: null before a value starts, otherwise
  /// a plain JSON value that never changes afterwards. Returns the previous
  /// snapshot while the text read since did not change the value, or while a
  /// fresh copy of the open path is not yet paid for (the copy credit).
  Object? snapshot() {
    if (!_dirty) return _snapshot;
    final pending = _pendingScalar();
    final cost = _pathCost + (pending == null ? 0 : 1);
    if (cost > _credit) return _snapshot;
    _credit -= cost;
    _dirty = false;
    _snapshot = _copyOpenPath(pending);
    return _snapshot;
  }

  /// Read string characters from [start] until the string ends or the text
  /// does; returns the next index.
  int _readString(_OpenString open, String text, int start) {
    var runStart = start;
    for (var index = start; index < text.length; index++) {
      final code = text.codeUnitAt(index);
      if (open.escape.isNotEmpty) {
        if (_continueEscape(open, text[index])) {
          runStart = index + 1;
          continue;
        }
        // Not part of the escape: read it as a normal string character below.
        runStart = index;
      }
      if (code == _quote) {
        if (index > runStart) {
          _appendString(open, text.substring(runStart, index));
        }
        _endString(open);
        return index + 1;
      }
      if (code == _backslash) {
        if (index > runStart) {
          _appendString(open, text.substring(runStart, index));
        }
        open.escape = r'\';
        runStart = index + 1;
      }
    }
    if (text.length > runStart) _appendString(open, text.substring(runStart));
    return text.length;
  }

  /// Read number or literal characters from [start] up to the next delimiter;
  /// returns the delimiter's index.
  int _readScalar(String text, int start) {
    var end = start;
    while (end < text.length && !_isDelimiter(text[end])) {
      end++;
    }
    if (end > start) {
      _scalar += text.substring(start, end);
      if (_scalarSlot != null) _dirty = true;
    }
    if (end < text.length) _endScalar();
    return end;
  }

  /// Handle one character outside strings.
  void _structural(String char) {
    switch (char) {
      case ' ' || '\t' || '\n' || '\r':
        return;
      case '"':
        _startString();
        return;
      case '{' || '[':
        _openContainer(char == '{' ? <String, dynamic>{} : <dynamic>[]);
        return;
      case '}' || ']':
        _closeContainer();
        return;
      case ':':
        final frame = _stack.isEmpty ? null : _stack.last;
        if (frame != null &&
            frame.container is! List &&
            frame.phase == 'colon') {
          frame.phase = 'value';
        }
        return;
      case ',':
        final frame = _stack.isEmpty ? null : _stack.last;
        if (frame != null) {
          frame.phase = frame.container is List ? 'value' : 'key';
        }
        return;
      default:
        _scalar = char;
        _scalarSlot = _valueSlot();
        if (_scalarSlot != null) _dirty = true;
    }
  }

  /// Where a value starting now goes, or null when this position takes no
  /// value.
  _Slot? _valueSlot() {
    final frame = _stack.isEmpty ? null : _stack.last;
    if (frame == null) return _root == null ? _rootSlot : null;
    if (frame.container is List) {
      return _ElementSlot((frame.container as List).length);
    }
    // A missing colon is tolerated: `{"a" 1}` reads as `{"a": 1}`.
    if ((frame.phase == 'value' || frame.phase == 'colon') &&
        frame.key != null) {
      return _MemberSlot(frame.key!);
    }
    return null;
  }

  void _startString() {
    final frame = _stack.isEmpty ? null : _stack.last;
    // A missing comma is tolerated: `{"a": 1 "b": 2}` reads the second member.
    if (frame != null &&
        frame.container is! List &&
        (frame.phase == 'key' || frame.phase == 'comma')) {
      _string = _OpenString(target: 'key', slot: null, path: null);
      return;
    }
    final slot = _valueSlot();
    final path = _reportedPath(slot);
    _string = _OpenString(target: 'value', slot: slot, path: path);
    _place(slot, '');
    if (path != null) {
      _string!.change = _report(JsonSet(path, ''));
    }
  }

  /// The path of a value at [slot] in the innermost open container, when its
  /// changes are reported.
  JsonPath? _reportedPath(_Slot? slot) {
    if (slot == null) return null;
    if (slot is _RootSlot) return <dynamic>[];
    final frame = _stack.last;
    if (!frame.reportsInside) return null;
    return <dynamic>[
      ...?frame.path,
      slot is _MemberSlot ? slot.key : (slot as _ElementSlot).index,
    ];
  }

  JsonChange _report(JsonChange change) {
    _changes.add(change);
    return change;
  }

  /// Continue an escape with [char]; returns false when [char] is not part of
  /// it and must be read normally.
  bool _continueEscape(_OpenString open, String char) {
    if (open.escape == r'\') {
      final decoded = _simpleEscapes[char];
      if (decoded != null) {
        open.escape = '';
        _appendString(open, decoded);
        return true;
      }
      if (char == 'u') {
        open.escape = r'\u';
        return true;
      }
      // Invalid escape: keep the backslash as text and read the character
      // normally, as repairJson() does.
      open.escape = '';
      _appendString(open, r'\');
      return false;
    }
    if (_isHexDigit(char)) {
      open.escape += char;
      if (open.escape.length < 6) return true;
      final decoded = String.fromCharCode(
        int.parse(open.escape.substring(2), radix: 16),
      );
      open.escape = '';
      _appendString(open, decoded);
      return true;
    }
    // `\u` without four hex digits: keep it as text and read the character
    // normally, as repairJson() does.
    final literal = open.escape;
    open.escape = '';
    _appendString(open, literal);
    return false;
  }

  void _appendString(_OpenString open, String text) {
    open.text += text;
    if (open.target != 'value') return;
    _place(open.slot, open.text);
    if (open.path == null) return;
    // Extend this string's newest change while nothing came after it;
    // otherwise report an append.
    final change = open.change;
    if (change != null &&
        (_changes.isEmpty || identical(_changes.last, change))) {
      if (change is JsonSet) {
        change.value = (change.value as String) + text;
      } else if (change is JsonAppend) {
        change.text += text;
      }
      return;
    }
    open.change = _report(JsonAppend(open.path!, text));
  }

  void _endString(_OpenString open) {
    _string = null;
    final frame = _stack.isEmpty ? null : _stack.last;
    if (open.target == 'key') {
      if (frame == null) return;
      frame.key = open.text;
      frame.phase = 'colon';
      return;
    }
    _valueEnded(frame);
  }

  void _endScalar() {
    final token = _scalar;
    final slot = _scalarSlot;
    _scalar = '';
    _scalarSlot = null;
    final value = _scalarValue(token);
    if (value != null || token == 'null') {
      _place(slot, value);
      final path = _reportedPath(slot);
      if (path != null) _report(JsonSet(path, value));
    }
    _valueEnded(_stack.isEmpty ? null : _stack.last);
  }

  /// The value of the unterminated scalar at the end of the text, if it shows.
  (_Slot, Object?)? _pendingScalar() {
    final slot = _scalarSlot;
    final token = _scalar;
    if (slot == null ||
        token.isEmpty ||
        token.length > _maxPendingScalarLength) {
      return null;
    }
    final value = _pendingScalarValue(token);
    return value == null && !_pendingIsNull(token) ? null : (slot, value);
  }

  void _openContainer(Object container) {
    final slot = _valueSlot();
    final path = _reportedPath(slot);
    _place(slot, container);
    _stack.add(_Frame(
      container: container,
      slot: slot,
      path: path,
      reportsInside: path != null && path.length < _maxReportedDepth,
      phase: container is List ? 'value' : 'key',
    ));
    _pathCost += 1;
    _dirty = true;
    // A fresh container: the working one keeps changing, and a change never
    // does.
    if (path != null) {
      _report(
          JsonSet(path, container is List ? <dynamic>[] : <String, dynamic>{}));
    }
  }

  void _closeContainer() {
    if (_stack.isEmpty) return;
    final frame = _stack.removeLast();
    _pathCost -= frame.size + 1;
    _dirty = true;
    // Too deep to report inside: the whole value, final now that it is closed.
    if (frame.path != null && !frame.reportsInside) {
      _report(JsonSet(frame.path!, frame.container));
    }
    _valueEnded(_stack.isEmpty ? null : _stack.last);
  }

  /// A value in [frame], or the root value when there is no frame, has ended.
  void _valueEnded(_Frame? frame) {
    if (frame == null) {
      // Text after the root value is ignored, but only once a root value
      // exists.
      if (_root != null) _done = true;
      return;
    }
    frame.phase = 'comma';
  }

  /// Set the value at [slot] in the open path; nothing for a value in an
  /// invalid position.
  void _place(_Slot? slot, Object? value) {
    if (slot == null) return;
    _dirty = true;
    if (slot is _RootSlot) {
      _root = value;
      return;
    }
    final frame = _stack.last;
    if (slot is _ElementSlot) {
      final elements = frame.container as List;
      if (slot.index == elements.length) {
        frame.size++;
        _pathCost++;
      }
      if (slot.index < elements.length) {
        elements[slot.index] = value;
      } else {
        elements.add(value);
      }
      return;
    }
    final members = frame.container as Map<String, dynamic>;
    if (!members.containsKey((slot as _MemberSlot).key)) {
      frame.size++;
      _pathCost++;
    }
    members[slot.key] = value;
  }

  /// A fresh snapshot: copies of the open containers, innermost first, each
  /// holding the copy of its open child.
  Object? _copyOpenPath((_Slot, Object?)? pending) {
    if (_stack.isEmpty) {
      if (pending != null && pending.$1 is _RootSlot) return pending.$2;
      return _root;
    }
    Object? child;
    _Slot? childSlot;
    for (var depth = _stack.length - 1; depth >= 0; depth--) {
      final frame = _stack[depth];
      final container = frame.container;
      final Object copy;
      if (container is List) {
        copy = List<dynamic>.from(container);
      } else {
        copy = Map<String, dynamic>.from(container as Map<String, dynamic>);
      }
      if (depth == _stack.length - 1 && pending != null) {
        _setSlot(copy, pending.$1, pending.$2);
      }
      if (child != null && childSlot != null) _setSlot(copy, childSlot, child);
      child = copy;
      childSlot = frame.slot;
    }
    // The outermost open container is the root unless it sits in an invalid
    // position.
    return childSlot is _RootSlot ? child : _root;
  }
}

/// The arguments of one streaming tool call: the raw text, for the one full
/// parse when the call ends, and a [StreamingJsonParser] for the partial
/// arguments in between. Providers keep one per call in their own stream
/// state, never on the content block, so the raw text never reaches partial
/// messages or transcripts.
class ToolCallArgumentsStream {
  String _text = '';
  StreamingJsonParser _parser = StreamingJsonParser();
  Object? _snapshot;
  Map<String, dynamic> _arguments = <String, dynamic>{};

  /// The raw argument text received so far.
  String get text => _text;

  /// Append a piece of argument text; returns the partial arguments, a new
  /// object whenever they changed.
  Map<String, dynamic> append(String delta) {
    _text += delta;
    _parser.append(delta);
    return _partial();
  }

  /// Take the provider's complete argument [text]. When it continues the text
  /// so far, returns the missing piece as `delta`; otherwise starts over with
  /// [text]. Either way returns the partial arguments of [text].
  ({String? delta, Map<String, dynamic> arguments}) replace(String text) {
    if (text.startsWith(_text)) {
      final delta = text.substring(_text.length);
      return (
        delta: delta,
        arguments: delta.isEmpty ? _partial() : append(delta),
      );
    }
    _text = '';
    _parser = StreamingJsonParser();
    return (delta: null, arguments: append(text));
  }

  /// The final arguments: one full parse of the complete text, which reports
  /// malformed arguments.
  ParsedToolArguments finish() => parseToolCallArguments(_text);

  Map<String, dynamic> _partial() {
    final snapshot = _parser.snapshot();
    if (identical(snapshot, _snapshot)) return _arguments;
    _snapshot = snapshot;
    // Tool arguments are an object; any other partial value shows as no
    // arguments yet.
    _arguments =
        snapshot is Map<String, dynamic> ? snapshot : <String, dynamic>{};
    return _arguments;
  }
}

bool _isDelimiter(String char) =>
    char == ' ' ||
    char == '\t' ||
    char == '\n' ||
    char == '\r' ||
    char == ',' ||
    char == ':' ||
    char == '{' ||
    char == '}' ||
    char == '[' ||
    char == ']' ||
    char == '"';

bool _isHexDigit(String char) =>
    (char.compareTo('0') >= 0 && char.compareTo('9') <= 0) ||
    (char.compareTo('a') >= 0 && char.compareTo('f') <= 0) ||
    (char.compareTo('A') >= 0 && char.compareTo('F') <= 0);

/// The value of a complete number or literal token; null for anything else,
/// which is dropped.
Object? _scalarValue(String token) {
  for (final (literal, value) in _literals) {
    if (token == literal) return value;
  }
  if (_number.hasMatch(token)) return _parseJsonNumber(token);
  return null;
}

/// Whether [token] is the beginning of the `null` literal.
bool _pendingIsNull(String token) => 'null'.startsWith(token);

/// The value an unterminated number or literal token shows.
Object? _pendingScalarValue(String token) {
  for (final (literal, value) in _literals) {
    if (value != null && literal.startsWith(token)) return value;
  }
  if (_number.hasMatch(token)) return _parseJsonNumber(token);
  final mantissa = _numberWithoutExponentDigits.firstMatch(token);
  if (mantissa == null) return null;
  return _parseJsonNumber(mantissa.group(1)!);
}

/// Parses a JSON number token the way JavaScript's `Number()` renders it: a
/// token without a fraction or exponent becomes an int (so it serializes as
/// `1`, not `1.0`), everything else a double.
Object? _parseJsonNumber(String token) {
  if (!token.contains('.') && !token.contains('e') && !token.contains('E')) {
    final intValue = int.tryParse(token);
    if (intValue != null) return intValue;
  }
  return double.tryParse(token);
}

void _setSlot(Object container, _Slot slot, Object? value) {
  if (slot is _ElementSlot) {
    (container as List)[slot.index] = value;
  } else if (slot is _MemberSlot) {
    (container as Map<String, dynamic>)[slot.key] = value;
  }
}

bool _deepEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is List && b is List) {
    return a.length == b.length &&
        a.indexed.every((e) => _deepEquals(e.$2, b[e.$1]));
  }
  if (a is Map && b is Map) {
    return a.length == b.length &&
        a.keys.toSet().intersection(b.keys.toSet()).length == a.length &&
        a.entries.every((e) => _deepEquals(e.value, b[e.key]));
  }
  if (a is num && b is num) return a == b;
  return a == b;
}

int _canonicalHash(Object? value) {
  if (value is List) {
    return Object.hashAll(value.map(_canonicalHash));
  }
  if (value is Map) {
    return Object.hashAll([
      for (final key in value.keys.toList()..sort())
        Object.hash(_canonicalHash(key), _canonicalHash(value[key])),
    ]);
  }
  return value.hashCode;
}
