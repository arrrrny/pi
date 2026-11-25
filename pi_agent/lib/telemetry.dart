/// The telemetry foundation's public surface.
///
/// Dart port of the runtime surface of upstream `@earendil-works/pi-telemetry`
/// at the registry-pinned SHA: backend-neutral span/trace/metric contracts, an
/// in-memory recorder, no-op capabilities, and trace rendering. The upstream
/// TypeScript type-level schema inference is compile-time only and has no Dart
/// runtime equivalent; the runtime behavior is ported with differential parity.
///
/// ```dart
/// import 'package:pi/telemetry.dart';
///
/// final telemetry = InMemoryTelemetryContext();
/// await telemetry.startSpan(SpanOptions(name: 'root'), (span) async {
///   span.addEvent('checkpoint');
/// });
/// ```
library;

export 'src/telemetry/types.dart';
export 'src/telemetry/metrics.dart';
export 'src/telemetry/memory.dart';
export 'src/telemetry/noop.dart';
export 'src/telemetry/render.dart';
