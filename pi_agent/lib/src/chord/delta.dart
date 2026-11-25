/// Chord delta operations and their immutable application.
///
/// Port of `packages/chord/src/delta/index.ts` (the `Op` vocabulary and
/// `applyImmutable` / `applyImmutableBatches`) and `delta/pending.ts` at
/// upstream `780bf31fcaeb252fa9b68df3964c735eae75bde3`.
library;

import 'json.dart';

/// One path segment: an object key or an array index.
typedef Seg = Object;

/// A location inside a document value.
typedef Path = List<Seg>;

/// A non-empty path: `s`, `d`, `a` and `t` cannot target the root.
typedef NonEmptyPath = List<Seg>;

/// One Chord mutation of a document value.
///
/// The tuple form upstream is the in-memory, on-wire and on-disk form; the port
/// keeps one class per case and the same field order.
sealed class Op {
  /// A document mutation.
  const Op();
}

/// `["r", value]`: replace the whole value.
final class OpReplace extends Op {
  /// Replace the whole value with [value].
  const OpReplace(this.value);

  /// The replacement value.
  final Object? value;
}

/// `["s", path, value]`: set the value at `path`.
final class OpSet extends Op {
  /// Set [value] at [path].
  const OpSet(this.path, this.value);

  /// Where to write; never empty.
  final NonEmptyPath path;

  /// The value to write.
  final Object? value;
}

/// `["d", path]`: delete the value at `path`.
final class OpDelete extends Op {
  /// Delete the value at [path].
  const OpDelete(this.path);

  /// What to delete; never empty.
  final NonEmptyPath path;
}

/// `["a", path, string]`: append `string` to the string at `path`.
final class OpAppend extends Op {
  /// Append [value] to the string at [path].
  const OpAppend(this.path, this.value);

  /// The string's location; never empty.
  final NonEmptyPath path;

  /// The text to append.
  final String value;
}

/// `["t", path, number]`: drop the first `length` characters at `path`,
/// keeping the tail (JS `slice(length)`).
final class OpTruncate extends Op {
  /// Drop the first [length] characters at [path], keeping the tail.
  const OpTruncate(this.path, this.length);

  /// The string's location; never empty.
  final NonEmptyPath path;

  /// How many leading characters to drop.
  final int length;
}

/// `["p", path, start, deleteCount, items]`: one array splice.
final class OpInsert extends Op {
  /// Splice [items] into the array at [path].
  const OpInsert(this.path, this.start, this.deleteCount, this.items);

  /// The array's location; empty means the root is the array.
  final Path path;

  /// Index at which to start.
  final int start;

  /// How many items to delete at [start] before inserting.
  final int deleteCount;

  /// Items to insert at [start].
  final List<Object?> items;
}

/// `["m", path, permutation]`: reorder an array so `new[i] = old[permutation[i]]`.
final class OpMove extends Op {
  /// Reorder the array at [path] by [permutation].
  const OpMove(this.path, this.permutation);

  /// The array's location; empty means the root is the array.
  final Path path;

  /// The permutation to apply.
  final List<int> permutation;
}

/// Thrown when an operation's path does not address the value it reads.
class PathError extends Error {
  /// The path that failed.
  PathError(this.path);

  /// The path that failed.
  final Path path;

  @override
  String toString() => 'PathError(${path.join("/")})';
}

/// Segments that reach the prototype chain.
///
/// `JSON.parse` is safe on its own — it makes `__proto__` an own property. What
/// is not safe is `parent[key] = value`, which is exactly what an applier does,
/// and paths are data: `["s", ["__proto__", "isAdmin"], true]` pollutes
/// `Object.prototype` for the whole process. Ops arrive from a facet, a plugin
/// compartment, or a tool whose details may echo model output, so none of it is
/// trusted input.
// The name is the upstream `RESERVED_SEGMENTS` identifier, kept verbatim.
// ignore: constant_identifier_names
const Set<String> RESERVED_SEGMENTS = <String>{
  '__proto__',
  'constructor',
  'prototype',
};

/// Whether [op] replaces the whole value (the `r` verb).
bool isReplace(Op op) => op is OpReplace;

/// Apply [ops] to a plain mutable value the caller owns, returning the root.
///
/// Unlike [applyImmutable], this mutates [target] in place: containers are
/// written through, not copied. Only `r` replaces the root outright, so the
/// return value is the one to keep — it is [target] for every other verb.
Object? apply(Object? target, List<Op> ops) {
  Object? root = target;
  for (final op in ops) {
    switch (op) {
      case OpReplace(:final value):
        root = value;
      case OpInsert():
      case OpMove():
      case OpSet():
      case OpDelete():
      case OpAppend():
      case OpTruncate():
        _applyMutable(root, op);
    }
  }
  return root;
}

/// Apply [ops] to [target], returning a new value; [target] is not mutated.
Object? applyImmutable(Object? target, List<Op> ops) =>
    applyImmutableBatches(target, <List<Op>>[ops]);

/// Fold a sequence of op batches over [target], returning the final value.
///
/// Containers on a mutated path are copied before they are written, so an
/// earlier batch's result is never changed by a later one and the caller's
/// [target] is never mutated. A root replacement is adopted, exactly as
/// upstream adopts it.
Object? applyImmutableBatches(Object? target, Iterable<List<Op>> batches) {
  Object? root = target;
  for (final ops in batches) {
    for (final op in ops) {
      switch (op) {
        case OpReplace(:final value):
          root = value;
        case OpInsert(:final path):
          root = _copyAlong(root, path);
          _applyMutable(root, op);
        case OpMove(:final path):
          root = _copyAlong(root, path);
          _applyMutable(root, op);
        case OpSet(:final path):
        case OpDelete(:final path):
        case OpAppend(:final path):
        case OpTruncate(:final path):
          root = _copyAlong(root, path.sublist(0, path.length - 1));
          _applyMutable(root, op);
      }
    }
  }
  return root;
}

/// Copy every container along [path], returning the new root.
Object? _copyAlong(Object? root, Path path) {
  if (path.isEmpty) {
    if (root is List) {
      return List<Object?>.of(root);
    }
    if (root is Map) {
      return Map<String, Object?>.of(root.cast<String, Object?>());
    }
    return root;
  }
  final segment = path.first;
  final rest = path.sublist(1);
  if (root is List) {
    if (segment is! int) {
      throw PathError(path);
    }
    if (segment < 0 || segment >= root.length) {
      throw PathError(path);
    }
    final copy = List<Object?>.of(root);
    copy[segment] = _copyAlong(copy[segment], rest);
    return copy;
  }
  if (root is Map) {
    if (segment is! String) {
      throw PathError(path);
    }
    final copy = <String, Object?>{...root.cast<String, Object?>()};
    copy[segment] = _copyAlong(copy[segment], rest);
    return copy;
  }
  throw PathError(path);
}

/// Apply one op to a value the caller owns. Returns nothing: only `r` replaces
/// the root, and that case is handled before this runs.
void _applyMutable(Object? root, Op op) {
  switch (op) {
    case OpReplace():
      throw StateError('root replacement is handled by the caller');
    case OpInsert(:final path, :final start, :final deleteCount, :final items):
      final target = _resolve(root, path);
      if (target is! List) {
        throw PathError(path);
      }
      target.insertAll(start, items);
      if (deleteCount > 0) {
        target.removeRange(
            start + items.length, start + items.length + deleteCount);
      }
    case OpMove(:final path, :final permutation):
      final target = _resolve(root, path);
      if (target is! List || target.length != permutation.length) {
        throw PathError(path);
      }
      final previous = List<Object?>.of(target);
      for (var index = 0; index < permutation.length; index++) {
        target[index] = previous[permutation[index]];
      }
    case OpSet(:final path, :final value):
      final parent = _resolve(root, path.sublist(0, path.length - 1));
      final key = path.last;
      if (parent is List) {
        if (key is! int) {
          throw PathError(path);
        }
        if (key < 0 || key >= parent.length) {
          throw PathError(path);
        }
        parent[key] = value;
        return;
      }
      if (parent is Map) {
        if (key is! String) {
          throw PathError(path);
        }
        parent[key] = value;
        return;
      }
      throw PathError(path);
    case OpDelete(:final path):
      final parent = _resolve(root, path.sublist(0, path.length - 1));
      final key = path.last;
      if (parent is List) {
        if (key is! int || key >= parent.length) {
          throw PathError(path);
        }
        parent.removeAt(key);
        return;
      }
      if (parent is Map) {
        if (key is! String) {
          throw PathError(path);
        }
        parent.remove(key);
        return;
      }
      throw PathError(path);
    case OpAppend(:final path, :final value):
      final parent = _resolve(root, path.sublist(0, path.length - 1));
      final key = path.last;
      final current =
          parent is List ? parent[key as int] : (parent as Map)[key as String];
      if (current is! String) {
        throw PathError(path);
      }
      if (parent is List) {
        parent[key as int] = '$current$value';
      } else {
        (parent as Map)[key as String] = '$current$value';
      }
    case OpTruncate(:final path, :final length):
      final parent = _resolve(root, path.sublist(0, path.length - 1));
      final key = path.last;
      final current =
          parent is List ? parent[key as int] : (parent as Map)[key as String];
      if (current is! String) {
        throw PathError(path);
      }
      final truncated =
          length >= current.length ? current : current.substring(length);
      if (parent is List) {
        parent[key as int] = truncated;
      } else {
        (parent as Map)[key as String] = truncated;
      }
  }
}

Object? _resolve(Object? root, Path path) {
  Object? node = root;
  for (final segment in path) {
    if (node is List) {
      if (segment is! int || segment < 0 || segment >= node.length) {
        throw PathError(path);
      }
      node = node[segment];
    } else if (node is Map) {
      if (segment is! String) {
        throw PathError(path);
      }
      node = node[segment];
    } else {
      throw PathError(path);
    }
  }
  return node;
}

/// The mutable draft of one document inside a transaction.
///
/// Every mutation is recorded as the [Op] that expresses it, so the commit can
/// store the smallest representation the definition's checkpoint predicate
/// allows. The draft owns a detached value, so a caller that abandons it leaves
/// the document unchanged.
class Draft<T extends JsonObject> {
  /// A draft over [value], which this object takes ownership of.
  Draft(T value)
      : _value = value as Object?,
        _initial = copyJson(value);

  Object? _value;
  final Object? _initial;
  final List<Op> _ops = <Op>[];

  /// The current value of the draft.
  T get value => _value as T;

  /// The operations this draft recorded, in order; empty when it did not change.
  List<Op> get ops => List<Op>.unmodifiable(_ops);

  /// The value the draft started from.
  Object? get initialValue => _initial;

  /// Replace the whole value.
  void replace(Object? value) {
    _value = copyJson(value);
    _ops.add(OpReplace(_value));
  }

  /// Set the value at [path].
  void set(Path path, Object? value) {
    final copied = copyJson(value);
    _apply(OpSet(path, copied));
  }

  /// Delete the value at [path].
  void delete(Path path) => _apply(OpDelete(path));

  /// Append [text] to the string at [path].
  void append(Path path, String text) => _apply(OpAppend(path, text));

  /// Drop the first [length] characters of the string at [path].
  void truncate(Path path, int length) => _apply(OpTruncate(path, length));

  /// Splice [items] into the array at [path].
  void insert(Path path, int start, int deleteCount, List<Object?> items) {
    final copied = <Object?>[for (final item in items) copyJson(item)];
    _apply(OpInsert(path, start, deleteCount, copied));
  }

  /// Reorder the array at [path] so `value[i] = previous[permutation[i]]`.
  void move(Path path, List<int> permutation) =>
      _apply(OpMove(path, permutation));

  void _apply(Op op) {
    _value = applyImmutable(_value, <Op>[op]);
    _ops.add(op);
  }
}
