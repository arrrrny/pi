/**
 * Behavior-registry schema, validation, and completeness helpers.
 *
 * The registry is the human-reviewed input that declares which behaviors exist.
 * It is deliberately distinct from the generated manifest: the generator never
 * synthesizes a behavior from a filename and never infers a row's status from a
 * missing Dart path (FR-010a, FR-004). This module only validates the registry
 * against its contract and joins it to the generated inventories for the
 * completeness check.
 */

import { AREA_ORDER, STATUSES, isKnownArea } from "./upstream-tree.mjs";

/**
 * Compute the stable row id from the row's identity tuple
 * `(area, upstream_path, export, behavior_kind)`, slugified. It is stable
 * across SHA advances, so the export diff and the release gate can reason about
 * the same row before and after an upstream sync (data-model.md, row identity).
 *
 * The export token preserves case: TypeScript export names are case-sensitive
 * identifiers, and a package may export both `Decoder` (a type) and `decoder`
 * (a value) from one file. Case-folding the export slug would collapse them onto
 * one id and silently drop a row, so the export keeps its case while the
 * path and behavior_kind slugs (canonically lowercase) stay folded.
 */
export function rowId(row) {
	const exportPart = row.export === null || row.export === undefined ? "internal" : row.export;
	const slug = (value) =>
		String(value)
			.replace(/[^A-Za-z0-9._-]+/g, "-")
			.replace(/^-+|-+$/g, "");
	return [row.area, slug(row.upstream_path).toLowerCase(), slug(exportPart), slug(row.behavior_kind).toLowerCase()].join(".");
}

/** Validate one behavior row against the registry contract. Returns error strings. */
export function validateBehaviorRow(row, index) {
	const errors = [];
	const at = `behaviors[${index}]`;
	if (!row || typeof row !== "object") return [`${at}: must be an object`];
	if (typeof row.id !== "string" || row.id.length === 0) errors.push(`${at}: missing id`);
	if (!isKnownArea(row.area)) errors.push(`${at}: unknown area ${JSON.stringify(row.area)}`);
	if (typeof row.upstream_path !== "string" || row.upstream_path.length === 0) {
		errors.push(`${at}: missing upstream_path`);
	} else if (!/^packages\/[^/]+\//.test(row.upstream_path)) {
		errors.push(`${at}: upstream_path must be under packages/<area>/ (${row.upstream_path})`);
	}
	if (row.internal === true) {
		if (row.export !== null && row.export !== undefined) {
			errors.push(`${at}: internal row must have export: null`);
		}
		if (typeof row.upstream_path === "string" && !/\/src\//.test(row.upstream_path)) {
			errors.push(`${at}: internal row upstream_path must be under the area's src/`);
		}
	}
	if (typeof row.behavior_kind !== "string" || row.behavior_kind.length === 0) {
		errors.push(`${at}: missing behavior_kind`);
	}
	if (!STATUSES.includes(row.status)) {
		errors.push(`${at}: unknown status ${JSON.stringify(row.status)}`);
	}
	if (row.normative_refs === undefined || typeof row.normative_refs !== "object") {
		errors.push(`${at}: missing normative_refs`);
	}
	return errors;
}

/**
 * Validate the whole registry. Returns `{ errors, warnings }`.
 *
 * Structural errors fail generation; warnings (e.g. a stale `reviewed_base_sha`)
 * are surfaced so a stale review is visible without blocking.
 */
export function validateRegistry(registry) {
	const errors = [];
	const warnings = [];
	if (!registry || typeof registry !== "object") return { errors: ["registry: must be an object"], warnings };
	if (registry.schema_version !== 1) errors.push(`registry: unsupported schema_version ${registry.schema_version}`);
	if (typeof registry.registry_version !== "string" || registry.registry_version.length === 0) {
		errors.push("registry: missing registry_version");
	}
	if (typeof registry.reviewed_base_sha !== "string" || !/^[0-9a-f]{40}$/.test(registry.reviewed_base_sha ?? "")) {
		errors.push("registry: reviewed_base_sha must be a full 40-char sha");
	}
	if (!Array.isArray(registry.areas)) {
		errors.push("registry: areas must be an array");
	} else {
		for (const area of registry.areas) {
			if (!AREA_ORDER.includes(area)) errors.push(`registry: unknown area ${JSON.stringify(area)}`);
		}
		const missing = AREA_ORDER.filter((area) => !registry.areas.includes(area));
		if (missing.length > 0) errors.push(`registry: missing areas ${missing.join(", ")}`);
	}
	if (!Array.isArray(registry.behaviors)) {
		errors.push("registry: behaviors must be an array");
	} else {
		const seen = new Set();
		registry.behaviors.forEach((row, index) => {
			for (const error of validateBehaviorRow(row, index)) errors.push(error);
			if (row && typeof row.id === "string") {
				if (seen.has(row.id)) errors.push(`behaviors[${index}]: duplicate id ${row.id}`);
				seen.add(row.id);
				if (row.id !== rowId(row)) {
					errors.push(`behaviors[${index}]: id ${row.id} does not match its identity tuple (${rowId(row)})`);
				}
			}
		});
	}
	if (registry.unmapped_rationales !== undefined) {
		if (!Array.isArray(registry.unmapped_rationales)) {
			errors.push("registry: unmapped_rationales must be an array");
		} else {
			registry.unmapped_rationales.forEach((entry, index) => {
				const at = `unmapped_rationales[${index}]`;
				if (!["export", "source", "test", "spec", "example"].includes(entry?.kind)) {
					errors.push(`${at}: unknown kind ${JSON.stringify(entry?.kind)}`);
				}
				if (typeof entry?.coordinate !== "string" || entry.coordinate.length === 0) {
					errors.push(`${at}: missing coordinate`);
				}
				if (typeof entry?.reason !== "string" || entry.reason.length === 0) {
					errors.push(`${at}: missing reason`);
				}
				if (typeof entry?.approved_by !== "string" || entry.approved_by.length === 0) {
					errors.push(`${at}: missing approved_by`);
				}
			});
		}
	}
	return { errors, warnings };
}

/**
 * The set of `coordinate` keys a rationale entry may satisfy, so a source file,
 * an export, and a test asset can each be matched without conflating kinds.
 */
export function rationaleIndex(registry) {
	const index = new Set();
	for (const entry of registry.unmapped_rationales ?? []) {
		index.add(`${entry.kind}:${entry.coordinate}`);
	}
	return index;
}

/**
 * Check that every public export and every applicable source/test/spec/example
 * asset maps to at least one behavior row or carries a reviewed rationale
 * (FR-010b, FR-010c). Returns `{ unmapped: [{kind, coordinate}] }`.
 *
 * An export maps to a row when the row's `export` equals the export's name (the
 * same symbol may be declared in one file and re-exported from another, so the
 * source path is not part of the match). An internal source file maps to a row
 * whose `upstream_path` equals the file and whose `internal` is true. An
 * exported source file is covered through its exports and is not required to
 * carry its own row. A test/spec/example asset maps to a row whose
 * `upstream_path` equals the asset or whose `normative_refs` name it.
 */
export function checkCompleteness({ registry, exportInventory, sourceInventory, assetInventory }) {
	const unmapped = [];
	const rationales = rationaleIndex(registry);
	const isRationalized = (kind, coordinate) => rationales.has(`${kind}:${coordinate}`);

	const rowCoversExport = (pkg, exportItem) =>
		registry.behaviors.some((row) => row.area === pkg.area && row.export === exportItem.name && row.internal !== true);
	const rowCoversInternalSource = (sourceItem) =>
		registry.behaviors.some((row) => row.upstream_path === sourceItem.path && row.internal === true);
	const rowCoversAsset = (assetItem) =>
		registry.behaviors.some(
			(row) =>
				row.upstream_path === assetItem.path ||
				(row.normative_refs && Object.values(row.normative_refs).some((ref) => ref === assetItem.path)),
		);

	for (const pkg of exportInventory) {
		for (const exportItem of pkg.exports) {
			if (exportItem.entry === false) continue;
			if (!rowCoversExport(pkg, exportItem) && !isRationalized("export", `${exportItem.name}@${exportItem.source}`)) {
				unmapped.push({ kind: "export", coordinate: `${exportItem.name}@${exportItem.source}`, area: pkg.area });
			}
		}
	}
	for (const sourceItem of sourceInventory) {
		if (sourceItem.exported) continue; // exported files are covered via their exports
		if (!rowCoversInternalSource(sourceItem) && !isRationalized("source", sourceItem.path)) {
			unmapped.push({ kind: "source", coordinate: sourceItem.path, area: sourceItem.area });
		}
	}
	for (const assetItem of assetInventory) {
		if (!rowCoversAsset(assetItem) && !isRationalized(assetItem.kind, assetItem.path)) {
			unmapped.push({ kind: assetItem.kind, coordinate: assetItem.path, area: assetItem.area });
		}
	}
	return { unmapped };
}

/** Group rows by area for the report and the per-package status table. */
export function groupRowsByArea(rows) {
	const groups = new Map();
	for (const row of rows) {
		if (!groups.has(row.area)) groups.set(row.area, []);
		groups.get(row.area).push(row);
	}
	return groups;
}