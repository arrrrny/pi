/**
 * Manifest schema, ordering, and hashing.
 *
 * The generator resolves the behavior registry against the pinned upstream
 * tree's inventories into `manifest.json`. This module owns the shape of that
 * document, the deterministic ordering rule that makes two runs byte-identical
 * (SC-002), and the stable hashing that the export diff and the release gate
 * use. Nothing here reads the upstream tree or the registry; the generator
 * composes the pieces and hands the result to `buildManifest`.
 */

import { createHash } from "node:crypto";

import { AREA_ORDER, STATUSES } from "./upstream-tree.mjs";
import { groupRowsByArea } from "./registry.mjs";

/** Bump only with a migration note in `data-model.md` (contracts §9). */
export const MANIFEST_SCHEMA_VERSION = 1;

/** The generator identity recorded in the manifest header. */
export const GENERATOR_NAME = "pi-coverage";
export const GENERATOR_VERSION = "0.1.0";

/**
 * A row is the registry's behavior joined to its generated coordinates. The
 * `id` comes from the registry; everything else is copied through unchanged
 * except `dart_test`, which is kept as-is (existence is checked by the gate).
 */
function buildRow(behavior) {
	return {
		id: behavior.id,
		area: behavior.area,
		upstream_path: behavior.upstream_path,
		export: behavior.internal ? null : (behavior.export ?? null),
		internal: behavior.internal === true,
		behavior_kind: behavior.behavior_kind,
		normative_refs: behavior.normative_refs ?? {},
		dart_entrypoint: behavior.dart_entrypoint ?? null,
		dart_impl: behavior.dart_impl ?? null,
		upstream_test: behavior.normative_refs?.test ?? null,
		dart_test: behavior.dart_test ?? null,
		platforms: behavior.platforms ?? [],
		adapter_requirements: behavior.adapter_requirements ?? [],
		status: behavior.status,
		evidence: behavior.evidence ?? null,
		divergence: behavior.divergence ?? null,
		issue: behavior.issue ?? null,
	};
}

/**
 * Sort rows by the area order pinned in the checker, then by id. Determinism
 * (SC-002) depends on this ordering being total: ids are unique by registry
 * validation, so the sort is total.
 */
function sortRows(rows) {
	return [...rows].sort((a, b) => {
		const areaDelta = AREA_ORDER.indexOf(a.area) - AREA_ORDER.indexOf(b.area);
		return areaDelta !== 0 ? areaDelta : a.id.localeCompare(b.id);
	});
}

/**
 * Build the manifest object from the generator's inputs.
 *
 * @param {object} inputs
 * @param {string} inputs.sha full 40-char upstream sha
 * @param {object} inputs.registry the validated behavior registry
 * @param {object[]} inputs.exportInventory per-package export inventories
 * @param {object} inputs.sourceInventory { sources, assets }
 * @param {object[]} inputs.appDecisions apps/* decisions
 * @param {string} inputs.typescriptVersion the scanner version string
 */
export function buildManifest({ sha, registry, exportInventory, sourceInventory, appDecisions, typescriptVersion }) {
	const packagesByName = new Map(exportInventory.map((pkg) => [pkg.area, pkg]));
	const rows = sortRows(registry.behaviors.map(buildRow));
	const areaCounts = new Map();
	for (const row of rows) {
		if (!areaCounts.has(row.area)) areaCounts.set(row.area, 0);
		areaCounts.set(row.area, areaCounts.get(row.area) + 1);
	}
	const packages = exportInventory
		.map((pkg) => ({
			area: pkg.area,
			npm_name: pkg.npm_name,
			version: pkg.version,
			entrypoints: pkg.entrypoints,
			export_count: pkg.exports.length,
			behavior_count: areaCounts.get(pkg.area) ?? 0,
		}))
		.sort((a, b) => AREA_ORDER.indexOf(a.area) - AREA_ORDER.indexOf(b.area));

	const packageVersions = {};
	for (const pkg of packages) {
		if (pkg.npm_name) packageVersions[pkg.npm_name] = pkg.version;
	}

	const appDecisionRows = [...appDecisions].sort((a, b) => a.path.localeCompare(b.path));

	const manifest = {
		schema_version: MANIFEST_SCHEMA_VERSION,
		generator: {
			name: GENERATOR_NAME,
			version: GENERATOR_VERSION,
			typescript: typescriptVersion,
			registry_version: registry.registry_version,
		},
		upstream: {
			repo: "earendil-works/pi",
			sha,
			packages: packageVersions,
		},
		packages,
		app_decisions: appDecisionRows,
		rows,
	};
	return manifest;
}

/**
 * Stable content hash of the manifest body (everything except the header's
 * `typescript` string, which may change with the scanner version). Two runs on
 * the same checkout and the same registry must produce the same hash (SC-002).
 */
export function manifestHash(manifest) {
	const body = {
		schema_version: manifest.schema_version,
		generator: { name: manifest.generator.name, version: manifest.generator.version, registry_version: manifest.generator.registry_version },
		upstream: manifest.upstream,
		packages: manifest.packages,
		app_decisions: manifest.app_decisions,
		rows: manifest.rows,
	};
	const canonical = canonicalJson(body);
	return createHash("sha256").update(canonical).digest("hex");
}

/**
 * Canonical JSON: sorted object keys, compact separators, array order preserved.
 * This is the byte-stable serialization every generated artifact uses.
 */
export function canonicalJson(value) {
	if (value === null || typeof value !== "object") return JSON.stringify(value);
	if (Array.isArray(value)) return `[${value.map(canonicalJson).join(",")}]`;
	const keys = Object.keys(value).sort();
	return `{${keys.map((key) => `${JSON.stringify(key)}:${canonicalJson(value[key])}`).join(",")}}`;
}

/**
 * Deterministic file writer: serializes with `canonicalJson` plus a trailing
 * newline, so re-running the generator on unchanged inputs is a byte-identical
 * no-op (SC-002).
 */
export function serializeManifest(manifest) {
	return `${canonicalJson(manifest)}\n`;
}

/**
 * Summarize status counts across the manifest's rows. Used by the report and by
 * the release gate to print totals without re-deriving them.
 */
export function statusCounts(manifest) {
	const counts = Object.fromEntries(STATUSES.map((status) => [status, 0]));
	for (const row of manifest.rows) counts[row.status] = (counts[row.status] ?? 0) + 1;
	return counts;
}

/** Group the manifest's rows by area for the per-package status table. */
export function manifestRowsByArea(manifest) {
	return groupRowsByArea(manifest.rows);
}

/** Does this package's entry inventory exist? Used by the export diff. */
export function packageExportCount(manifest, area) {
	const pkg = manifest.packages.find((entry) => entry.area === area);
	return pkg?.export_count ?? 0;
}