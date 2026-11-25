/// The schema foundation's public surface.
///
/// Dart port of the validation surface of upstream `@earendil-works/pi-schema`
/// at the registry-pinned SHA: a draft-07 JSON Schema validator subset and the
/// string `format` checks. Differential parity is proven against the official
/// JSON-Schema-Test-Suite fixtures bundled under `test/schema/fixtures`.
///
/// ```dart
/// import 'package:pi/schema.dart';
///
/// final validator = SchemaValidator({'type': 'integer'});
/// validator.check({'type': 'integer'}, 1); // true
/// ```
library;

export 'src/schema/validator.dart';
export 'src/schema/formats.dart';
