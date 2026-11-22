#!/usr/bin/env node
/**
 * Purity guard: the Dart port must not import the product domain (FR-030).
 *
 * Fails (exit 1) on any import or export directive under `--root` whose target
 * begins with a forbidden prefix: `package:zuraffa`, `package:zuraffa_agent`,
 * a browser package, or product-domain code. Output is `<file>:<line>: forbidden
 * import <uri>`. This is a gate, not a warning; `coverage.yml` runs it.
 *
 * Usage:
 *   node scripts/coverage/check-purity.mjs [--root pi_agent/lib]
 */

import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative, resolve } from "node:path";

import { parseArgs } from "./lib/cli.mjs";
import { FORBIDDEN_PREFIXES } from "./lib/upstream-tree.mjs";

const IMPORT_RE = /^\s*(?:import|export)\s+(?:[^'"]*?\s+from\s+)?["']([^"']+)["']/;

function dartFiles(dir) {
	const out = [];
	for (const entry of readdirSync(dir, { withFileTypes: true })) {
		const full = join(dir, entry.name);
		if (entry.isDirectory()) {
			out.push(...dartFiles(full));
		} else if (entry.isFile() && entry.name.endsWith(".dart")) {
			out.push(full);
		}
	}
	return out;
}

function main() {
	const args = parseArgs(process.argv.slice(2));
	const root = resolve(args.root ?? "pi_agent/lib");
	let files;
	try {
		if (!statSync(root).isDirectory()) throw new Error("not a directory");
		files = dartFiles(root);
	} catch (error) {
		console.error(`check-purity: cannot read root ${root}: ${error.message}`);
		process.exit(2);
	}

	const failures = [];
	for (const file of files) {
		const lines = readFileSync(file, "utf8").split(/\r?\n/);
		lines.forEach((line, index) => {
			const match = IMPORT_RE.exec(line);
			if (!match) return;
			const uri = match[1];
			if (FORBIDDEN_PREFIXES.some((prefix) => uri === prefix || uri.startsWith(`${prefix}/`))) {
				failures.push(`${relative(process.cwd(), file)}:${index + 1}: forbidden import ${uri}`);
			}
		});
	}

	if (failures.length > 0) {
		for (const failure of failures) console.error(failure);
		console.error(`check-purity: ${failures.length} forbidden import(s) under ${args.root ?? "pi_agent/lib"}`);
		process.exit(1);
	}
	console.log(`check-purity: ${files.length} files clean under ${args.root ?? "pi_agent/lib"}`);
}

main();