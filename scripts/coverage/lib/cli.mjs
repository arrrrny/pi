import { readFileSync } from "node:fs";

/**
 * CLI plumbing for the coverage tools.
 *
 * A coverage script has one job: parse `--flags`, do the work, exit with a
 * documented code, and print a human summary (or `--json` payload) that the
 * contract in `specs/002-upstream-coverage-governance/contracts/coverage-ledger.md`
 * names. These helpers keep the scripts thin so the behavior is testable.
 */

/** Parse `--flag value` and `--flag` pairs from `process.argv.slice(2)`. */
export function parseArgs(argv) {
	const args = {};
	for (let index = 0; index < argv.length; index += 1) {
		const token = argv[index];
		if (!token.startsWith("--")) continue;
		const key = token.slice(2);
		const next = argv[index + 1];
		if (next !== undefined && !next.startsWith("--")) {
			args[key] = next;
			index += 1;
		} else {
			args[key] = true;
		}
	}
	return args;
}

/** Join non-empty lines with a newline. */
export function lineList(items) {
	return items.filter((item) => item !== undefined && item !== null && item !== "").join("\n");
}

/** Print a failure list to stderr and return the process exit code. */
export function failWith(errors, code = 1) {
	for (const error of errors) console.error(error);
	return code;
}

/**
 * Read and JSON-parse a file, or exit 2 with a named message. Used by every
 * script so a missing input never becomes an unhandled throw.
 */
export function readJsonOrExit(path, label) {
	try {
		return JSON.parse(readFileSync(path, "utf8"));
	} catch (error) {
		console.error(`${label}: cannot read ${path}: ${error.message}`);
		process.exit(2);
	}
}