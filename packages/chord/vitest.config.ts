// Chord's Node tests use workspace sources and canonical temporary paths.

import { realpathSync } from "node:fs";
import { tmpdir } from "node:os";
import { defineConfig } from "vitest/config";

// Spawned processes and bundles still need built workspace packages.
export default defineConfig({
	test: {
		environment: "node",
		// Heavy deterministic property tests (e.g. the 100x100 state-fuzz convergence
		// run) exceed the 5s default under the concurrency a shared host runs at, and an
		// uncapped worker fan starves the host (fleet guard: cap test concurrency at 2).
		testTimeout: 30000,
		maxWorkers: 2,
		// Fixtures and esbuild must name the same files when macOS's temporary directory is a symlink.
		env: { TMPDIR: realpathSync(tmpdir()) },
	},
	resolve: { conditions: ["source"] },
	ssr: { resolve: { conditions: ["source"] } },
});
