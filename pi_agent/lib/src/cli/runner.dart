// The single runtime behind `pidart` (pi#50): one Agent, one turn runner, used
// by both the interactive loop and the one-shot invocation. There is no second,
// wrapper-specific runtime.
//
// The agent is built from the environment so the command needs no flags beyond
// its prompt; `--help` and `--version` short-circuit before any of this runs.

import 'dart:convert';
import 'dart:io';

import 'package:pi/pi.dart';

import 'args.dart';

/// Runs a parsed `pidart` invocation and returns the process exit code.
///
/// [stdinLines] supplies interactive input (defaults to the real stdin), and
/// [write] / [writeErr] are the output sinks (defaults to stdout/stderr). The
/// environment is read from [env] (defaults to the real environment). All of
/// them are injectable so the runner is testable without a real terminal.
Future<int> runPidart(
  PidartArgs args, {
  Map<String, String> env = const {},
  Stream<String>? stdinLines,
  void Function(String text)? write,
  void Function(String text)? writeErr,
}) async {
  final out = write ?? stdout.write;
  final err = writeErr ?? stderr.write;
  final environment = env.isEmpty ? Platform.environment : env;

  switch (args.mode) {
    case PidartMode.help:
      out(pidartUsage());
      return 0;
    case PidartMode.version:
      out('$pidartVersion\n');
      return 0;
    case PidartMode.error:
      err('pidart: ${args.error}\n');
      err(pidartUsage());
      return 64; // EX_USAGE
    case PidartMode.oneShot:
    case PidartMode.interactive:
      return _runConversation(
        args: args,
        environment: environment,
        stdinLines: stdinLines,
        out: out,
        err: err,
      );
  }
}

/// Builds the single [Agent] used for the whole invocation, or returns a config
/// error string when the environment does not name a model.
Future<int> _runConversation({
  required PidartArgs args,
  required Map<String, String> environment,
  required Stream<String>? stdinLines,
  required void Function(String) out,
  required void Function(String) err,
}) async {
  final resolved = _modelFromEnv(environment);
  if (resolved.error case final error?) {
    err('pidart: $error\n');
    return 78; // EX_CONFIG
  }
  final model = resolved.model!;

  final agent = Agent(
    model: model,
    systemPrompt: environment['PI_SYSTEM_PROMPT'] ?? '',
    getApiKey: (provider) async =>
        environment['${provider.toUpperCase()}_API_KEY'] ??
        environment['PI_API_KEY'],
  );

  // Print each turn's assistant text as it completes; one subscription serves
  // both modes.
  agent.subscribe((event) {
    if (event is TurnEnd && event.message is AssistantMessage) {
      final text = (event.message as AssistantMessage).text;
      if (text.isNotEmpty) out('$text\n');
    }
  });

  switch (args.mode) {
    case PidartMode.oneShot:
      await agent.prompt(args.prompt);
      return 0;
    case PidartMode.interactive:
      final lines = stdinLines ??
          stdin.transform(utf8.decoder).transform(const LineSplitter());
      await for (final line in lines) {
        final prompt = line.trim();
        if (prompt.isEmpty) continue;
        if (prompt == '/exit' || prompt == '/quit') break;
        await agent.prompt(prompt);
      }
      return 0;
    default:
      return 0;
  }
}

/// Resolves the [Model] from the environment, or a human-readable config error.
({Model? model, String? error}) _modelFromEnv(Map<String, String> env) {
  final spec = env['PI_MODEL']?.trim() ?? '';
  if (spec.isEmpty) {
    return (
      model: null,
      error: 'PI_MODEL is not set; set it to `provider/model` (e.g. '
          'openai/gpt-4o) or a bare model id with PI_PROVIDER.',
    );
  }

  String provider;
  String modelId;
  if (spec.contains('/')) {
    final slash = spec.indexOf('/');
    provider = spec.substring(0, slash);
    modelId = spec.substring(slash + 1);
  } else {
    provider = env['PI_PROVIDER']?.trim() ?? 'openai';
    modelId = spec;
  }

  final contextWindow = int.tryParse(env['PI_CONTEXT_WINDOW'] ?? '') ?? 128000;

  final baseUrl = env['PI_BASE_URL']?.trim() ?? '';
  return (
    model: Model(
      provider: provider,
      modelId: modelId,
      contextWindow: contextWindow,
      baseUrl: baseUrl.isEmpty ? null : baseUrl,
    ),
    error: null,
  );
}
