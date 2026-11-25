// Shell configuration resolution, including Git Bash discovery through git on
// PATH.
//
// Port of `packages/coding-agent/src/utils/shell.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b` (`getShellConfig`,
// `getPowerShellConfig`, `ShellConfig`). The behavioral change in this sync is
// #12494: on Windows, after the known Git Bash locations, resolve Git Bash of
// the Git for Windows installation whose git.exe is on PATH (`git var
// GIT_SHELL_PATH`, Git 2.47+) before the generic bash.exe lookup, which usually
// finds the WSL launcher in System32 first. The host is injected so the Windows
// resolution order is exercised on any platform.

import 'package:pi/coding_agent.dart';
import 'package:test/test.dart';

/// A fake [ShellHost] recording the lookups made and the spawns run.
class _FakeHost implements ShellHost {
  _FakeHost({
    required this.isWindows,
    this.programFiles,
    this.programFilesX86,
    this.systemRoot,
    required List<String> installed,
    required this.onPath,
    this.gitShellPath,
  }) : _installed = installed.toSet();

  @override
  final bool isWindows;
  @override
  final String? programFiles;
  @override
  final String? programFilesX86;
  @override
  final String? systemRoot;

  final Set<String> _installed;
  final Map<String, String?> onPath;
  final String? gitShellPath;
  int gitVarCalls = 0;

  @override
  bool shellPathExists(String path) => _installed.contains(path);

  @override
  String? findExecutableOnPath(String executable) {
    final found = onPath[executable];
    return (found != null && _installed.contains(found)) ? found : null;
  }

  @override
  String? gitVarGitShellPath(String git) {
    gitVarCalls++;
    return gitShellPath;
  }
}

void main() {
  group('legacy WSL bash detection', () {
    // #9490: identify legacy WSL launchers under the actual Windows directory.
    final cases = <List<Object?>>[
      ['D:\\WinNT\\', 'd:/WINNT/System32/BASH.EXE', true],
      ['D:\\WinNT', 'D:\\WinNT\\Sysnative\\bash.exe', true],
      [null, 'E:\\Windows\\System32\\bash.exe', true],
      ['D:\\WinNT', 'D:\\Git\\bin\\bash.exe', false],
      ['D:\\WinNT', 'E:\\Windows\\System32\\bash.exe', false],
      ['WinNT', 'C:\\Windows\\System32\\bash.exe', false],
    ];

    for (final c in cases) {
      final systemRoot = c[0] as String?;
      final shell = c[1] as String;
      final stdin = c[2] as bool;
      test('resolves $systemRoot / $shell to stdin=$stdin', () {
        final host = _FakeHost(
          isWindows: true,
          systemRoot: systemRoot,
          installed: <String>[shell],
          onPath: <String, String?>{},
        );

        expect(
          getShellConfig(customShellPath: shell, host: host),
          equals(stdin
              ? ShellConfig(
                  shell: shell, args: <String>['-s'], commandTransport: 'stdin')
              : ShellConfig(shell: shell, args: <String>['-c'])),
        );
      });
    }
  });

  group('Git Bash discovery through git on PATH', () {
    const git = 'G:\\Programmi Aggiuntivi\\Git\\cmd\\git.exe';
    const gitBash = 'G:\\Programmi Aggiuntivi\\Git\\bin\\bash.exe';
    const wslBash = 'C:\\Windows\\System32\\bash.exe';

    _FakeHost baseHost(String? gitShellPath,
        {required List<String> installed}) {
      return _FakeHost(
        isWindows: true,
        programFiles: 'C:\\Program Files',
        programFilesX86: 'C:\\Program Files (x86)',
        systemRoot: 'C:\\Windows',
        installed: installed,
        onPath: <String, String?>{'git.exe': git, 'bash.exe': wslBash},
        gitShellPath: gitShellPath,
      );
    }

    test('prefers Git Bash of git on PATH over the WSL launcher on PATH', () {
      final host = baseHost(
        'G:/Programmi Aggiuntivi/Git/usr/bin/sh.exe',
        installed: <String>[git, gitBash, wslBash],
      );

      expect(
        getShellConfig(host: host),
        equals(ShellConfig(shell: gitBash, args: <String>['-c'])),
      );
    });

    test('keeps Git Bash under ProgramFiles first without running git', () {
      const programFilesBash = 'C:\\Program Files\\Git\\bin\\bash.exe';
      final host = baseHost(
        'G:/Programmi Aggiuntivi/Git/usr/bin/sh.exe',
        installed: <String>[programFilesBash, git, gitBash],
      );

      expect(
        getShellConfig(host: host),
        equals(ShellConfig(shell: programFilesBash, args: <String>['-c'])),
      );
      expect(host.gitVarCalls, 0);
    });

    for (final c in <List<Object?>>[
      ['git without GIT_SHELL_PATH (before 2.47)', null],
      ['a shell outside a Git for Windows layout', 'G:/Tools/sh.exe'],
      [
        'a Git for Windows root without its Bash launcher',
        'G:/Programmi Aggiuntivi/Other/usr/bin/sh.exe',
      ],
    ]) {
      final name = c[0] as String;
      final gitShellPath = c[1] as String?;
      test('falls back to bash.exe on PATH for $name', () {
        final host = baseHost(
          gitShellPath,
          installed: <String>[git, gitBash, wslBash],
        );

        expect(
          getShellConfig(host: host),
          equals(ShellConfig(
              shell: wslBash, args: <String>['-s'], commandTransport: 'stdin')),
        );
      });
    }
  });
}
