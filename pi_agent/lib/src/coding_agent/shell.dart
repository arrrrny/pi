// Shell configuration resolution, including Git Bash discovery through git on
// PATH.
//
// Faithful port of `packages/coding-agent/src/utils/shell.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b` (`getShellConfig`,
// `getPowerShellConfig`, `ShellConfig`). The behavioral change in this sync is
// #12494: on Windows, after the known Git Bash locations, resolve Git Bash of
// the Git for Windows installation whose git.exe is on PATH before the generic
// bash.exe lookup, which usually finds the WSL launcher in System32 first.
//
// The platform, filesystem and process lookups are taken from an injected
// [ShellHost] so the resolution order is testable on any platform; production
// callers use [ProcessShellHost].

import 'dart:io' as io;

/// The resolved shell invocation: the executable, its arguments, and an
/// optional command transport.
class ShellConfig {
  /// The shell executable path.
  final String shell;

  /// The arguments passed to the shell.
  final List<String> args;

  /// How the command is delivered: `argv` (as `-c <cmd>`) or `stdin` (as
  /// `-s` with the command on standard input). Null for the default argv form.
  final String? commandTransport;

  /// Creates a shell configuration.
  const ShellConfig({
    required this.shell,
    required this.args,
    this.commandTransport,
  });

  @override
  bool operator ==(Object other) =>
      other is ShellConfig &&
      other.shell == shell &&
      _listEquals(other.args, args) &&
      other.commandTransport == commandTransport;

  @override
  int get hashCode =>
      Object.hash(shell, Object.hashAll(args), commandTransport);

  @override
  String toString() =>
      'ShellConfig(shell: $shell, args: $args, commandTransport: $commandTransport)';

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// The platform, filesystem and process operations [getShellConfig] and
/// [getPowerShellConfig] need, injected so the resolution order is testable.
abstract class ShellHost {
  /// Whether the host is Windows.
  bool get isWindows;

  /// The `ProgramFiles` environment value, or null.
  String? get programFiles;

  /// The `ProgramFiles(x86)` environment value, or null.
  String? get programFilesX86;

  /// The `SystemRoot` environment value, or null.
  String? get systemRoot;

  /// Whether [path] exists, mirroring upstream `accessSync(path, F_OK)`.
  bool shellPathExists(String path);

  /// The first match for [executable] on PATH, or null.
  String? findExecutableOnPath(String executable);

  /// The normalized `git var GIT_SHELL_PATH` output for [git], or null when
  /// git is older than 2.47 or the call fails.
  String? gitVarGitShellPath(String git);
}

/// The production [ShellHost] backed by the real platform, filesystem and
/// process table.
class ProcessShellHost implements ShellHost {
  /// Creates a host over the real platform.
  const ProcessShellHost();

  @override
  bool get isWindows => io.Platform.isWindows;

  @override
  String? get programFiles => io.Platform.environment['ProgramFiles'];

  @override
  String? get programFilesX86 => io.Platform.environment['ProgramFiles(x86)'];

  @override
  String? get systemRoot => io.Platform.environment['SystemRoot'];

  @override
  bool shellPathExists(String path) {
    try {
      io.File(path).statSync();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  String? findExecutableOnPath(String executable) {
    try {
      final command = io.Platform.isWindows ? 'where' : 'which';
      final result = io.Process.runSync(command, <String>[executable]);
      if (result.exitCode == 0) {
        final first =
            (result.stdout as String).trim().split(RegExp(r'\r?\n')).first;
        if (first.isNotEmpty) return first;
      }
    } catch (_) {
      // Ignore errors.
    }
    return null;
  }

  @override
  String? gitVarGitShellPath(String git) {
    try {
      final result = io.Process.runSync(git, <String>['var', 'GIT_SHELL_PATH']);
      if (result.exitCode == 0) {
        final out = (result.stdout as String).trim();
        return out.isEmpty ? null : out;
      }
    } catch (_) {
      // Ignore errors.
    }
    return null;
  }
}

// Git for Windows reports its POSIX shell as `<root>/usr/bin/sh.exe`.
final String _gitForWindowsShellSuffix =
    _win32Join(<String>['usr', 'bin', 'sh.exe']);

/// Resolves the shell configuration.
///
/// Resolution order:
/// 1. The user-specified [customShellPath].
/// 2. On Windows: Git Bash in known locations, then Git Bash of git on PATH,
///    then bash on PATH.
/// 3. On Unix: `/bin/bash`, then bash on PATH, then `sh`.
///
/// [host] defaults to the real platform when omitted.
ShellConfig getShellConfig({String? customShellPath, ShellHost? host}) {
  host ??= _systemHost();

  // 1. Check user-specified shell path.
  if (customShellPath != null) {
    if (host.shellPathExists(customShellPath)) {
      return _bashShellConfig(customShellPath, host);
    }
    throw StateError('Custom shell path not found: $customShellPath');
  }

  if (host.isWindows) {
    // 2. Try Git Bash in known locations.
    final paths = <String>[];
    final programFiles = host.programFiles;
    if (programFiles != null) {
      paths.add(_win32Join(<String>[programFiles, 'Git', 'bin', 'bash.exe']));
    }
    final programFilesX86 = host.programFilesX86;
    if (programFilesX86 != null) {
      paths
          .add(_win32Join(<String>[programFilesX86, 'Git', 'bin', 'bash.exe']));
    }

    for (final path in paths) {
      if (host.shellPathExists(path)) {
        return _bashShellConfig(path, host);
      }
    }

    // 3. Git Bash installed elsewhere, found through git on PATH. This must
    // precede the generic bash.exe lookup, which usually finds the WSL launcher
    // in System32 first.
    final gitBash = _findGitBashOfGitOnPath(host);
    if (gitBash != null) {
      return _bashShellConfig(gitBash, host);
    }

    // 4. Fallback: search bash.exe on PATH (Cygwin, MSYS2, WSL, etc.).
    final bashOnPath = host.findExecutableOnPath('bash.exe');
    if (bashOnPath != null) {
      return _bashShellConfig(bashOnPath, host);
    }

    throw StateError(
      'No bash shell found. Options:\n'
      '  1. Install Git for Windows: https://git-scm.com/download/win\n'
      '  2. Add your bash to PATH (Cygwin, MSYS2, etc.)\n'
      '  3. Set shellPath in settings.json\n\n'
      'Searched Git Bash in:\n${paths.map((p) => '  $p').join('\n')}\n'
      '  the Git for Windows installation of git.exe on PATH',
    );
  }

  // Unix: try /bin/bash, then bash on PATH, then fallback to sh.
  if (host.shellPathExists('/bin/bash')) {
    return _bashShellConfig('/bin/bash', host);
  }

  final bashOnPath = host.findExecutableOnPath('bash');
  if (bashOnPath != null) {
    return _bashShellConfig(bashOnPath, host);
  }

  return const ShellConfig(shell: 'sh', args: <String>['-c']);
}

/// Arguments for a PowerShell invocation.
const List<String> powershellArgs = <String>[
  '-NoProfile',
  '-NonInteractive',
  '-ExecutionPolicy',
  'Bypass',
  '-Command',
];

/// Resolves PowerShell on Windows, preferring PowerShell 7 when available.
///
/// [host] defaults to the real platform when omitted.
ShellConfig getPowerShellConfig({ShellHost? host}) {
  host ??= _systemHost();
  if (!host.isWindows) {
    throw StateError('The powershell tool is only available on Windows.');
  }

  String? shell = host.findExecutableOnPath('pwsh.exe');
  // Installation directories may be on any drive and need not be on PATH.
  final programFiles = host.programFiles;
  if (shell == null && programFiles != null) {
    final pwsh7 =
        _win32Join(<String>[programFiles, 'PowerShell', '7', 'pwsh.exe']);
    if (host.shellPathExists(pwsh7)) shell = pwsh7;
  }

  shell ??= host.findExecutableOnPath('powershell.exe');
  final systemRoot = host.systemRoot;
  if (shell == null && systemRoot != null) {
    final windowsPowerShell = _win32Join(<String>[
      systemRoot,
      'System32',
      'WindowsPowerShell',
      'v1.0',
      'powershell.exe',
    ]);
    if (host.shellPathExists(windowsPowerShell)) shell = windowsPowerShell;
  }

  if (shell == null) {
    throw StateError(
        'No PowerShell executable found. Install PowerShell or add powershell.exe/pwsh.exe to PATH.');
  }

  return ShellConfig(shell: shell, args: List<String>.of(powershellArgs));
}

/// Whether [path] is a legacy WSL launcher under the actual Windows directory.
///
/// Keep in sync with `packages/durable/src/env/node.ts`.
bool isLegacyWslBashPath(String path, {String? systemRoot}) {
  final normalized = _win32Normalize(path).toLowerCase();
  if (systemRoot != null) {
    if (!_isWindowsDriveRoot(systemRoot)) return false;
    return <String>['System32', 'Sysnative'].any(
      (directory) =>
          normalized ==
          _win32Join(<String>[systemRoot, directory, 'bash.exe']).toLowerCase(),
    );
  }
  // Fall back to conventional launcher paths only when the Windows directory
  // is unknown.
  return RegExp(r'^[a-z]:\\windows\\(?:system32|sysnative)\\bash\.exe$')
      .hasMatch(normalized);
}

ShellConfig _bashShellConfig(String shell, ShellHost host) =>
    isLegacyWslBashPath(shell, systemRoot: host.systemRoot)
        ? ShellConfig(
            shell: shell, args: <String>['-s'], commandTransport: 'stdin')
        : ShellConfig(shell: shell, args: <String>['-c']);

/// Finds Git Bash of the Git for Windows installation whose git.exe is on PATH.
///
/// Git itself reports where it is installed (`git var GIT_SHELL_PATH`, Git
/// 2.47+), so this works for any install directory and any PATH layout. It
/// returns `<root>\bin\bash.exe`, not the shell Git reports: that launcher sets
/// up MSYSTEM and PATH, without which `usr\bin\bash.exe` cannot find tools like
/// `ls`.
String? _findGitBashOfGitOnPath(ShellHost host) {
  final git = host.findExecutableOnPath('git.exe');
  if (git == null) return null;
  final gitShell = host.gitVarGitShellPath(git);
  if (gitShell == null) return null;
  final normalized = _win32Normalize(gitShell);
  if (!normalized.toLowerCase().endsWith('\\$_gitForWindowsShellSuffix')) {
    return null;
  }
  final bash = _win32Join(<String>[
    normalized.substring(
        0, normalized.length - _gitForWindowsShellSuffix.length),
    'bin',
    'bash.exe',
  ]);
  return host.shellPathExists(bash) ? bash : null;
}

ShellHost _systemHost() => const ProcessShellHost();

// --- Windows path helpers (independent of the host OS) ---

String _win32Join(List<String> parts) {
  final out = StringBuffer();
  for (var i = 0; i < parts.length; i++) {
    final part = parts[i];
    if (part.isEmpty) continue;
    if (out.isNotEmpty && !out.toString().endsWith('\\')) out.write('\\');
    out.write(part);
  }
  return out.toString();
}

String _win32Normalize(String path) {
  final normalized = path.replaceAll('/', '\\');
  // Collapse repeated separators and resolve `.` / `..` segments the way
  // path.win32.normalize does for the cases the resolution order produces.
  final isUnc = normalized.startsWith('\\\\');
  final segments = normalized.split('\\');
  final resolved = <String>[];
  for (final segment in segments) {
    if (segment.isEmpty || segment == '.') continue;
    if (segment == '..') {
      if (resolved.isNotEmpty && resolved.last != '..') {
        resolved.removeLast();
      } else if (!isUnc) {
        resolved.add(segment);
      }
      continue;
    }
    resolved.add(segment);
  }
  final prefix = isUnc ? '\\\\' : '';
  final body = resolved.join('\\');
  // Preserve a trailing separator for a drive root like `D:\`.
  final trailing =
      (normalized.endsWith('\\') || normalized.endsWith('/')) ? '\\' : '';
  if (body.isEmpty) return '$prefix$trailing';
  return '$prefix$body$trailing';
}

bool _isWindowsDriveRoot(String path) =>
    RegExp(r'^[a-z]:[\\/]', caseSensitive: false).hasMatch(path);
