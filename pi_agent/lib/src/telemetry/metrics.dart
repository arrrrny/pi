/// Metric instrument contracts ported from `@earendil-works/pi-telemetry`.
///
/// Typed inputs are trusted; callers supply finite measurements and
/// nonnegative counter increments. Malformed input behavior is unspecified.
library;

import 'types.dart';

/// Options shared by all instruments.
class InstrumentOptions {
  /// Creates instrument options with optional [description] and [unit].
  const InstrumentOptions({this.description, this.unit});

  /// A human-readable description of the instrument.
  final String? description;

  /// The unit of the recorded values.
  final String? unit;
}

/// Options for a histogram instrument.
class HistogramOptions extends InstrumentOptions {
  /// Creates histogram options with optional bucket [boundaries].
  const HistogramOptions({super.description, super.unit, this.boundaries});

  /// Bucket hints; callers supply finite, strictly increasing values.
  final List<num>? boundaries;
}

/// A monotonically increasing counter instrument.
abstract interface class TelemetryCounter {
  /// Adds [value] with optional [attributes].
  void add(num value, [SpanAttributes? attributes]);
}

/// A counter that may increase or decrease.
abstract interface class TelemetryUpDownCounter {
  /// Adds [value] (which may be negative) with optional [attributes].
  void add(num value, [SpanAttributes? attributes]);
}

/// A distribution-recording instrument.
abstract interface class TelemetryHistogram {
  /// Records [value] with optional [attributes] and [context].
  void record(num value, [SpanAttributes? attributes, TelemetryContext? context]);
}

/// Optional adapter capability with synchronous instrument factories.
abstract interface class TelemetryMetrics {
  /// Creates a counter named [name].
  TelemetryCounter counter(String name, [InstrumentOptions? options]);

  /// Creates an up/down counter named [name].
  TelemetryUpDownCounter upDownCounter(String name, [InstrumentOptions? options]);

  /// Creates a histogram named [name].
  TelemetryHistogram histogram(String name, [HistogramOptions? options]);
}