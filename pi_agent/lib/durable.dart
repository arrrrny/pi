/// The durable foundation's public surface.
///
/// Port of the upstream `@earendil-works/pi-durable` and
/// `@earendil-works/pi-chord` package boundaries at upstream
/// `780bf31fcaeb252fa9b68df3964c735eae75bde3`, as far as pi#11's foundation slice
/// covers them. Generation, tools, submissions, signals and product missions are
/// pi#12 and are absent here on purpose.
///
/// ```dart
/// import 'package:pi/durable.dart';
///
/// final storage = MemoryStorage();
/// final root = await storage.mintId<ConversationKind>();
/// ```
library;

export 'src/chord/context.dart';
export 'src/chord/delta.dart';
export 'src/chord/errors.dart';
export 'src/chord/failure.dart';
export 'src/chord/ids.dart';
export 'src/chord/json.dart';
export 'src/durable/entries.dart';
export 'src/durable/env/decode.dart';
export 'src/durable/env/index.dart';
export 'src/durable/env/line_scan.dart';
export 'src/durable/errors.dart';
export 'src/durable/harness/define.dart';
export 'src/durable/harness/registry.dart';
export 'src/durable/harness/types.dart';
export 'src/durable/signals.dart';
export 'src/durable/provider.dart';
export 'src/durable/usage.dart';
export 'src/durable/storage/conformance.dart';
export 'src/durable/storage/jsonl.dart';
export 'src/durable/storage/memory.dart';
export 'src/durable/storage/sqlite.dart';
export 'src/durable/storage/storage.dart';
export 'src/durable/types.dart';
