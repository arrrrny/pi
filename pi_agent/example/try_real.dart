import 'dart:io';

import 'package:pi/pi.dart';

/// Real end-to-end run of the Dart port against an OpenAI-compatible endpoint.
///
/// Environment:
///   PI_API_KEY  (required)  API key / bearer token
///   PI_BASE_URL (optional)  defaults to http://localhost:8317/v1
///   PI_MODEL    (optional)  defaults to kilo/baidu/ernie-5.5-flash-preview:free
///
/// Usage: PI_API_KEY=... dart run example/try_real.dart "your prompt"
Future<void> main(List<String> args) async {
  final apiKey = Platform.environment['PI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('Set PI_API_KEY (optionally PI_BASE_URL, PI_MODEL).');
    exit(2);
  }
  final baseUrl = Platform.environment['PI_BASE_URL'] ?? 'http://localhost:8317/v1';
  final modelId =
      Platform.environment['PI_MODEL'] ?? 'kilo/baidu/ernie-5.5-flash-preview:free';

  final agent = Agent(
    model: Model(
      provider: 'openai',
      modelId: modelId,
      contextWindow: 128000,
      baseUrl: baseUrl,
    ),
    systemPrompt: 'You are a concise, helpful assistant.',
    getApiKey: (_) async => apiKey,
  );

  var updates = 0;
  agent.subscribe((event) {
    switch (event) {
      case MessageUpdate():
        updates++;
      case MessageEnd(message: final m):
        if (m is AssistantMessage) {
          stdout.writeln('[updates=$updates blocks=${m.content.length}]');
          stdout.writeln(m.text);
        }
      default:
        break;
    }
  });

  final prompt = args.isNotEmpty
      ? args.join(' ')
      : 'In one short sentence, greet me and name the model you are.';

  stderr.writeln('>>> $prompt');
  await agent.prompt(prompt);
}