// Argument parsing for the `pidart` command-line entrypoint.
//
// One parser serves both the interactive and the one-shot surface (pi#50): no
// arguments selects interactive mode, positional words form a one-shot prompt,
// and `--` forces the rest to be treated as the prompt.

/// The version reported by `pidart --version`.
///
/// Kept in step with the `version:` in pubspec.yaml by a test, so the two can
/// never drift.
const String pidartVersion = '0.2.0';

/// What `pidart` should do, decided entirely from its arguments.
enum PidartMode {
  /// Print usage and exit successfully.
  help,

  /// Print the version and exit successfully.
  version,

  /// Read prompts from stdin and run them in one conversation.
  interactive,

  /// Run a single prompt given on the command line.
  oneShot,

  /// The arguments were invalid; [PidartArgs.error] names the problem.
  error,
}

/// The parsed `pidart` invocation.
class PidartArgs {
  /// The selected mode.
  final PidartMode mode;

  /// The one-shot prompt, when [mode] is [PidartMode.oneShot].
  final String? prompt;

  /// The diagnostic, when [mode] is [PidartMode.error].
  final String? error;

  /// Creates a parsed invocation.
  const PidartArgs({required this.mode, this.prompt, this.error});
}

/// Parses the raw `pidart` arguments (without the executable name).
///
/// - no arguments, or only `--`, selects interactive mode;
/// - `--help`/`-h` and `--version`/`-v` select their modes;
/// - `--` makes every following token positional;
/// - any other leading-dash token is an error naming the flag;
/// - positional tokens are joined with spaces into a one-shot prompt.
PidartArgs parsePidartArgs(List<String> args) {
  var positionalOnly = false;
  final positionals = <String>[];

  for (final arg in args) {
    if (!positionalOnly && arg == '--') {
      positionalOnly = true;
      continue;
    }
    if (!positionalOnly && arg.startsWith('-')) {
      switch (arg) {
        case '--help':
        case '-h':
          return const PidartArgs(mode: PidartMode.help);
        case '--version':
        case '-v':
          return const PidartArgs(mode: PidartMode.version);
        default:
          return PidartArgs(
            mode: PidartMode.error,
            error: 'unknown option: $arg',
          );
      }
    }
    positionals.add(arg);
  }

  if (positionals.isEmpty) {
    return const PidartArgs(mode: PidartMode.interactive);
  }
  return PidartArgs(mode: PidartMode.oneShot, prompt: positionals.join(' '));
}

/// The usage text printed by `pidart --help`.
String pidartUsage() => '''
pidart $pidartVersion — the Dart port of the pi coding agent.

Usage:
  pidart                 Start an interactive session (reads stdin).
  pidart <prompt...>     Run a single prompt and print the reply.
  pidart --help, -h      Show this help.
  pidart --version, -v   Show the version.

Configuration (environment):
  PI_MODEL               Model to run, as `provider/model` or a bare id.
  PI_PROVIDER            Provider name when PI_MODEL is a bare id (openai).
  PI_BASE_URL            Override the OpenAI-compatible endpoint.
  PI_CONTEXT_WINDOW      Context window in tokens (default 128000).
  PI_API_KEY, <PROVIDER>_API_KEY
                         API key for the provider.

Install:
  dart pub global activate pi
''';
