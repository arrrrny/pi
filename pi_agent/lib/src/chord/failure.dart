/// Failure causes: why an object, or a request, is failed.
///
/// Port of `packages/chord/src/data/failure.ts` at upstream
/// `780bf31fcaeb252fa9b68df3964c735eae75bde3`.
library;

import 'errors.dart';

/// Why an object, or a request, is failed; the kind comes from the failing
/// stage, never from the error code.
class FailureCause {
  /// A cause of the given [kind] carrying [error].
  const FailureCause(this.kind, this.error);

  /// A transient failure: the object's own effect failed, retry later.
  const FailureCause.transient(ChordError error) : this('transient', error);

  /// A broken failure: its own code, a cycle or authority, retry by hand.
  const FailureCause.broken(ChordError error) : this('broken', error);

  /// A waiting failure: not its fault, woken by an event.
  const FailureCause.waiting(ChordError error) : this('waiting', error);

  /// A denied failure: an admission refused the caller, woken by the decision.
  const FailureCause.denied(ChordError error) : this('denied', error);

  /// The cause kind: `transient`, `broken`, `waiting` or `denied`.
  final String kind;

  /// The failure.
  final ChordError error;
}

/// Marks an open's failure as broken (bad configuration): `throw broken(error)`.
BrokenOpen broken(Object? cause) => BrokenOpen(cause);

/// The cause of a value thrown by an open: broken when it came from [broken],
/// transient otherwise.
FailureCause openFailure(Object? thrown, String label) {
  if (thrown is BrokenOpen) {
    return FailureCause.broken(asChordError(thrown.cause, label));
  }
  return FailureCause.transient(asChordError(thrown, label));
}

/// The longest message a `waiting` cause of a dependent carries.
const int _messageLimit = 500;

/// How a dependent's message names its blocker: the nearest one first.
const String _prefix = 'waiting for ';

/// The separator after a blocker's label.
const String _separator = ': ';

/// The marker of a clipped label or root.
const String _clipped = '\u2026';

/// The most of the 500 characters the root cause takes when both are long.
const int _rootLimit = 320;

/// The `waiting` cause of a dependent parked on [blocker], which failed with
/// [error]: `unavailable`, its message always "waiting for `<blocker>`:
/// `<root cause>`" (the root found through any "waiting for …: " of [error]'s
/// message), so a ring of waiting attempts passing causes round reaches the same
/// message after one round; within 500 characters, the label clipped first, the
/// root only past its share. [error] is its cause.
FailureCause waitingFor(String blocker, ChordError error) {
  var root = _rootMessage(error.message);
  var label = blocker;
  final room = _messageLimit - _prefix.length - _separator.length;
  if (label.length + root.length > room) {
    final rootRoom =
        _rootLimit > room - label.length ? _rootLimit : room - label.length;
    if (root.length > rootRoom) root = _clip(root, rootRoom);
    if (label.length + root.length > room) {
      label = _clip(label, room - root.length);
    }
  }
  final message = '$_prefix$label$_separator$root';
  // A version refusal, here or along the chain, keeps its reason: it heals with
  // another host's reload.
  final version = error.code == 'contract_mismatch' ||
      (error.code == 'unavailable' && error.reason == 'version');
  final wrapped = version
      ? ChordError(
          code: 'unavailable', reason: 'version', message: message, cause: error)
      : ChordError(code: 'unavailable', message: message, cause: error);
  return FailureCause.waiting(wrapped);
}

/// `text` within [length] characters, clipped with "…" when longer.
String _clip(String text, int length) => text.length <= length
    ? text
    : '${text.substring(0, length - _clipped.length)}$_clipped';

/// The root cause in a "waiting for X: root" message: past every leading
/// "waiting for …: ".
String _rootMessage(String message) {
  var rest = message;
  while (rest.startsWith(_prefix)) {
    final end = rest.indexOf(_separator, _prefix.length);
    if (end < 0) break;
    rest = rest.substring(end + _separator.length);
  }
  return rest;
}

/// Whether two failure causes say the same (a wake compares causes by value):
/// kind, code, reason and message.
bool sameCause(FailureCause a, FailureCause b) =>
    a.kind == b.kind &&
    a.error.code == b.error.code &&
    a.error.reason == b.error.reason &&
    a.error.message == b.error.message;

/// A value thrown by an open to mark its failure broken (bad configuration).
class BrokenOpen extends Error {
  /// The marked cause.
  BrokenOpen(this.cause);

  /// The underlying cause.
  final Object? cause;

  /// The error's name.
  String get name => 'BrokenOpen';

  /// The error message: the cause's message without a runtime type prefix.
  String get message => chordErrorMessage(cause);

  @override
  String toString() => '$name: $message';
}
