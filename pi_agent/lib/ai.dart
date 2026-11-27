/// AI provider utilities ported from upstream `packages/ai`.
///
/// The value-add of this fork is the Dart port; this library collects the
/// self-contained behavioral utilities ported from `packages/ai/src/utils/`
/// as the daily upstream sync lands them. Each file names the upstream source
/// and commit it ports.
library;

export 'package:pi/pi.dart' show AssistantMessage, StopReason, Usage;

export 'src/ai/anthropic_stream.dart';
export 'src/ai/google_stream.dart';
export 'src/ai/mistral_stream.dart';
export 'src/ai/openai_stream.dart';
export 'src/ai/overflow.dart';
export 'src/ai/provider_event_stream.dart';
export 'src/ai/provider_events.dart';
export 'src/ai/provider_error.dart';
export 'src/ai/provider_identity.dart';
export 'src/ai/provider_retry.dart';
export 'src/ai/provider_stop_reason.dart';
export 'src/ai/sse_decoder.dart';
export 'src/ai/streaming_json.dart';
export 'src/ai/transcript.dart';
