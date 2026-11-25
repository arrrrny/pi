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
// `agent-loop.*` scenarios drive the REAL `agentLoop` from
// `package:pi/src/agent_loop.dart` with a scripted `streamFn`, so the outcome
// is what shipped code produces rather than a parallel switch that can only
// disagree with a hand-written twin. The remaining kinds have no Dart
// implementation to drive yet (`durable.*` has no commit boundary in the port,
// `provider.*` needs a provider transport the harness does not model), so they
// stay scripted and say so.
//
// Usage:
//   dart run pi_agent/tool/parity_harness.dart --scenario <file>

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:pi/src/agent_loop.dart';
import 'package:pi/src/ai/anthropic_stream.dart';
import 'package:pi/src/ai/google_stream.dart';
import 'package:pi/src/ai/mistral_stream.dart';
import 'package:pi/src/ai/openai_stream.dart';
import 'package:pi/src/ai/provider_error.dart';
import 'package:pi/src/ai/provider_events.dart';
import 'package:pi/src/ai/provider_identity.dart';
import 'package:pi/src/ai/provider_retry.dart';
import 'package:pi/src/ai/sse_decoder.dart';
import 'package:pi/src/types.dart' hide AgentTool;
import 'package:pi/src/tools.dart';

/// Replace timestamps by their ordinal within the stream (first seen = 0).
List<Map<String, dynamic>> normalizeTimestamps(
    List<Map<String, dynamic>> records) {
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
  if (value is num || value is bool || value is String) {
    return jsonEncode(value);
  }
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
List<Map<String, dynamic>> normalizeInterleaving(
    List<Map<String, dynamic>> records) {
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
      final nameDelta =
          (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString());
      if (nameDelta != 0) return nameDelta;
      return canonicalStringify(a).compareTo(canonicalStringify(b));
    });
    out.addAll(group);
  }
  return out;
}

/// Normalize a raw event stream into the canonical JSONL form.
List<Map<String, dynamic>> normalizeOutcome(
    List<Map<String, dynamic>> rawRecords) {
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

/// Drives the REAL [agentLoop] for an `agent-loop.*` scenario with a scripted
/// `streamFn`, so the emitted records are what shipped code produces.
///
/// The scenario describes the provider's turns: turn 0 carries the tool call
/// under test (with an `arguments_error` when the scenario models a failed
/// argument parse), and any later turn is a plain assistant message that ends
/// the run. Every `AgentEvent` the loop emits is reduced to one record, with a
/// `turn` index so the two sides group interleaving the same way.
Future<List<Map<String, dynamic>>> runRealAgentLoop(
    Map<String, dynamic> scenario) async {
  final toolName = scenario['tool'] as String? ?? 'shell';
  final argumentsError =
      scenario['arguments_error'] as String? ?? 'Expected object';
  final arguments =
      (scenario['arguments'] as Map<String, dynamic>?) ?? <String, dynamic>{};

  final tool = AgentTool<Map<String, dynamic>, dynamic>(
    name: toolName,
    description: 'Scenario tool under test',
    parameters: {
      'type': 'object',
      'properties': <String, dynamic>{},
    },
    execute: (id, params, {onUpdate, isAborted}) async =>
        AgentToolResult<dynamic>(
      content: const <ContentBlock>[TextBlock('executed')],
      details: null,
    ),
  );

  final context = AgentContext(
    systemPrompt: 'parity-harness',
    messages: <AgentMessage>[
      UserMessage.text(scenario['prompt'] as String? ?? 'go')
    ],
    tools: <AgentTool<dynamic, dynamic>>[tool],
  );

  final config = AgentLoopConfig(
    model: const Model(
      provider: 'parity',
      modelId: 'scripted',
      contextWindow: 128000,
    ),
    convertToLlm: (messages) async => messages
        .map((m) => <String, dynamic>{'role': 'user', 'content': 'parity'})
        .toList(),
  );

  var turn = 0;
  Stream<AgentEvent> scriptedStream({
    required AgentContext context,
    required AgentLoopConfig config,
    required String apiKey,
    required Completer<void>? abortSignal,
  }) {
    final isFirst = turn++ == 0;
    final message = isFirst
        ? AssistantMessage(
            content: <dynamic>[
              ToolCallBlock(
                id: 'call-1',
                name: toolName,
                arguments: arguments,
                argumentsError: argumentsError,
              ),
            ],
            stopReason: StopReason.toolUse,
          )
        : AssistantMessage(
            content: const <ContentBlock>[TextBlock('done')],
            stopReason: StopReason.endTurn,
          );
    return Stream<AgentEvent>.fromIterable(<AgentEvent>[
      MessageStart(message: message),
      MessageEnd(message: message),
    ]);
  }

  final records = <Map<String, dynamic>>[];
  var turnIndex = 0;
  num? usageInput;
  num? usageOutput;

  // The record contract is the OBSERVABLE outcome, not the event plumbing:
  // `MessageStart`/`MessageEnd` are streaming bookkeeping (the prompt echo
  // alone emits two of them), so only loop-, turn-, tool-, and usage-level
  // records are emitted. Both sides compare the same reduced set.
  await for (final event in agentLoop(
    context,
    config,
    prompts: <AgentMessage>[
      UserMessage.text(scenario['prompt'] as String? ?? 'go')
    ],
    streamFn: scriptedStream,
  )) {
    switch (event) {
      case AgentStart():
        records.add({'turn': 0, 'type': 'event', 'name': 'agent_start'});
      case AgentEnd():
        records.add({'turn': turnIndex, 'type': 'event', 'name': 'agent_end'});
      case TurnStart():
        turnIndex += 1;
        records.add({'turn': turnIndex, 'type': 'turn', 'name': 'turn_start'});
      case TurnEnd(message: final message, toolResults: final results):
        records.add({
          'turn': turnIndex,
          'type': 'turn',
          'name': 'turn_end',
          'stop_reason': message is AssistantMessage
              ? (message.stopReason?.name ?? 'unknown')
              : 'unknown',
        });
        for (final result in results) {
          records.add({
            'turn': turnIndex,
            'type': 'tool_result',
            'tool_call_id': result.toolCallId,
            'tool': result.toolName,
            'is_error': result.isError,
            'text': result.content
                .whereType<TextBlock>()
                .map((b) => b.text)
                .join('|'),
          });
        }
      case MessageStart(message: final message):
        if (message is AssistantMessage) {
          usageInput ??= message.usage?.inputTokens;
          usageOutput ??= message.usage?.outputTokens;
        }
      case MessageEnd(message: final message):
        if (message is AssistantMessage) {
          usageInput ??= message.usage?.inputTokens;
          usageOutput ??= message.usage?.outputTokens;
        }
      case ToolExecutionStart(toolCallId: final id, toolName: final name):
        records.add({
          'turn': turnIndex,
          'type': 'tool_execution',
          'name': 'start',
          'tool_call_id': id,
          'tool': name,
        });
      case ToolExecutionEnd(
          toolCallId: final id,
          toolName: final name,
          isError: final isError
        ):
        records.add({
          'turn': turnIndex,
          'type': 'tool_execution',
          'name': 'end',
          'tool_call_id': id,
          'tool': name,
          'is_error': isError,
        });
      case ToolExecutionUpdate():
        break;
      default:
        break;
    }
  }

  records.add({
    'turn': 0,
    'type': 'usage',
    'input': usageInput ?? 0,
    'output': usageOutput ?? 0,
    'cache': 0,
  });
  records.add(
      {'turn': 0, 'type': 'state', 'path': r'$.turns', 'value': turnIndex});
  return records;
}

/// Deterministic model of the Dart port's observable behavior for scenarios
/// that have no Dart implementation to drive yet.
///
/// `durable.*` has no commit boundary in the port and `provider.*` needs a
/// provider transport the harness does not model, so those kinds stay scripted
/// and are marked as such in the scenario's `dart_model` field.
List<Map<String, dynamic>> runScripted(Map<String, dynamic> scenario) {
  final records = <Map<String, dynamic>>[];
  void push(Map<String, dynamic> record) => records.add({'turn': 0, ...record});
  switch (scenario['kind']) {
    case 'durable.commit-boundary':
      push({'type': 'event', 'name': 'agent_start'});
      push({
        'type': 'commit',
        'commit_id': 'commit-1',
        'entries': scenario['entries'] ?? <dynamic>[]
      });
      push({'type': 'state', 'path': r'$.turns', 'value': 1});
      push({'type': 'usage', 'input': 0, 'output': 0, 'cache': 0});
      break;
    case 'provider.scripted-turn':
      push({'type': 'event', 'name': 'agent_start'});
      push({
        'type': 'transcript',
        'role': 'user',
        'content': scenario['prompt'] ?? ''
      });
      push({
        'type': 'transcript',
        'role': 'assistant',
        'content': scenario['response'] ?? ''
      });
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

/// Normalization shared with `normalize.mjs`: a GENERATED tool-call id
/// (`<name>_<timestamp>_<counter>`, minted at stream time by Google and any
/// provider that mints ids) differs per run and per language, so the
/// first-seen generated shape maps to `<generated-tool-call-N>` on both
/// sides. Explicit scenario ids are `call_1`-style and never match.
final RegExp _generatedToolCallId = RegExp(r'^.+_\d+_\d+$');

List<Map<String, dynamic>> normalizeGeneratedToolCallIds(
    List<Map<String, dynamic>> records) {
  final placeholders = <String, String>{};
  var count = 0;
  String placeholderFor(String value) => placeholders.putIfAbsent(value, () {
        count += 1;
        return '<generated-tool-call-$count>';
      });

  Object? walk(Object? value) {
    if (value is List) return value.map(walk).toList();
    if (value is Map) {
      final out = <String, dynamic>{};
      for (final entry in value.entries) {
        final key = entry.key;
        final inner = entry.value;
        if (key == 'id' &&
            inner is String &&
            _generatedToolCallId.hasMatch(inner)) {
          out[key as String] = placeholderFor(inner);
        } else {
          out[key as String] = walk(inner);
        }
      }
      return out;
    }
    return value;
  }

  return records.map((record) => walk(record) as Map<String, dynamic>).toList();
}

/// Decode a raw SSE cassette into decoded events, mirroring the well-formed
/// frames a sanitized cassette carries.
List<ServerSentEvent> decodeCassette(String text) {
  final decoder = SseDecoder();
  final events = <ServerSentEvent>[];
  for (final frame in text.split('\n\n')) {
    if (frame.isEmpty) continue;
    events.addAll(decoder.push(utf8.encode('$frame\n\n')));
  }
  events.addAll(decoder.end());
  return events;
}

/// The provider streaming surface (`provider-stream.*`, `provider-error-body`,
/// `provider-retry-transient`, `provider.session-identity`): drive the REAL
/// Dart parsers and utils over the sanitized cassette, exactly as the
/// TypeScript side's model drives the upstream contract. A parser failure
/// becomes the canonical terminal `error` outcome plus message record, like
/// the upstream API's outer catch.
Future<List<Map<String, dynamic>>> runProviderSurface(
    Map<String, dynamic> scenario) async {
  final kind = scenario['kind'] as String? ?? '';
  if (kind == 'provider-error-body') {
    return runProviderErrorBodyScenario(scenario);
  }
  if (kind == 'provider-retry-transient') {
    return runProviderRetryScenario(scenario);
  }
  if (kind == 'provider.session-identity') {
    return runProviderIdentityScenario(scenario);
  }

  final cassette =
      File((scenario['provider'] as Map<String, dynamic>)['cassette'] as String)
          .readAsStringSync();
  if (kind.startsWith('provider-stream.anthropic')) {
    final parser = AnthropicStreamParser(
      requestedModelId: scenario['requested_model_id'] as String? ?? '',
    );
    return driveProviderParser(
      parser.message,
      run: (events) {
        for (final sse in decodeCassette(cassette)) {
          events.addAll(parser.feed(sse));
        }
        events.addAll(parser.end());
      },
    );
  }
  final chunks = <Map<String, dynamic>>[];
  for (final sse in decodeCassette(cassette)) {
    // The [DONE] sentinel carries no payload.
    if (sse.data == '[DONE]') continue;
    chunks.add(jsonDecode(sse.data) as Map<String, dynamic>);
  }
  if (kind.startsWith('provider-stream.openai')) {
    final parser = OpenAiStreamParser(
      requestedModelId: scenario['requested_model_id'] as String?,
    );
    return driveProviderParser(
      parser.message,
      run: (events) {
        for (final chunk in chunks) {
          events.addAll(parser.feedChunk(chunk));
        }
        // The sink IS the accumulator: end() returns it, so no addAll — a
        // second add would double every block-close event.
        parser.end(sink: events);
      },
    );
  }
  if (kind.startsWith('provider-stream.google')) {
    final parser = GoogleStreamParser(
      requestedModelId: scenario['requested_model_id'] as String? ?? '',
    );
    return driveProviderParser(
      parser.message,
      run: (events) {
        for (final chunk in chunks) {
          events.addAll(parser.feedChunk(chunk));
        }
        // The sink IS the accumulator: end() returns it, so no addAll — a
        // second add would double every block-close event.
        parser.end(sink: events);
      },
    );
  }
  if (kind.startsWith('provider-stream.mistral')) {
    final parser = MistralStreamParser();
    return driveProviderParser(
      parser.message,
      run: (events) {
        for (final chunk in chunks) {
          events.addAll(parser.feedChunk(chunk));
        }
        // The sink IS the accumulator: end() returns it, so no addAll — a
        // second add would double every block-close event.
        parser.end(sink: events);
      },
    );
  }
  throw StateError('unsupported scenario kind: $kind');
}

/// Run the parser against the shared [run] accumulator, then render the
/// canonical outcome records: one per event plus the terminal message
/// record. Events collected before a throw survive: the accumulator is
/// shared with the caller's closure.
List<Map<String, dynamic>> driveProviderParser(
  ProviderMessageState message, {
  required void Function(List<ProviderStreamEvent> events) run,
}) {
  final events = <ProviderStreamEvent>[];
  try {
    run(events);
  } on ProviderStreamException catch (error) {
    message.stopReason = 'error';
    message.errorMessage = error.message;
    events.add(ProviderErrorEvent('error', error.message));
  }
  return [
    for (final event in events) event.toJson(),
    {'type': 'message', ...message.toJson()},
  ];
}

/// `provider-error-body`: normalize + format each scripted error shape.
List<Map<String, dynamic>> runProviderErrorBodyScenario(
    Map<String, dynamic> scenario) {
  final records = <Map<String, dynamic>>[];
  for (final entry in scenario['errors'] as List) {
    final map = entry as Map<String, dynamic>;
    final norm = normalizeProviderError(map['error']);
    final display = formatProviderError(norm, prefix: map['prefix'] as String?);
    records.add({
      'type': 'provider_error',
      'status': norm.status,
      'body': norm.body,
      'messageCarriesBody': norm.messageCarriesBody,
      'display': display,
    });
  }
  return records;
}

/// `provider-retry-transient`: the retry loop over scripted responses with an
/// injected (virtual-clock) sleep.
Future<List<Map<String, dynamic>>> runProviderRetryScenario(
    Map<String, dynamic> scenario) async {
  final records = <Map<String, dynamic>>[];
  final responses = (scenario['responses'] as List?) ?? const <dynamic>[];
  final policyJson = scenario['policy'] as Map<String, dynamic>?;
  final policy = policyJson == null
      ? null
      : RetryPolicy(
          enabled: policyJson['enabled'] as bool,
          maxRetries: (policyJson['maxRetries'] as num).toInt(),
          baseDelayMs: (policyJson['baseDelayMs'] as num).toInt(),
          maxAgentDelayMs: policyJson['maxAgentDelayMs'] == null
              ? null
              : (policyJson['maxAgentDelayMs'] as num).toInt(),
        );
  var call = 0;
  await retryAssistantCall(
    () async {
      final response =
          responses[call < responses.length ? call : responses.length - 1]
              as Map<String, dynamic>;
      call++;
      records.add({
        'type': 'produce',
        'call': call,
        'stopReason': response['stopReason'],
        'errorMessage': response['errorMessage'],
      });
      return RetryAssistantOutcome(
        response['stopReason'] as String,
        response['errorMessage'] as String?,
      );
    },
    policy,
    null,
    RetryCallbacks(
      onRetryScheduled: (attempt, maxAttempts, delayMs, errorMessage) {
        records.add({
          'type': 'retry_scheduled',
          'attempt': attempt,
          'maxAttempts': maxAttempts,
          'delayMs': delayMs,
          'errorMessage': errorMessage,
        });
      },
      onRetryFinished: (success, attempt, finalError) {
        records.add({
          'type': 'retry_finished',
          'success': success,
          'attempt': attempt,
          if (finalError != null) 'finalError': finalError,
        });
      },
    ),
    (_) async {},
  );
  return records;
}

/// `provider.session-identity`: user agent + attribution + session headers
/// for scripted request targets.
List<Map<String, dynamic>> runProviderIdentityScenario(
    Map<String, dynamic> scenario) {
  ClientIdentity? identityFrom(Map<String, dynamic>? json) {
    if (json == null) return null;
    final attributionJson = json['attribution'] as Map<String, dynamic>?;
    return ClientIdentity(
      userAgent: json['user_agent'],
      attribution: attributionJson == null
          ? null
          : ClientAttribution(
              name: attributionJson['name'] as String,
              url: attributionJson['url'] as String,
              categories:
                  (attributionJson['categories'] as List?)?.cast<String>(),
            ),
      version: json['version'] as String?,
    );
  }

  final records = <Map<String, dynamic>>[];
  for (final entry in scenario['requests'] as List) {
    final map = entry as Map<String, dynamic>;
    final identity = identityFrom(map['identity'] as Map<String, dynamic>?);
    final runtime = map['runtime'] as Map<String, dynamic>?;
    final targetJson = map['target'] as Map<String, dynamic>;
    final target = ClientIdentityTarget(
      provider: targetJson['provider'] as String,
      baseUrl: targetJson['base_url'] as String,
    );
    final userAgent = formatUserAgent(
      identity,
      platform: runtime?['platform'] as String?,
      runtime: runtime?['runtime'] as String?,
      arch: runtime?['arch'] as String?,
    );
    final attribution = getAttributionHeaders(target, identity);
    final session =
        getOpenCodeSessionHeaders(target, map['session_id'] as String?);
    records.add({
      'type': 'request_identity',
      'userAgent': userAgent,
      'attribution': attribution.isEmpty ? null : attribution,
      'session': session,
    });
  }
  return records;
}

void main(List<String> argv) async {
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
  final kind = scenario['kind'] as String? ?? '';
  final List<Map<String, dynamic>> raw;
  if (kind.startsWith('agent-loop.')) {
    raw = await runRealAgentLoop(scenario);
  } else if (kind.startsWith('provider-stream.') ||
      kind == 'provider-error-body' ||
      kind == 'provider-retry-transient' ||
      kind == 'provider.session-identity') {
    raw = await runProviderSurface(scenario);
  } else {
    raw = runScripted(scenario);
  }
  final normalized = normalizeOutcome(normalizeGeneratedToolCallIds(raw));
  final lines = normalized.map(canonicalStringify).join('\n');
  stdout.writeln(lines);
}
