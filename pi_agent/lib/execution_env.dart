/// The execution environment surface: the local filesystem/shell environment,
/// and the remote pi-env daemon client (connection, process and terminal).
///
/// The local half is the port of `packages/durable`'s `ExecutionEnv`; the remote
/// half ports `packages/env/src/{connection,errors,process,terminal}.ts` at the
/// pinned upstream SHA.
library;

export 'src/execution_env.dart';
export 'src/env/connection.dart';
export 'src/env/errors.dart';
export 'src/env/process.dart';
export 'src/env/terminal.dart';
