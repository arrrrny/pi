/**
 * Upstream coverage governance tooling.
 *
 * Shared by the coverage generator, the manifest/report/check gates, and the
 * differential harness. Dependency-free by design: the generator runs against a
 * local checkout of the upstream tree (which is TypeScript source) with no
 * network, no database, and no paid provider, so it must not reach for a
 * TypeScript toolchain the CI box may not have installed. Export and source
 * enumeration therefore use a self-contained scanner over the declared entry
 * points and `src/**`, and the manifest records its own generator version so a
 * ledger can be challenged against the scanner that produced it.
 *
 * This module is intentionally the only place that knows the upstream layout:
 * the CLI scripts stay thin so their behavior is testable in isolation.
 */

import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, join, normalize, relative, sep } from "node:path";

/** The 12 upstream package areas the ledger must inventory (FR-002). */
export const AREA_ORDER = [
	"schema",
	"telemetry",
	"chord",
	"ai",
	"agent",
	"durable",
	"codemode",
	"env",
	"mcp",
	"coding-agent",
	"tui",
	"evals",
];

/** Valid row statuses (FR-004). */
export const STATUSES = ["unported", "in_progress", "implemented_unverified", "verified", "not_applicable"];

/** Statuses that pass the release gate. */
export const PASSING_STATUSES = ["verified", "not_applicable"];

/** Statuses that MUST carry a divergence and a tracking issue (FR-005). */
export const DIVERGENCE_STATUSES = ["unported", "in_progress", "implemented_unverified"];

/** Valid app decisions (FR-028). */
export const APP_DECISIONS = ["port", "adapt", "not_applicable"];

/** Forbidden import prefixes for the purity gate (FR-030). */
export const FORBIDDEN_PREFIXES = [
	"package:zuraffa",
	"package:zuraffa_agent",
	"package:zuraffa_browser",
	"package:zuraffa_browser_agent",
	"package:browser",
	"package:product",
	"package:pi_product",
];

/**
 * The package directory that backs each ledger area.
 *
 * Areas `tui` and `evals` are enumerated from their directories even though they
 * ship no `exports` map today; the manifest still records them with a zero
 * export count so "covered" means "inventoried and decided", not "omitted".
 */
export function areaDirectory(area) {
	return `packages/${area}`;
}

/**
 * Map an upstream file path to its ledger area, or `null` when it is not under a
 * known package.
 */
export function areaForPath(path) {
	const match = /^packages\/([^/]+)\//.exec(path);
	if (!match) return null;
	return match[1];
}

/** Is `path` under one of the 12 known package areas? */
export function isKnownArea(area) {
	return AREA_ORDER.includes(area);
}

/** Enumerate the package directories present under `packages/` in the tree. */
export function listPackageAreas(upstreamRoot) {
	const packagesDir = join(upstreamRoot, "packages");
	if (!existsSync(packagesDir)) return [];
	return readdirSync(packagesDir, { withFileTypes: true })
		.filter((entry) => entry.isDirectory() && existsSync(join(packagesDir, entry.name, "package.json")))
		.map((entry) => entry.name)
		.sort();
}

/** Recursively list every file under `dir`, repo-relative with `/` separators. */
export function listFilesRecursive(root, dir) {
	const absolute = join(root, dir);
	if (!existsSync(absolute)) return [];
	const out = [];
	const walk = (current) => {
		for (const entry of readdirSync(current, { withFileTypes: true })) {
			if (entry.name === "node_modules" || entry.name === "dist" || entry.name.startsWith(".")) continue;
			const full = join(current, entry.name);
			if (entry.isDirectory()) {
				walk(full);
			} else {
				out.push(relative(root, full).split(sep).join("/"));
			}
		}
	};
	walk(absolute);
	return out.sort();
}

/**
 * Resolve the `src` entry files for a package: its declared entry points from
 * the `exports` map when it has one, plus `src/index.*` / `src/index/**` as the
 * fallback for packages without an `exports` map.
 */
export function packageEntryFiles(upstreamRoot, area) {
	const packageDir = join(upstreamRoot, areaDirectory(area));
	const packageJson = JSON.parse(readFileSync(join(packageDir, "package.json"), "utf8"));
	const sourceEntries = new Set();
	const exportsMap = packageJson.exports;
	if (exportsMap && typeof exportsMap === "object") {
		for (const [key, value] of Object.entries(exportsMap)) {
			if (key === "./package.json") continue;
			const source = typeof value === "string" ? value : value?.source;
			if (typeof source === "string" && source.startsWith("./src/")) {
				sourceEntries.add(relative(upstreamRoot, join(packageDir, source)).split(sep).join("/"));
			}
		}
	}
	if (sourceEntries.size === 0) {
		const indexCandidates = listFilesRecursive(upstreamRoot, `${areaDirectory(area)}/src`).filter((p) =>
			/(^|\/)index\.(ts|tsx|mts|js|mjs)$/.test(p),
		);
		for (const candidate of indexCandidates) sourceEntries.add(candidate);
	}
	return { packageJson, entryFiles: [...sourceEntries].sort() };
}

const EXPORT_DECLARATION =
	/^export\s+(?:declare\s+)?(?:default\s+)?(?:async\s+)?(?:abstract\s+)?(function\*?|class|interface|type|const|let|var|enum|namespace)\s+([A-Za-z_$][A-Za-z0-9_$]*)/;

/**
 * Scan one source file for exported names. Returns `{ name, kind, typeOnly }`.
 * `type_only` marks `export interface|type`, which the compiler API would erase
 * before Node sees them; the inventory records them so completeness is honest
 * about the public surface rather than only its value exports.
 */
export function scanExports(source) {
	const exports = [];
	const lines = source.split(/\r?\n/);
	for (const line of lines) {
		const match = EXPORT_DECLARATION.exec(line.trim());
		if (match) {
			const kind = match[1].replace(/\*$/, "");
			exports.push({
				name: match[2],
				kind,
				type_only: kind === "interface" || kind === "type",
			});
			continue;
		}
		// `export { a, b }` and `export { a } from "./mod"` — the export list is
		// what makes a symbol public even when declared elsewhere in the file.
		const listMatch = /^export\s+(?:type\s+)?\{([^}]*)\}\s*(?:from\s+["']([^"']+)["'])?;/.exec(line.trim());
		if (listMatch) {
			const typeOnly = /^export\s+type\s*\{/.test(line.trim());
			const from = listMatch[2] ?? null;
			for (const part of listMatch[1].split(",")) {
				const name = part.trim().split(/\s+as\s+/).pop()?.trim();
				if (name && /^[A-Za-z_$][A-Za-z0-9_$]*$/.test(name)) {
					exports.push({ name, kind: "alias", type_only: typeOnly, from });
				}
			}
			continue;
		}
		// `export * from "./mod"` — a star re-export makes every symbol of the
		// target module public through this file. It is recorded as a star alias
		// so the inventory can follow it to the declaring file.
		const starMatch = /^export\s+\*\s+from\s+["']([^"']+)["'];/.exec(line.trim());
		if (starMatch) {
			exports.push({ name: "*", kind: "star", type_only: false, from: starMatch[1] });
		}
	}
	return exports;
}

/**
 * Resolve a relative import specifier to a source file under `src/`.
 * Handles `./x`, `./x.ts`, and `../y/z` relative to `fromFile`.
 */
function resolveRelative(fromFile, specifier) {
	const base = normalize(join(dirname(fromFile), specifier));
	for (const ext of ["", ".ts", ".tsx", ".mts", ".js", ".mjs", "/index.ts", "/index.tsx"]) {
		const candidate = `${base}${ext}`;
		if (existsSync(candidate)) return candidate;
	}
	return null;
}

/**
 * Build the per-package export inventory: every entry point and every
 * `src/**` file, each with the exports it declares. This is the input the
 * completeness check and the export diff compare (FR-010).
 *
 * A re-export (`export { x } from "./y"`) makes the symbol public in the
 * entry file that performs it; the declaration in its own file is kept with
 * `entry: false`. Completeness matches an export by name (not by source), so a
 * symbol is covered whether it is read from its declaration or its re-export.
 * `export * from "./y"` makes every symbol of `./y` public through the entry
 * file; each is recorded as an alias entry so the public surface is complete.
 */
export function buildExportInventory(upstreamRoot) {
	const packages = [];
	for (const area of listPackageAreas(upstreamRoot)) {
		const { packageJson, entryFiles } = packageEntryFiles(upstreamRoot, area);
		const entrySet = new Set(entryFiles);
		const sourceFiles = listFilesRecursive(upstreamRoot, `${areaDirectory(area)}/src`).filter((p) =>
			/\.(ts|tsx|mts|js|mjs)$/.test(p) && !/\.d\.(ts|mts)$/.test(p),
		);
		const exports = [];
		for (const file of sourceFiles) {
			const source = readFileSync(join(upstreamRoot, file), "utf8");
			for (const declaration of scanExports(source)) {
				if (declaration.kind === "star" && declaration.from) {
					// Follow the star to the target file and record its exports
					// as aliases public through this entry file.
					const resolved = resolveRelative(join(upstreamRoot, file), declaration.from);
					if (!resolved) continue;
					const rel = relative(upstreamRoot, resolved).split(sep).join("/");
					const target = readFileSync(resolved, "utf8");
					for (const targetExport of scanExports(target)) {
						if (targetExport.kind === "star") continue;
						exports.push({
							name: targetExport.name,
							kind: targetExport.kind,
							type_only: targetExport.typeOnly,
							source: rel,
							entry: true,
						});
					}
					continue;
				}
				const isAlias = declaration.kind === "alias" && declaration.from;
				// A declaration is `entry` when its file is a declared entry
				// point; a named re-export is `entry` only in the entry file that
				// performs it.
				const entry = isAlias ? entrySet.has(file) : entrySet.has(file);
				exports.push({
					name: declaration.name,
					kind: declaration.kind,
					type_only: declaration.typeOnly,
					source: file,
					entry,
				});
			}
		}
		exports.sort((a, b) => (a.source === b.source ? a.name.localeCompare(b.name) : a.source.localeCompare(b.source)));
		packages.push({
			area,
			npm_name: packageJson.name ?? null,
			version: packageJson.version ?? null,
			entrypoints: entryFiles,
			exports,
		});
	}
	return packages.sort((a, b) => a.area.localeCompare(b.area));
}

/** Enumerate the upstream `apps/*` directories (FR-028). */
export function listApps(upstreamRoot) {
	const appsDir = join(upstreamRoot, "apps");
	if (!existsSync(appsDir)) return [];
	return readdirSync(appsDir, { withFileTypes: true })
		.filter((entry) => entry.isDirectory())
		.map((entry) => `apps/${entry.name}`)
		.sort();
}

/** Is this upstream file a test, spec, or example asset? */
export function assetKindForPath(path) {
	if (/(^|\/)test\//.test(path) || /\.(test|spec)\.(ts|tsx|mts|js|mjs)$/.test(path)) return "test";
	if (/(^|\/)spec\//.test(path) || /\.spec\.md$/.test(path)) return "spec";
	if (/(^|\/)examples?\//.test(path) || /(^|\/)example\//.test(path)) return "example";
	return null;
}

/**
 * Build the source + asset inventories for completeness checking (FR-010b,
 * FR-010c). `sources` is every non-generated source file under each package's
 * `src/`; `assets` is every upstream test/spec/example reference.
 */
export function buildSourceInventory(upstreamRoot) {
	const sources = [];
	for (const area of listPackageAreas(upstreamRoot)) {
		for (const file of listFilesRecursive(upstreamRoot, `${areaDirectory(area)}/src`)) {
			if (!/\.(ts|tsx|mts|js|mjs)$/.test(file) || /\.d\.(ts|mts)$/.test(file)) continue;
			if (file.endsWith(".generated.ts")) continue;
			const source = readFileSync(join(upstreamRoot, file), "utf8");
			const exported = scanExports(source).length > 0;
			sources.push({ area, path: file, exported });
		}
	}
	sources.sort((a, b) => (a.area === b.area ? a.path.localeCompare(b.path) : a.area.localeCompare(b.area)));

	const assets = [];
	for (const area of listPackageAreas(upstreamRoot)) {
		const base = areaDirectory(area);
		const candidates = [
			...listFilesRecursive(upstreamRoot, `${base}/test`),
			...listFilesRecursive(upstreamRoot, `${base}/tests`),
			...listFilesRecursive(upstreamRoot, `${base}/spec`),
			...listFilesRecursive(upstreamRoot, `${base}/specs`),
			...listFilesRecursive(upstreamRoot, `${base}/examples`),
			...listFilesRecursive(upstreamRoot, `${base}/example`),
		];
		for (const file of candidates) {
			const kind = assetKindForPath(file);
			if (kind) assets.push({ area, kind, path: file });
		}
	}
	assets.sort((a, b) => (a.area === b.area ? a.path.localeCompare(b.path) : a.area.localeCompare(b.area)));
	return { sources, assets };
}

/** Read a JSON file from the tree, or `undefined` when absent. */
export function readJsonIfExists(path) {
	if (!existsSync(path)) return undefined;
	return JSON.parse(readFileSync(path, "utf8"));
}

/** Read a text file, or `undefined` when absent. */
export function readTextIfExists(path) {
	if (!existsSync(path)) return undefined;
	return readFileSync(path, "utf8");
}

/** Does `path` point at a regular file? */
export function isFile(path) {
	return existsSync(path) && statSync(path).isFile();
}