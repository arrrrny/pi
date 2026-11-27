import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:pi/src/types.dart' hide AgentTool;
import 'package:pi/src/conversion.dart';
import 'package:pi/src/proxy.dart';

/// A minimal proxy server for hermetic streamProxy tests.
///
/// Records the last request it received and streams back a canned set of
/// `data:` frames carrying ProxyAssistantMessageEvent JSON, so the proxy
/// adapter's request building and reconstruction can be verified without any
/// real network access (packages/agent/src/proxy.ts).
class _FakeProxyServer {
  _FakeProxyServer(this.frames, {this.statusCode = 200});

  final List<String> frames;
  final int statusCode;
  HttpServer? _server;
  Map<String, dynamic>? lastBody;
  String? lastAuth;
  String? lastPath;

  Uri get url => Uri.parse('http://127.0.0.1:${_server!.port}');

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) async {
      lastPath = request.uri.path;
      lastAuth = request.headers.value('authorization');
      final raw = await utf8.decoder.bind(request).join();
      lastBody = raw.isEmpty ? null : jsonDecode(raw) as Map<String, dynamic>;
      request.response.statusCode = statusCode;
      if (statusCode != 200) {
        request.response.headers.set('content-type', 'application/json');
        request.response.write('{"error":"boom"}');
        await request.response.close();
        return;
      }
      request.response.headers.set('content-type', 'text/event-stream');
      for (final frame in frames) {
        request.response.write('data: $frame\n\n');
      }
      await request.response.close();
    });
  }

  Future<void> stop() => _server!.close(force: true);
}

AgentLoopConfig makeConfig(Model model) =>
    AgentLoopConfig(model: model, convertToLlm: convertToLlm);

Model makeModel() => const Model(
      provider: 'openai',
      modelId: 'gpt-test',
      contextWindow: 8000,
    );

ProxyStreamOptions makeOptions(Uri url) =>
    ProxyStreamOptions(authToken: 'tok-123', proxyUrl: url.origin);

MessageEnd singleEnd(List<AgentEvent> events) =>
    events.whereType<MessageEnd>().single;

void main() {
  group('streamProxy (proxy stream adapter)', () {
    test('reconstructs a text response from proxy events', () async {
      final server = _FakeProxyServer([
        '{"type":"start"}',
        '{"type":"text_start","contentIndex":0}',
        '{"type":"text_delta","contentIndex":0,"delta":"Hello"}',
        '{"type":"text_delta","contentIndex":0,"delta":" world"}',
        '{"type":"text_end","contentIndex":0}',
        '{"type":"done","reason":"stop","usage":{"input":3,"output":5,"cacheRead":0,"cacheWrite":0,"totalTokens":8,"cost":{"input":0,"output":0,"cacheRead":0,"cacheWrite":0,"total":0}}}',
      ]);
      await server.start();
      addTearDown(server.stop);

      final events = await streamProxy(
        context: const AgentContext(systemPrompt: '', messages: []),
        config: makeConfig(makeModel()),
        options: makeOptions(server.url),
      ).toList();

      final end = singleEnd(events);
      expect((end.message as AssistantMessage).stopReason, StopReason.endTurn);
      expect((end.message as AssistantMessage).text, 'Hello world');
      // Request shape: Bearer auth, /api/stream path, model+context+options body.
      expect(server.lastAuth, 'Bearer tok-123');
      expect(server.lastPath, '/api/stream');
      expect(server.lastBody!['model'], isA<Map<String, dynamic>>());
      expect(server.lastBody!['options'], isA<Map<String, dynamic>>());
    });

    test('reconstructs a tool call from proxy events', () async {
      final server = _FakeProxyServer([
        '{"type":"start"}',
        '{"type":"toolcall_start","contentIndex":0,"id":"call_1","toolName":"calc"}',
        '{"type":"toolcall_delta","contentIndex":0,"delta":"{\\"x\\":"}',
        '{"type":"toolcall_delta","contentIndex":0,"delta":"1}"}',
        '{"type":"toolcall_end","contentIndex":0,"toolCall":{"type":"toolCall","id":"call_1","name":"calc","arguments":{"x":1}}}',
        '{"type":"done","reason":"toolUse","usage":{"input":1,"output":2,"cacheRead":0,"cacheWrite":0,"totalTokens":3,"cost":{"input":0,"output":0,"cacheRead":0,"cacheWrite":0,"total":0}}}',
      ]);
      await server.start();
      addTearDown(server.stop);

      final events = await streamProxy(
        context: const AgentContext(systemPrompt: '', messages: []),
        config: makeConfig(makeModel()),
        options: makeOptions(server.url),
      ).toList();

      final end = singleEnd(events);
      expect((end.message as AssistantMessage).stopReason, StopReason.toolUse);
      final calls = (end.message as AssistantMessage).toolCalls;
      expect(calls.single.id, 'call_1');
      expect(calls.single.name, 'calc');
      expect(calls.single.arguments, {'x': 1});
    });

    test('maps a proxy error event to an error terminal message', () async {
      final server = _FakeProxyServer([
        '{"type":"start"}',
        '{"type":"error","reason":"error","errorMessage":"upstream failed","usage":{"input":0,"output":0,"cacheRead":0,"cacheWrite":0,"totalTokens":0,"cost":{"input":0,"output":0,"cacheRead":0,"cacheWrite":0,"total":0}}}',
      ]);
      await server.start();
      addTearDown(server.stop);

      final events = await streamProxy(
        context: const AgentContext(systemPrompt: '', messages: []),
        config: makeConfig(makeModel()),
        options: makeOptions(server.url),
      ).toList();

      final end = singleEnd(events);
      expect((end.message as AssistantMessage).stopReason, StopReason.error);
      expect((end.message as AssistantMessage).errorMessage, 'upstream failed');
    });

    test('surfaces a clean EOF without a terminal event as an error', () async {
      final server = _FakeProxyServer([
        '{"type":"start"}',
        '{"type":"text_start","contentIndex":0}',
        '{"type":"text_delta","contentIndex":0,"delta":"partial"}',
      ]);
      await server.start();
      addTearDown(server.stop);

      final events = await streamProxy(
        context: const AgentContext(systemPrompt: '', messages: []),
        config: makeConfig(makeModel()),
        options: makeOptions(server.url),
      ).toList();

      final end = singleEnd(events);
      expect((end.message as AssistantMessage).stopReason, StopReason.error);
      expect((end.message as AssistantMessage).errorMessage,
          contains('before the response completed'));
    });

    test('maps a non-200 proxy response to an error terminal message',
        () async {
      final server = _FakeProxyServer([], statusCode: 401);
      await server.start();
      addTearDown(server.stop);

      final events = await streamProxy(
        context: const AgentContext(systemPrompt: '', messages: []),
        config: makeConfig(makeModel()),
        options: makeOptions(server.url),
      ).toList();

      final end = singleEnd(events);
      expect((end.message as AssistantMessage).stopReason, StopReason.error);
      expect((end.message as AssistantMessage).errorMessage,
          contains('Proxy error'));
    });
  });
}
