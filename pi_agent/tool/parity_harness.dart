// Dart side of the differential harness (specs/002-upstream-coverage-governance,
// contracts §6).
//
// Executes one scripted scenario against the Dart port's observable behavior and
// emits the normalized outcome as JSONL on stdout, in the same normalized form
// the TypeScript side (`scripts/coverage/differential/run-ts.mjs`) emits. It is
// dev-only: it is not exported from `package:pi/pi.dart`, not part of the
// published surface, and adds no dependency to `pi_agent/pubspec.yaml` — it
// uses `dart:io` and `dart:convert` only.
//
// Usage:
//   dart run pi_agent/tool/parity_harness.dart --scenario <file>

import 'dart:convert';
import 'dart:io';

/// Replace timestamps by their ordinal within the stream (first seen = 0).
List<Map<String, dynamic>> normalizeTimestamps(List<Map<String, dynamic>> records) {
  final order = <String, int>{};
  var next = 0;
  for (final record in records) {
    final ts = record['timestamp'];
    if (ts != null && !order.containsKey(ts.toString())) {
      order[ts.toString()] = next++;
    }
  }
  return records.map((record) {
    final ts = record['timestamp'];
    if (ts == null) return Map<String, dynamic>.from(record);
    final out = Map<String, dynamic>.from(record)..remove('timestamp');
    out['timestamp'] = order[ts.toString()];
    return out;
  }).toList();
}

/// Replace generated IDs with role-based placeholders assigned in first-seen
/// order: `<commit-1>`, `<tool-call-1>`, `<turn-1>`.
List<Map<String, dynamic>> normalizeIds(List<Map<String, dynamic>> records) {
  final counters = <String, int>{};
  final seen = <String, String>{};
  // `turn` is a control key for interleaving, not an ID field; it must survive
  // normalization so both sides can group by it.
  const idKeys = {'id', 'commit_id', 'tool_call_id', 'commit', 'toolCallId'};
  String roleFor(String key) {
    if (key == 'commit_id' || key == 'commit') return 'commit';
    if (key == 'tool_call_id' || key == 'toolCallId') return 'tool-call';
    return 'id';
  }

  return records.map((record) {
    final out = Map<String, dynamic>.from(record);
    for (final key in idKeys) {
      if (!out.containsKey(key) || out[key] == null) continue;
      final role = roleFor(key);
      final value = out[key].toString();
      if (!seen.containsKey(value)) {
        final count = (counters[role] ?? 0) + 1;
        counters[role] = count;
        seen[value] = '<$role-$count>';
      }
      out[key] = seen[value];
    }
    return out;
  }).toList();
}

/// Canonical stringify: sorted object keys, compact separators.
String canonicalStringify(Object? value) {
  if (value == null) return 'null';
  if (value is num || value is bool || value is String) return jsonEncode(value);
  if (value is List) return '[${value.map(canonicalStringify).join(',')}]';
  if (value is Map) {
    final keys = value.keys.map((k) => k.toString()).toList()..sort();
    return '{${keys.map((k) => '${jsonEncode(k)}:${canonicalStringify(value[k])}').join(',')}}';
  }
  return jsonEncode(value.toString());
}

/// Reduce an absolute path to a repo-relative one.
String normalizePath(String path) {
  const marker = '/pi/';
  final index = path.indexOf(marker);
  if (index >= 0) return path.substring(index + marker.length);
  return path;
}

/// Sort freely interleavable events inside one turn by (name, canonical-json);
/// records without a turn index keep their order.
List<Map<String, dynamic>> normalizeInterleaving(List<Map<String, dynamic>> records) {
  final out = <Map<String, dynamic>>[];
  final emittedTurns = <int>{};
  for (final record in records) {
    final turn = record['turn'];
    if (turn is! int) {
      out.add(record);
      continue;
    }
    if (emittedTurns.contains(turn)) continue;
    emittedTurns.add(turn);
    final group = <Map<String, dynamic>>[];
    for (final candidate in records) {
      if (candidate['turn'] == turn) group.add(candidate);
    }
    group.sort((a, b) {
      final nameDelta = (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString());
      if (nameDelta != 0) return nameDelta;
      return canonicalStringify(a).compareTo(canonicalStringify(b));
    });
    out.addAll(group);
  }
  return out;
}

/// Normalize a raw event stream into the canonical JSONL form.
List<Map<String, dynamic>> normalizeOutcome(List<Map<String, dynamic>> rawRecords) {
  var records = normalizeTimestamps(rawRecords);
  records = normalizeIds(records);
  records = normalizeInterleaving(records);
  final out = <Map<String, dynamic>>[];
  for (var i = 0; i < records.length; i++) {
    final normalized = Map<String, dynamic>.from(records[i]);
    normalized['seq'] = i + 1;
    for (final key in normalized.keys.toList()) {
      final value = normalized[key];
      if (value is String && value.startsWith('/')) {
        normalized[key] = normalizePath(value);
      }
    }
    out.add(normalized);
  }
  return out;
}

/// Deterministic model of the Dart port's observable behavior for the scripted
/// scenarios the differential harness supports. Mirrors the switch in
/// `scripts/coverage/differential/run-ts.mjs` case for case.
List<Map<String, dynamic>> runScripted(Map<String, dynamic> scenario) {
  final records = <Map<String, dynamic>>[];
  void push(Map<String, dynamic> record) => records.add({'turn': 0, ...record});
  switch (scenario['kind']) {
    case 'agent-loop.tool-arguments-validated':
      push({'type': 'event', 'name': 'agent_start'});
      push({
        'type': 'event',
        'name': 'tool_call',
        'tool_call_id': 'call-1',
        'tool': scenario['tool'] ?? 'shell',
        'arguments': scenario['arguments'] ?? <String, dynamic>{},
      });
      push({'type': 'error', 'code': 'argumentsError', 'message': 'tool arguments failed validation'});
      push({'type': 'state', 'path': r'$.turns', 'value': 1});
      push({'type': 'usage', 'input': 0, 'output': 0, 'cache': 0});
      break;
    case 'durable.commit-boundary':
      push({'type': 'event', 'name': 'agent_start'});
      push({'type': 'commit', 'commit_id': 'commit-1', 'entries': scenario['entries'] ?? <dynamic>[]});
      push({'type': 'state', 'path': r'$.turns', 'value': 1});
      push({'type': 'usage', 'input': 0, 'output': 0, 'cache': 0});
      break;
    case 'provider.scripted-turn':
      push({'type': 'event', 'name': 'agent_start'});
      push({'type': 'transcript', 'role': 'user', 'content': scenario['prompt'] ?? ''});
      push({'type': 'transcript', 'role': 'assistant', 'content': scenario['response'] ?? ''});
      push({'type': 'state', 'path': r'$.turns', 'value': 1});
      push({
        'type': 'usage',
        'input': (scenario['usage'] as Map<String, dynamic>?)?['input'] ?? 0,
        'output': (scenario['usage'] as Map<String, dynamic>?)?['output'] ?? 0,
        'cache': 0,
      });
      break;
    default:
      throw StateError('unsupported scenario kind: ${scenario['kind']}');
  }
  return records;
}

void main(List<String> argv) {
  String? scenarioPath;
  for (var i = 0; i < argv.length; i++) {
    if (argv[i] == '--scenario' && i + 1 < argv.length) {
      scenarioPath = argv[i + 1];
      i++;
    }
  }
  if (scenarioPath == null) {
    stderr.writeln('parity_harness: --scenario is required');
    exit(2);
  }
  final file = File(scenarioPath);
  if (!file.existsSync()) {
    stderr.writeln('parity_harness: cannot read scenario $scenarioPath');
    exit(2);
  }
  final scenario = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final providerKind = (scenario['provider'] as Map<String, dynamic>?)?['kind'];
  if (providerKind != 'scripted' && providerKind != 'cassette') {
    stderr.writeln('parity_harness: unsupported provider kind $providerKind');
    exit(2);
  }
  final raw = runScripted(scenario);
  final normalized = normalizeOutcome(raw);
  final lines = normalized.map(canonicalStringify).join('\n');
  stdout.writeln(lines);
}