/// AI provider utilities ported from upstream `packages/ai`.
///
/// The value-add of this fork is the Dart port; this library collects the
/// self-contained behavioral utilities ported from `packages/ai/src/utils/`
/// as the daily upstream sync lands them. Each file names the upstream source
/// and commit it ports.
library;

export 'package:pi/pi.dart' show AssistantMessage, StopReason, Usage;

export 'src/ai/overflow.dart';
export 'src/ai/sse_decoder.dart';