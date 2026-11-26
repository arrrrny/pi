/// The `pidart` executable: the Dart port of the pi coding agent.
///
/// Exposed through pubspec.yaml as exactly `pidart` (pi#50). All behavior
/// lives in `package:pi/cli.dart`; this file only forwards the process
/// arguments and exit code.
library;

import 'dart:io';

import 'package:pi/cli.dart';

Future<void> main(List<String> args) async {
  exitCode = await runPidart(parsePidartArgs(args));
}
