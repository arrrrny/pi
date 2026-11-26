/// The `pidart` command-line surface for the Dart port of the pi coding agent.
///
/// One argument parser ([parsePidartArgs]) and one runtime ([runPidart]) serve
/// both the interactive and the one-shot invocation; `bin/pidart.dart` is a
/// thin wrapper over this library.
library;

export 'src/cli/args.dart';
export 'src/cli/runner.dart';
