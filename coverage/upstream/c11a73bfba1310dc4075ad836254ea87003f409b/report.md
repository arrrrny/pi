# Upstream coverage report

- Upstream: `earendil-works/pi` at `c11a73bfba1310dc4075ad836254ea87003f409b`
- Generator: `pi-coverage` v0.1.0 (node 20.19.2)
- Registry version: `eac23310c3f9`
- Rows: 2970 total — 243 verified, 24 implemented_unverified, 0 in_progress, 2700 unported, 3 not_applicable

## Per-package status

| Area | Package | Version | Exports | Behaviors | Verified | Unverified | Not applicable |
| --- | --- | --- | --- | --- | --- | --- | --- |
| schema | `@earendil-works/pi-schema` | 1.6.0 | 195 | 224 | 49 | 175 | 0 |
| telemetry | `@earendil-works/pi-telemetry` | 1.6.0 | 72 | 55 | 55 | 0 | 0 |
| chord | `@earendil-works/chord` | 1.6.0 | 1959 | 928 | 13 | 915 | 0 |
| ai | `@earendil-works/pi-ai` | 1.6.0 | 1171 | 509 | 31 | 478 | 0 |
| agent | `@earendil-works/pi-agent-core` | 1.6.0 | 91 | 54 | 25 | 29 | 0 |
| durable | `@earendil-works/pi-durable` | 1.6.0 | 738 | 306 | 36 | 267 | 3 |
| codemode | `@earendil-works/pi-codemode` | 1.6.0 | 93 | 40 | 7 | 33 | 0 |
| env | `@earendil-works/pi-env` | 1.6.0 | 50 | 19 | 0 | 19 | 0 |
| mcp | `@earendil-works/pi-mcp` | 1.6.0 | 195 | 35 | 12 | 23 | 0 |
| coding-agent | `@earendil-works/pi-coding-agent` | 1.6.0 | 1545 | 705 | 15 | 690 | 0 |
| tui | `@earendil-works/pi-tui` | 1.6.0 | 311 | 88 | 0 | 88 | 0 |
| evals | `@earendil-works/pi-evals` | 1.6.0 | 42 | 7 | 0 | 7 | 0 |

## Apps

| Path | Decision | Reason | Approved by |
| --- | --- | --- | --- |
| `apps/p2` | not_applicable | Product application (a web app with its own deploy pipeline); it exercises the packages but exposes no Dart library surface to port. | arrrrny |
| `apps/p2-mac` | not_applicable | Native macOS shell for p2; platform-specific UI with no Dart library surface to port. | arrrrny |
| `apps/p3` | not_applicable | Pi Roam product application; no Dart library surface to port. | arrrrny |

## Not verified

### `schema.packages-schema-src-formats-typebox-idna-hostname.ts.IsHostname.api`

- Area: `schema`, kind: `api`
- Upstream: `packages/schema/src/formats/typebox/idna/hostname.ts` → `IsHostname`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-src-formats-typebox-idna-idn-hostname.ts.IsIdnHostname.api`

- Area: `schema`, kind: `api`
- Upstream: `packages/schema/src/formats/typebox/idna/idn-hostname.ts` → `IsIdnHostname`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-bench-all.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/bench/all.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-bench-candidates.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/bench/candidates.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-bench-cases.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/bench/cases.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-bench-conformance.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/bench/conformance.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-bench-corpus.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/bench/corpus.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-bench-memory.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/bench/memory.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-bench-setup.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/bench/setup.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-bench-size.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/bench/size.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-bench-speed.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/bench/speed.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-bench-zod.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/bench/zod.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-builders.test.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/builders.test.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-coerce-typebox.test.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/coerce-typebox.test.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-coerce.test.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/coerce.test.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-conformance.test.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/conformance.test.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-equal.test.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/equal.test.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-license.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/LICENSE`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-readme.md.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/README.md`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-baseurichange-folderinteger.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/baseUriChange/folderInteger.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-baseurichangefolder-folderinteger.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/baseUriChangeFolder/folderInteger.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-baseurichangefolderinsubschema-folderinteger.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/baseUriChangeFolderInSubschema/folderInteger.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2019-09-dependentrequired.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2019-09/dependentRequired.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2019-09-ignore-prefixitems.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2019-09/ignore-prefixItems.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-baseurichange-folderinteger.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/baseUriChange/folderInteger.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-baseurichangefolder-folderinteger.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/baseUriChangeFolder/folderInteger.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-baseurichangefolderinsubschema-folderinteger.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/baseUriChangeFolderInSubschema/folderInteger.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-detached-dynamicref.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/detached-dynamicref.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-detached-ref.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/detached-ref.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-different-id-ref-string.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/different-id-ref-string.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-extendible-dynamic-ref.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/extendible-dynamic-ref.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-format-assertion-false.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/format-assertion-false.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-format-assertion-true.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/format-assertion-true.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-integer.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/integer.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-locationindependentidentifier.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/locationIndependentIdentifier.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-metaschema-no-validation.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/metaschema-no-validation.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-metaschema-optional-vocabulary.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/metaschema-optional-vocabulary.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-name-defs.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/name-defs.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-nested-absolute-ref-to-string.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/nested-absolute-ref-to-string.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-nested-foo-ref-string.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/nested/foo-ref-string.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-nested-string.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/nested/string.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-prefixitems.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/prefixItems.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-ref-and-defs.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/ref-and-defs.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-subschemas.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/subSchemas.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-tree.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/tree.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft2020-12-urn-ref-string.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft2020-12/urn-ref-string.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft7-detached-ref.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft7/detached-ref.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft7-ignore-dependentrequired.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft7/ignore-dependentRequired.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft7-locationindependentidentifier.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft7/locationIndependentIdentifier.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft7-name.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft7/name.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft7-ref-and-definitions.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft7/ref-and-definitions.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-draft7-subschemas.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/draft7/subSchemas.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-integer.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/integer.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-nested-foo-ref-string.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/nested/foo-ref-string.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-remotes-nested-string.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/remotes/nested/string.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-additionalproperties.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/additionalProperties.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-allof.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/allOf.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-anchor.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/anchor.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-anyof.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/anyOf.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-boolean_schema.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/boolean_schema.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-const.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/const.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-contains.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/contains.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-content.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/content.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-default.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/default.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-defs.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/defs.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-dependentrequired.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/dependentRequired.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-dependentschemas.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/dependentSchemas.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-dynamicref.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/dynamicRef.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-enum.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/enum.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-exclusivemaximum.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/exclusiveMaximum.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-exclusiveminimum.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/exclusiveMinimum.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-format.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/format.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-if-then-else.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/if-then-else.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-infinite-loop-detection.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/infinite-loop-detection.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-items.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/items.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-maxcontains.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/maxContains.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-maximum.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/maximum.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-maxitems.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/maxItems.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-maxlength.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/maxLength.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-maxproperties.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/maxProperties.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-mincontains.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/minContains.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-minimum.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/minimum.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-minitems.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/minItems.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-minlength.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/minLength.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-minproperties.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/minProperties.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-multipleof.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/multipleOf.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-not.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/not.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-oneof.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/oneOf.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-anchor.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/anchor.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-bignum.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/bignum.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-cross-draft.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/cross-draft.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-dependencies-compatibility.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/dependencies-compatibility.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-dynamicref.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/dynamicRef.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-ecmascript-regex.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/ecmascript-regex.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-float-overflow.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/float-overflow.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-assertion.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format-assertion.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-date-time.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/date-time.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-date.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/date.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-duration.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/duration.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-ecmascript-regex.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/ecmascript-regex.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-email.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/email.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-hostname.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/hostname.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-idn-email.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/idn-email.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-idn-hostname.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/idn-hostname.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-ipv4.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/ipv4.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-ipv6.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/ipv6.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-iri-reference.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/iri-reference.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-iri.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/iri.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-json-pointer.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/json-pointer.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-regex.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/regex.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-relative-json-pointer.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/relative-json-pointer.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-time.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/time.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-unknown.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/unknown.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-uri-reference.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/uri-reference.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-uri-template.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/uri-template.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-uri.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/uri.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-format-uuid.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/format/uuid.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-id.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/id.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-no-schema.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/no-schema.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-non-bmp-regex.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/non-bmp-regex.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-refofunknownkeyword.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/refOfUnknownKeyword.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-optional-unknownkeyword.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/optional/unknownKeyword.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-pattern.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/pattern.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-patternproperties.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/patternProperties.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-prefixitems.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/prefixItems.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-properties.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/properties.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-propertynames.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/propertyNames.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-ref.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/ref.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-refremote.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/refRemote.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-required.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/required.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-type.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/type.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-unevaluateditems.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/unevaluatedItems.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-unevaluatedproperties.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/unevaluatedProperties.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-uniqueitems.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/uniqueItems.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft2020-12-vocabulary.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft2020-12/vocabulary.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-default.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/default.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-definitions.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/definitions.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-format.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/format.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-infinite-loop-detection.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/infinite-loop-detection.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-bignum.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/bignum.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-content.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/content.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-cross-draft.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/cross-draft.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-ecmascript-regex.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/ecmascript-regex.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-float-overflow.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/float-overflow.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-format-ecmascript-regex.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/format/ecmascript-regex.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-format-hostname.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/format/hostname.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-format-idn-email.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/format/idn-email.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-format-idn-hostname.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/format/idn-hostname.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-format-ipv6.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/format/ipv6.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-format-iri-reference.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/format/iri-reference.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-format-iri.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/format/iri.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-format-relative-json-pointer.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/format/relative-json-pointer.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-format-unknown.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/format/unknown.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-format-uri-reference.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/format/uri-reference.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-format-uri-template.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/format/uri-template.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-format-uri.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/format/uri.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-id.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/id.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-non-bmp-regex.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/non-bmp-regex.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-optional-unknownkeyword.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/optional/unknownKeyword.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-ref.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/ref.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-json-schema-test-suite-tests-draft7-refremote.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/json-schema-test-suite/tests/draft7/refRemote.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-meta-schemas-draft-07-schema.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/meta-schemas/draft-07-schema.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-meta-schemas-draft2020-12-meta-applicator.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/meta-schemas/draft2020-12-meta-applicator.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-meta-schemas-draft2020-12-meta-content.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/meta-schemas/draft2020-12-meta-content.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-meta-schemas-draft2020-12-meta-core.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/meta-schemas/draft2020-12-meta-core.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-meta-schemas-draft2020-12-meta-format-annotation.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/meta-schemas/draft2020-12-meta-format-annotation.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-meta-schemas-draft2020-12-meta-meta-data.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/meta-schemas/draft2020-12-meta-meta-data.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-meta-schemas-draft2020-12-meta-unevaluated.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/meta-schemas/draft2020-12-meta-unevaluated.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-meta-schemas-draft2020-12-meta-validation.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/meta-schemas/draft2020-12-meta-validation.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-meta-schemas-draft2020-12-schema.json.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/meta-schemas/draft2020-12-schema.json`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-fixtures-meta-schemas-readme.md.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/fixtures/meta-schemas/README.md`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-shared.test.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/shared.test.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-suite.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/suite.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-typebox-static.test.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/typebox-static.test.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `schema.packages-schema-test-validator.test.ts.internal.test`

- Area: `schema`, kind: `test`
- Upstream: `packages/schema/test/validator.test.ts`
- Dart: _(none)_
- Divergence: Ported in a later slice (draft2020-12 keywords, IDNA/URI/IRI formats, compiler/explain/builders, remote $ref); tracked in pi#53.
- Issue: `#arrrrny/pi#81`

### `chord.packages-chord-src-context-index.ts.awaitWithContext.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/context/index.ts` → `awaitWithContext`
- Dart: `pi_agent/lib/src/chord/context.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#87`

### `chord.packages-chord-src-context-index.ts.BACKGROUND_CONTEXT.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/context/index.ts` → `BACKGROUND_CONTEXT`
- Dart: `pi_agent/lib/src/chord/context.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#87`

### `chord.packages-chord-src-context-index.ts.Context.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/context/index.ts` → `Context`
- Dart: `pi_agent/lib/src/chord/context.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#87`

### `chord.packages-chord-src-context-index.ts.ContextKey.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/context/index.ts` → `ContextKey`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-context-index.ts.createContextKey.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/context/index.ts` → `createContextKey`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-context-index.ts.TODO_CONTEXT.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/context/index.ts` → `TODO_CONTEXT`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-context-index.ts.traceIn.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/context/index.ts` → `traceIn`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-context-index.ts.withAbortSignal.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/context/index.ts` → `withAbortSignal`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-context-index.ts.withCancel.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/context/index.ts` → `withCancel`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-context-index.ts.withContextValue.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/context/index.ts` → `withContextValue`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-context-index.ts.withoutAbortSignal.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/context/index.ts` → `withoutAbortSignal`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-context-index.ts.withTelemetry.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/context/index.ts` → `withTelemetry`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-contracts-index.ts.AcceptsTable.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/contracts/index.ts` → `AcceptsTable`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-contracts-index.ts.evolve.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/contracts/index.ts` → `evolve`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-contracts-index.ts.hostKind.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/contracts/index.ts` → `hostKind`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-contracts-index.ts.local.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/contracts/index.ts` → `local`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-contracts-index.ts.memberNames.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/contracts/index.ts` → `memberNames`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-contracts-index.ts.remote.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/contracts/index.ts` → `remote`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-data-index.ts.broken.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/data/index.ts` → `broken`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-data-index.ts.Principal.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/data/index.ts` → `Principal`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-data-index.ts.PrincipalKeyFunction.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/data/index.ts` → `PrincipalKeyFunction`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.appendText.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `appendText`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.assertSafePath.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `assertSafePath`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.assertValidOp.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `assertValidOp`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.assertValidWireOp.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `assertValidWireOp`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.decoder.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `decoder`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.Decoder.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `Decoder`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.diffRevisions.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `diffRevisions`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.encoder.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `encoder`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.Encoder.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `Encoder`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.isBase.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `isBase`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.JsonValue.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `JsonValue`
- Dart: `pi_agent/lib/src/chord/delta.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#87`

### `chord.packages-chord-src-delta-index.ts.overlap.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `overlap`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.ownedSlice.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `ownedSlice`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.PathRef.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `PathRef`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.PendingOps.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `PendingOps`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.track.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `track`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.UnsafePathError.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `UnsafePathError`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-delta-index.ts.WireOp.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/delta/index.ts` → `WireOp`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-documents-index.ts.HandleOf.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/documents/index.ts` → `HandleOf`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-documents-index.ts.KeyedHandle.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/documents/index.ts` → `KeyedHandle`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-documents-index.ts.SingletonHandle.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/documents/index.ts` → `SingletonHandle`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-documents-index.ts.Tx.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/documents/index.ts` → `Tx`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.ActivityCounts.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `ActivityCounts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.allow.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `allow`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.Ctx.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `Ctx`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.defineFacet.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `defineFacet`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.deny.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `deny`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.FollowAttach.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `FollowAttach`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.FollowAttachment.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `FollowAttachment`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.FollowObserver.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `FollowObserver`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.Held.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `Held`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.ListOptions.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `ListOptions`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.Native.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `Native`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.NativeCloseReason.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `NativeCloseReason`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.NativeOptions.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `NativeOptions`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.OnHandler.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `OnHandler`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.OnLiveHandler.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `OnLiveHandler`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.OnNativeHandler.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `OnNativeHandler`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.PartnerRow.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `PartnerRow`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.PluginFacet.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `PluginFacet`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.Presence.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `Presence`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.QueriesOptions.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `QueriesOptions`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.Reference.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `Reference`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.RefIn.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `RefIn`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.RefState.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `RefState`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.RevokedBy.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `RevokedBy`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.RootOptions.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `RootOptions`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.RouteHandle.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `RouteHandle`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.RouteOptions.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `RouteOptions`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.RoutineDeclarations.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `RoutineDeclarations`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.sleep.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `sleep`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-host-index.ts.untilAborted.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/host/index.ts` → `untilAborted`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-index.ts.applyBatch.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/index.ts` → `applyBatch`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-index.ts.CHORD_TELEMETRY_SCHEMA.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/index.ts` → `CHORD_TELEMETRY_SCHEMA`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-index.ts.ChordStore.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/index.ts` → `ChordStore`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-index.ts.Claimant.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/index.ts` → `Claimant`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-index.ts.EncodedRow.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/index.ts` → `EncodedRow`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-index.ts.Order.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/index.ts` → `Order`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-index.ts.OwnerTable.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/index.ts` → `OwnerTable`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-index.ts.SeriesCommit.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/index.ts` → `SeriesCommit`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-index.ts.SeriesResult.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/index.ts` → `SeriesResult`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-index.ts.StagedWrite.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/index.ts` → `StagedWrite`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-index.ts.Step.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/index.ts` → `Step`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-index.ts.StoreOwnerTables.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/index.ts` → `StoreOwnerTables`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-jobs-index.ts.BlockedReason.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/jobs/index.ts` → `BlockedReason`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-jobs-index.ts.JobCtx.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/jobs/index.ts` → `JobCtx`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-jobs-index.ts.JobHandle.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/jobs/index.ts` → `JobHandle`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-jobs-index.ts.JobImplementation.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/jobs/index.ts` → `JobImplementation`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-jobs-index.ts.Run.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/jobs/index.ts` → `Run`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-jobs-index.ts.RunningEntry.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/jobs/index.ts` → `RunningEntry`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-jobs-index.ts.RunState.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/jobs/index.ts` → `RunState`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-jobs-index.ts.StartOptions.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/jobs/index.ts` → `StartOptions`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-json.ts.CopyJsonOptions.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/json.ts` → `CopyJsonOptions`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-json.ts.JsonRepresentation.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/json.ts` → `JsonRepresentation`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-link-index.ts.binaryCodec.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/link/index.ts` → `binaryCodec`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-link-index.ts.Codec.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/link/index.ts` → `Codec`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-link-index.ts.Compression.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/link/index.ts` → `Compression`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-link-index.ts.describeMessage.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/link/index.ts` → `describeMessage`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-link-index.ts.Inflated.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/link/index.ts` → `Inflated`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-link-index.ts.ipcLink.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/link/index.ts` → `ipcLink`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-link-index.ts.memoryLinkPair.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/link/index.ts` → `memoryLinkPair`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-link-index.ts.Message.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/link/index.ts` → `Message`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-link-index.ts.PartLimits.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/link/index.ts` → `PartLimits`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-link-index.ts.textCodec.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/link/index.ts` → `textCodec`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-link-index.ts.webSocketLink.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/link/index.ts` → `webSocketLink`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-app-files-entry.ts.copyFiles.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/app/files-entry.ts` → `copyFiles`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-app-files-entry.ts.privateDirectory.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/app/files-entry.ts` → `privateDirectory`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-app-files-entry.ts.privateStore.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/app/files-entry.ts` → `privateStore`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-app-index.ts.AppInfo.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/app/index.ts` → `AppInfo`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-app-index.ts.appInfoFacet.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/app/index.ts` → `appInfoFacet`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-app-index.ts.ARCHIVE_FORMAT.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/app/index.ts` → `ARCHIVE_FORMAT`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-app-index.ts.defineUsers.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/app/index.ts` → `defineUsers`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-app-index.ts.ephemeralLoginFacet.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/app/index.ts` → `ephemeralLoginFacet`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-app-index.ts.inviteFacet.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/app/index.ts` → `inviteFacet`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-app-index.ts.SIGN_IN_COOKIE.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/app/index.ts` → `SIGN_IN_COOKIE`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-app-index.ts.SignIns.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/app/index.ts` → `SignIns`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-app-index.ts.startWorker.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/app/index.ts` → `startWorker`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-app-index.ts.WorkerInfo.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/app/index.ts` → `WorkerInfo`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-app-index.ts.workerInfoFacet.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/app/index.ts` → `workerInfoFacet`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-compression.ts.nodeCompression.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/compression.ts` → `nodeCompression`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-http-index.ts.Authenticators.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/http/index.ts` → `Authenticators`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-http-index.ts.Connection.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/http/index.ts` → `Connection`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-http-index.ts.cookie.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/http/index.ts` → `cookie`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-http-index.ts.fileResponse.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/http/index.ts` → `fileResponse`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-http-index.ts.HttpFailure.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/http/index.ts` → `HttpFailure`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-http-index.ts.HttpResponse.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/http/index.ts` → `HttpResponse`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-http-index.ts.LinkOptions.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/http/index.ts` → `LinkOptions`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-http-index.ts.nodeRequest.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/http/index.ts` → `nodeRequest`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-http-index.ts.Provenance.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/http/index.ts` → `Provenance`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-http-index.ts.readCookie.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/http/index.ts` → `readCookie`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-http-index.ts.readSignedCookie.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/http/index.ts` → `readSignedCookie`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-plugins-index.ts.BaseInputs.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/plugins/index.ts` → `BaseInputs`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-plugins-index.ts.buildFacet.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/plugins/index.ts` → `buildFacet`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-plugins-index.ts.evaluateFacet.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/plugins/index.ts` → `evaluateFacet`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-plugins-index.ts.mapStack.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/plugins/index.ts` → `mapStack`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-plugins-index.ts.pluginFile.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/plugins/index.ts` → `pluginFile`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-plugins-index.ts.PluginsState.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/plugins/index.ts` → `PluginsState`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-plugins-index.ts.testPlugin.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/plugins/index.ts` → `testPlugin`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-plugins-runtime.ts.createPluginRuntime.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/plugins/runtime.ts` → `createPluginRuntime`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-plugins-runtime.ts.PluginError.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/plugins/runtime.ts` → `PluginError`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-plugins-runtime.ts.PluginRuntime.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/plugins/runtime.ts` → `PluginRuntime`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-plugins-runtime.ts.PluginScript.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/plugins/runtime.ts` → `PluginScript`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-plugins-runtime.ts.RuntimeLoad.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/plugins/runtime.ts` → `RuntimeLoad`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-surfaces-index.ts.buildBase.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/surfaces/index.ts` → `buildBase`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-surfaces-index.ts.processConditions.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/surfaces/index.ts` → `processConditions`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-surfaces-index.ts.ServedFile.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/surfaces/index.ts` → `ServedFile`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-surfaces-index.ts.SurfaceBuilt.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/surfaces/index.ts` → `SurfaceBuilt`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-surfaces-index.ts.TUI_PREFIX.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/surfaces/index.ts` → `TUI_PREFIX`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-surfaces-index.ts.tuiSurface.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/surfaces/index.ts` → `tuiSurface`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-tui-index.ts.filterOutput.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/tui/index.ts` → `filterOutput`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-tui-index.ts.PromptTerminal.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/tui/index.ts` → `PromptTerminal`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-tui-index.ts.requireSandboxNode.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/tui/index.ts` → `requireSandboxNode`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-tui-index.ts.startTerminal.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/tui/index.ts` → `startTerminal`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-tui-index.ts.TerminalCredentials.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/tui/index.ts` → `TerminalCredentials`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-tui-index.ts.terminalFile.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/tui/index.ts` → `terminalFile`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-workers-child.ts.CrossedError.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/workers/child.ts` → `CrossedError`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-workers-child.ts.processLock.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/workers/child.ts` → `processLock`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-node-workers-index.ts.nodeBaseInputs.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/node/workers/index.ts` → `nodeBaseInputs`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-output.ts.BoundedOutput.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/output.ts` → `BoundedOutput`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-output.ts.boundOutput.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/output.ts` → `boundOutput`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-output.ts.characterEnd.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/output.ts` → `characterEnd`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-output.ts.OutputBuffer.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/output.ts` → `OutputBuffer`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-output.ts.OutputLimits.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/output.ts` → `OutputLimits`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-output.ts.OutputSkip.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/output.ts` → `OutputSkip`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-output.ts.OutputSlice.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/output.ts` → `OutputSlice`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-output.ts.PROGRESS_BYTES_PER_SECOND.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/output.ts` → `PROGRESS_BYTES_PER_SECOND`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-output.ts.Progress.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/output.ts` → `Progress`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-output.ts.ProgressClock.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/output.ts` → `ProgressClock`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-output.ts.sanitizeOutput.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/output.ts` → `sanitizeOutput`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-output.ts.utf8ByteLength.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/output.ts` → `utf8ByteLength`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-react-index.ts.InVariant.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/react/index.ts` → `InVariant`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-react-index.ts.VariantOf.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/react/index.ts` → `VariantOf`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-react-index.ts.VariantRef.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/react/index.ts` → `VariantRef`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-react-index.ts.watchStore.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/react/index.ts` → `watchStore`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-registries-index.ts.keyedEntries.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/registries/index.ts` → `keyedEntries`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-registries-index.ts.orderedEntries.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/registries/index.ts` → `orderedEntries`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sqlite-cloudflare.ts.DurableObjectSqliteDatabase.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sqlite/cloudflare.ts` → `DurableObjectSqliteDatabase`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sqlite-cloudflare.ts.DurableObjectSqliteStorage.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sqlite/cloudflare.ts` → `DurableObjectSqliteStorage`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sqlite-index.ts.applySqliteMigrations.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sqlite/index.ts` → `applySqliteMigrations`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sqlite-index.ts.SqliteDatabase.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sqlite/index.ts` → `SqliteDatabase`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sqlite-index.ts.SqliteExecutor.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sqlite/index.ts` → `SqliteExecutor`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sqlite-index.ts.SqliteValue.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sqlite/index.ts` → `SqliteValue`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sqlite-index.ts.validateSqliteSchemaPrefix.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sqlite/index.ts` → `validateSqliteSchemaPrefix`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sqlite-node.ts.NodeSqliteDatabase.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sqlite/node.ts` → `NodeSqliteDatabase`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sqlite-node.ts.NodeSqliteDatabaseOptions.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sqlite/node.ts` → `NodeSqliteDatabaseOptions`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sqlite-node.ts.NodeSqliteMode.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sqlite/node.ts` → `NodeSqliteMode`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sqlite-node.ts.openNodeSqliteDatabase.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sqlite/node.ts` → `openNodeSqliteDatabase`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-state-index.ts.constant.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/state/index.ts` → `constant`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-state-index.ts.mapShared.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/state/index.ts` → `mapShared`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-state-index.ts.NativeObservation.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/state/index.ts` → `NativeObservation`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-state-index.ts.NativeObserver.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/state/index.ts` → `NativeObserver`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-state-index.ts.Watchable.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/state/index.ts` → `Watchable`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-state-index.ts.Writable.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/state/index.ts` → `Writable`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.ArchiveManifest.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `ArchiveManifest`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.ArchivePart.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `ArchivePart`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.Columns.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `Columns`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.compareText.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `compareText`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.decodeJsonl.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `decodeJsonl`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.defineColumns.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `defineColumns`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.defineTable.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `defineTable`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.encodeJsonl.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `encodeJsonl`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.host.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `host`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.importStore.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `importStore`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.json.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.openStore.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `openStore`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.Outbox.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `Outbox`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.OutboxCommit.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `OutboxCommit`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.Page.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `Page`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.PageOptions.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `PageOptions`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.PutRowOf.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `PutRowOf`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.query.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `query`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.RowOf.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `RowOf`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.sqliteBackend.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `sqliteBackend`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.StoreWrite.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `StoreWrite`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.Table.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `Table`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-store-index.ts.TableOf.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/store/index.ts` → `TableOf`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-surfaces-index.ts.createLanguage.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/surfaces/index.ts` → `createLanguage`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-surfaces-index.ts.followActiveLanguage.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/surfaces/index.ts` → `followActiveLanguage`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-surfaces-index.ts.followActiveTheme.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/surfaces/index.ts` → `followActiveTheme`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-surfaces-index.ts.formatNumber.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/surfaces/index.ts` → `formatNumber`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-surfaces-index.ts.formatTime.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/surfaces/index.ts` → `formatTime`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-surfaces-index.ts.hostLanguage.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/surfaces/index.ts` → `hostLanguage`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-surfaces-index.ts.LoadedFacets.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/surfaces/index.ts` → `LoadedFacets`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-surfaces-index.ts.LocaleChoice.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/surfaces/index.ts` → `LocaleChoice`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-surfaces-index.ts.localeChoiceFacet.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/surfaces/index.ts` → `localeChoiceFacet`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-surfaces-index.ts.ScriptSet.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/surfaces/index.ts` → `ScriptSet`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-surfaces-index.ts.ThemeChoice.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/surfaces/index.ts` → `ThemeChoice`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-surfaces-index.ts.themeChoiceFacet.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/surfaces/index.ts` → `themeChoiceFacet`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-surfaces-index.ts.TuiScripts.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/surfaces/index.ts` → `TuiScripts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-surfaces-index.ts.WebScripts.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/surfaces/index.ts` → `WebScripts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sync-index.ts.checkSessionId.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sync/index.ts` → `checkSessionId`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sync-index.ts.decodeLogLine.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sync/index.ts` → `decodeLogLine`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sync-index.ts.encodeLogLine.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sync/index.ts` → `encodeLogLine`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sync-index.ts.FileResult.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sync/index.ts` → `FileResult`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sync-index.ts.FileSyncStateStore.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sync/index.ts` → `FileSyncStateStore`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sync-index.ts.FileSystemSyncRemote.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sync/index.ts` → `FileSystemSyncRemote`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sync-index.ts.LOG_VERSION.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sync/index.ts` → `LOG_VERSION`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sync-index.ts.LogFormatError.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sync/index.ts` → `LogFormatError`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sync-index.ts.SyncFileInfo.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sync/index.ts` → `SyncFileInfo`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sync-index.ts.SyncFileReader.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sync/index.ts` → `SyncFileReader`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-sync-index.ts.SyncFileSystem.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/sync/index.ts` → `SyncFileSystem`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-telemetry-ingest-index.ts.sendPageTelemetry.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/telemetry-ingest/index.ts` → `sendPageTelemetry`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-telemetry-ingest-index.ts.sendWorkerTelemetry.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/telemetry-ingest/index.ts` → `sendWorkerTelemetry`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-telemetry-ingest-index.ts.TelemetryRecorder.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/telemetry-ingest/index.ts` → `TelemetryRecorder`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-telemetry-sqlite-index.ts.createSqliteTelemetry.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/telemetry-sqlite/index.ts` → `createSqliteTelemetry`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-telemetry-sqlite-index.ts.SqliteTelemetry.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/telemetry-sqlite/index.ts` → `SqliteTelemetry`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-telemetry-sqlite-index.ts.SqliteTelemetryOptions.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/telemetry-sqlite/index.ts` → `SqliteTelemetryOptions`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-telemetry-sqlite-index.ts.TelemetryBatch.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/telemetry-sqlite/index.ts` → `TelemetryBatch`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-telemetry-sqlite-node.ts.openTelemetryStore.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/telemetry-sqlite/node.ts` → `openTelemetryStore`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-telemetry-sqlite-node.ts.SqliteTelemetryStore.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/telemetry-sqlite/node.ts` → `SqliteTelemetryStore`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-tui-index.ts.Bridge.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/tui/index.ts` → `Bridge`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-tui-index.ts.BridgeRequest.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/tui/index.ts` → `BridgeRequest`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-tui-index.ts.BridgeStart.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/tui/index.ts` → `BridgeStart`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-tui-index.ts.BridgeTerminal.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/tui/index.ts` → `BridgeTerminal`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-tui-index.ts.LauncherMessage.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/tui/index.ts` → `LauncherMessage`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-tui-index.ts.PageState.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/tui/index.ts` → `PageState`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-tui-index.ts.SandboxMessage.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/tui/index.ts` → `SandboxMessage`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-tui-index.ts.TerminalTheme.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/tui/index.ts` → `TerminalTheme`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-tui-index.ts.TuiScope.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/tui/index.ts` → `TuiScope`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-watch.ts.NativeWatch.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/watch.ts` → `NativeWatch`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-watch.ts.NativeWatchable.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/watch.ts` → `NativeWatchable`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-watch.ts.NativeWatchCall.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/watch.ts` → `NativeWatchCall`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-watch.ts.NativeWatchHandle.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/watch.ts` → `NativeWatchHandle`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-watch.ts.Watch.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/watch.ts` → `Watch`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-watch.ts.WatchCall.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/watch.ts` → `WatchCall`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-watch.ts.WatchEnd.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/watch.ts` → `WatchEnd`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-watch.ts.WatchHandle.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/watch.ts` → `WatchHandle`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-web-index.ts.followLanguage.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/web/index.ts` → `followLanguage`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-web-index.ts.followThemes.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/web/index.ts` → `followThemes`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-web-index.ts.pageEnvironment.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/web/index.ts` → `pageEnvironment`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-src-web-index.ts.startPage.api`

- Area: `chord`, kind: `api`
- Upstream: `packages/chord/src/web/index.ts` → `startPage`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-calls.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/calls.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-compression.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/compression.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-derives.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/derives.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-events.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/events.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-http.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/http.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-jobs.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/jobs.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-links.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/links.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-live-query.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/live-query.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-plugins.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/plugins.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-registries.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/registries.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-relay.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/relay.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-reload.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/reload.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-shared-holds.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/shared-holds.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-slice-14.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/slice-14.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-state-binding.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/state-binding.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-store.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/store.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-sync-memory.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/sync-memory.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-sync-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/sync-worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-telemetry.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/telemetry.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-bench-workers.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/bench/workers.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-boundary.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/boundary.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-context.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/context.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-contracts-accepts.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/contracts/accepts.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-contracts-contract.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/contracts/contract.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-contracts-declare.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/contracts/declare.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-contracts-evolve.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/contracts/evolve.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-contracts-fingerprint.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/contracts/fingerprint.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-contracts-history.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/contracts/history.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-contracts-host-kind.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/contracts/host-kind.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-contracts-params.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/contracts/params.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-contracts-schema.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/contracts/schema.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-contracts-snapshot.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/contracts/snapshot.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-data-args.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/data/args.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-data-errors.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/data/errors.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-data-failure.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/data/failure.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-data-params.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/data/params.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-data-principal.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/data/principal.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-data-validator.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/data/validator.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-append-text.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-append-text.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-apply-immutable.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-apply-immutable.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-benchmark-benchmark.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-benchmark/benchmark.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-benchmark-benchmark.worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-benchmark/benchmark.worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-benchmark-conversation-view-benchmark.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-benchmark/conversation-view-benchmark.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-benchmark-conversation-view-benchmark.worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-benchmark/conversation-view-benchmark.worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-benchmark-memory-benchmark.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-benchmark/memory-benchmark.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-benchmark-memory-benchmark.worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-benchmark/memory-benchmark.worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-clone.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-clone.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-diff.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-diff.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-op-text-retention.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-op-text-retention.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-pending.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-pending.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-tracker-retention.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-tracker/retention.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-tracker-retention.worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-tracker/retention.worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-tracker-tracker.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-tracker/tracker.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta-traversal.bench.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta-traversal.bench.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-delta.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/delta.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-documents-address-source.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/documents/address-source.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-documents-definition.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/documents/definition.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-documents-documents.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/documents/documents.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-documents-fence.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/documents/fence.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-documents-handles.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/documents/handles.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-documents-keyed-slot.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/documents/keyed-slot.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-documents-line.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/documents/line.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-documents-persistence.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/documents/persistence.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-documents-residency.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/documents/residency.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-documents-slot.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/documents/slot.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-documents-transaction.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/documents/transaction.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-01-objects.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/01-objects.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-02-documents.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/02-documents.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-03-derives.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/03-derives.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-04-watches.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/04-watches.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-05-errors.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/05-errors.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-06-natives.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/06-natives.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-07-failures.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/07-failures.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-08-remote.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/08-remote.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-09-calls.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/09-calls.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-10-drops.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/10-drops.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-11-linger-and-retry.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/11-linger-and-retry.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-12-routes.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/12-routes.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-13-relay.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/13-relay.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-14-flow-control.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/14-flow-control.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-15-revocation.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/15-revocation.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-16-presence-and-activity.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/16-presence-and-activity.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-17-limits-and-compression.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/17-limits-and-compression.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-18-routines.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/18-routines.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-19-jobs.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/19-jobs.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-20-tables.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/20-tables.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-21-persisted-documents.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/21-persisted-documents.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-22-migrations.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/22-migrations.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-23-keyed-watches.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/23-keyed-watches.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-24-keyed-members.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/24-keyed-members.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-25-export-import.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/25-export-import.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-28-persisted-jobs.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/28-persisted-jobs.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-29-registries.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/29-registries.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-30-host-root.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/30-host-root.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-31-parked-dependencies.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/31-parked-dependencies.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-32-startup.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/32-startup.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-33-reload.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/33-reload.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-34-versions.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/34-versions.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-35-plugins-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/35-plugins/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-35-plugins-plugins-clock-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/35-plugins/plugins/clock/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-35-plugins-plugins-clock-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/35-plugins/plugins/clock/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-35-plugins-plugins-contracts-contract.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/35-plugins/plugins/contracts/contract.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-35-plugins-plugins-contracts-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/35-plugins/plugins/contracts/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-35-plugins-plugins-notes-label.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/35-plugins/plugins/notes/label.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-35-plugins-plugins-notes-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/35-plugins/plugins/notes/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-35-plugins-plugins-notes-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/35-plugins/plugins/notes/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-35-plugins-plugins-notes-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/35-plugins/plugins/notes/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-boot-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/boot/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-boot-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/boot/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-cache-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/cache/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-cache-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/cache/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-counter-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/counter/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-counter-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/counter/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-forecast-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/forecast/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-forecast-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/forecast/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-greeter-label.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/greeter/label.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-greeter-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/greeter/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-greeter-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/greeter/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-prices-contract.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/prices/contract.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-prices-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/prices/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-prices-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/prices/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-summary-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/summary/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-summary-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/summary/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-weather-contract.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/weather/contract.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-weather-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/weather/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-36-plugin-failures-plugins-weather-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/36-plugin-failures/plugins/weather/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-app-index.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/app/index.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-app-legacy.cjs.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/app/legacy.cjs`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-deps-example-greeting-index.js.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/deps/example-greeting/index.js`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-deps-example-greeting-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/deps/example-greeting/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-deps-example-native-index.js.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/deps/example-native/index.js`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-deps-example-native-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/deps/example-native/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-fake-npm.mjs.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/fake-npm.mjs`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-plugins-paths-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/plugins/paths/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-plugins-paths-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/plugins/paths/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-plugins-refused-other.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/plugins/refused/other.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-plugins-refused-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/plugins/refused/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-plugins-refused-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/plugins/refused/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-plugins-report-data-rates.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/plugins/report/data/rates.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-plugins-report-env.d.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/plugins/report/env.d.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-plugins-report-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/plugins/report/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-plugins-report-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/plugins/report/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-plugins-ruler-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/plugins/ruler/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-plugins-ruler-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/plugins/ruler/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-plugins-shapes-contract.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/plugins/shapes/contract.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-plugins-shapes-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/plugins/shapes/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-37-plugin-imports-plugins-shapes-units.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/37-plugin-imports/plugins/shapes/units.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-app-config.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/app/config.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-incoming-extra-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/incoming/extra/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-incoming-extra-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/incoming/extra/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-plugins-contracts-contract.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/plugins/contracts/contract.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-plugins-contracts-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/plugins/contracts/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-plugins-notes-label.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/plugins/notes/label.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-plugins-notes-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/plugins/notes/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-plugins-notes-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/plugins/notes/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-plugins-notes-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/plugins/notes/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-plugins-old-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/plugins/old/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-plugins-old-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/plugins/old/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-plugins-tags-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/plugins/tags/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-plugins-tags-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/plugins/tags/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-38-watch-and-rollout-plugins-tags-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/38-watch-and-rollout/plugins/tags/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-39-browser-build-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/39-browser-build/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-39-browser-build-plugins-bad-web-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/39-browser-build/plugins/bad-web/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-39-browser-build-plugins-bad-web-web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/39-browser-build/plugins/bad-web/web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-39-browser-build-plugins-gallery-assets-logo.svg.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/39-browser-build/plugins/gallery/assets/logo.svg`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-39-browser-build-plugins-gallery-assets.d.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/39-browser-build/plugins/gallery/assets.d.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-39-browser-build-plugins-gallery-gallery.css.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/39-browser-build/plugins/gallery/gallery.css`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-39-browser-build-plugins-gallery-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/39-browser-build/plugins/gallery/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-39-browser-build-plugins-gallery-web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/39-browser-build/plugins/gallery/web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-40-http-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/40-http/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-40-http-plugins-notes-files-hello.md.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/40-http/plugins/notes/files/hello.md`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-40-http-plugins-notes-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/40-http/plugins/notes/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-40-http-plugins-notes-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/40-http/plugins/notes/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-41-workers-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/41-workers/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-41-workers-plugins-sessions-contract.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/41-workers/plugins/sessions/contract.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-41-workers-plugins-sessions-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/41-workers/plugins/sessions/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-41-workers-plugins-sessions-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/41-workers/plugins/sessions/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-41-workers-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/41-workers/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-42-worker-crash-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/42-worker-crash/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-42-worker-crash-plugins-sessions-contract.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/42-worker-crash/plugins/sessions/contract.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-42-worker-crash-plugins-sessions-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/42-worker-crash/plugins/sessions/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-42-worker-crash-plugins-sessions-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/42-worker-crash/plugins/sessions/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-42-worker-crash-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/42-worker-crash/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-43-rollout-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/43-rollout/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-43-rollout-plugins-notes-contract.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/43-rollout/plugins/notes/contract.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-43-rollout-plugins-notes-label.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/43-rollout/plugins/notes/label.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-43-rollout-plugins-notes-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/43-rollout/plugins/notes/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-43-rollout-plugins-notes-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/43-rollout/plugins/notes/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-43-rollout-plugins-notes-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/43-rollout/plugins/notes/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-43-rollout-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/43-rollout/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-44-http-wraps-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/44-http-wraps/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-44-http-wraps-plugins-audit-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/44-http-wraps/plugins/audit/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-44-http-wraps-plugins-audit-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/44-http-wraps/plugins/audit/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-44-http-wraps-plugins-notes-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/44-http-wraps/plugins/notes/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-44-http-wraps-plugins-notes-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/44-http-wraps/plugins/notes/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-45-plugin-socket-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/45-plugin-socket/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-45-plugin-socket-plugins-echo-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/45-plugin-socket/plugins/echo/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-45-plugin-socket-plugins-echo-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/45-plugin-socket/plugins/echo/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-46-allowed-hosts-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/46-allowed-hosts/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-46-allowed-hosts-plugins-tunnel-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/46-allowed-hosts/plugins/tunnel/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-46-allowed-hosts-plugins-tunnel-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/46-allowed-hosts/plugins/tunnel/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-47-http-own-server-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/47-http-own-server/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-47-http-own-server-plugins-notes-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/47-http-own-server/plugins/notes/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-47-http-own-server-plugins-notes-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/47-http-own-server/plugins/notes/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-48-http-baseline-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/48-http-baseline/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-48-http-baseline-plugins-notes-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/48-http-baseline/plugins/notes/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-48-http-baseline-plugins-notes-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/48-http-baseline/plugins/notes/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-app-v2.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/app/v2.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-app-v3-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/app/v3/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-app-v3-web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/app/v3/web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-app-v3-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/app/v3/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-app-v3.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/app/v3.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-plugins-ancient-env.d.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/plugins/ancient/env.d.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-plugins-ancient-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/plugins/ancient/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-plugins-ancient-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/plugins/ancient/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-plugins-direct-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/plugins/direct/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-plugins-direct-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/plugins/direct/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-plugins-hello-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/plugins/hello/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-plugins-hello-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/plugins/hello/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-plugins-legacy-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/plugins/legacy/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-plugins-legacy-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/plugins/legacy/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-plugins-mixed-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/plugins/mixed/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-plugins-mixed-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/plugins/mixed/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-plugins-panel-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/plugins/panel/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-plugins-panel-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/plugins/panel/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-49-plugin-api-plugins-panel-web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/49-plugin-api/plugins/panel/web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-plugins-notes-contract.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/plugins/notes/contract.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-plugins-notes-contract.web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/plugins/notes/contract.web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-plugins-notes-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/plugins/notes/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-plugins-notes-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/plugins/notes/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-plugins-peek-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/plugins/peek/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-plugins-peek-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/plugins/peek/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-plugins-peek-view.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/plugins/peek/view.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-plugins-search-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/plugins/search/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-plugins-search-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/plugins/search/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-plugins-search-web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/plugins/search/web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-user-reach-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/user/reach/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-user-reach-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/user/reach/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-user-stats-env.d.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/user/stats/env.d.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-user-stats-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/user/stats/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-user-stats-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/user/stats/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-words-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/words/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-50-plugin-imports-words-words.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/50-plugin-imports/words/words.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-51-single-file-plugin-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/51-single-file-plugin/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-51-single-file-plugin-plugins-bad.server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/51-single-file-plugin/plugins/bad.server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-51-single-file-plugin-plugins-clock.server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/51-single-file-plugin/plugins/clock.server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-51-single-file-plugin-plugins-hello.server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/51-single-file-plugin/plugins/hello.server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-51-single-file-plugin-plugins-hello.web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/51-single-file-plugin/plugins/hello.web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-51-single-file-plugin-plugins-helper.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/51-single-file-plugin/plugins/helper.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-52-test-plugin-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/52-test-plugin/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-52-test-plugin-plugins-notes-contract.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/52-test-plugin/plugins/notes/contract.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-52-test-plugin-plugins-notes-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/52-test-plugin/plugins/notes/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-52-test-plugin-plugins-stats-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/52-test-plugin/plugins/stats/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-52-test-plugin-plugins-stats-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/52-test-plugin/plugins/stats/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-53-app-app-principals.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/53-app/app/principals.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-53-app-app-v1-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/53-app/app/v1/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-53-app-app-v1.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/53-app/app/v1.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-53-app-client.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/53-app/client.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-53-app-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/53-app/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-53-app-plugins-home-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/53-app/plugins/home/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-53-app-plugins-home-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/53-app/plugins/home/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-53-app-plugins-notes-contract.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/53-app/plugins/notes/contract.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-53-app-plugins-notes-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/53-app/plugins/notes/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-53-app-plugins-notes-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/53-app/plugins/notes/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-53-app-plugins-notes-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/53-app/plugins/notes/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-53-app-start.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/53-app/start.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-53-app-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/53-app/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-54-app-sign-ins-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/54-app-sign-ins/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-55-app-export-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/55-app-export/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-56-web-app-principals.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/56-web/app/principals.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-56-web-app-v1-tui.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/56-web/app/v1/tui.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-56-web-app-v1-web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/56-web/app/v1/web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-56-web-app-v1.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/56-web/app/v1.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-56-web-headless.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/56-web/headless.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-56-web-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/56-web/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-56-web-plugins-clock-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/56-web/plugins/clock/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-56-web-plugins-clock-web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/56-web/plugins/clock/web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-56-web-plugins-notes-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/56-web/plugins/notes/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-56-web-plugins-notes-tui.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/56-web/plugins/notes/tui.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-56-web-plugins-notes-web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/56-web/plugins/notes/web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-56-web-start.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/56-web/start.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-56-web-tui-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/56-web/tui/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-56-web-web-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/56-web/web/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-57-tui-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/57-tui/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-57-tui-terminal.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/57-tui/terminal.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-58-themes-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/58-themes/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-58-themes-plugins-midnight.web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/58-themes/plugins/midnight.web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-58-themes-plugins-solarized-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/58-themes/plugins/solarized/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-58-themes-plugins-solarized-theme.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/58-themes/plugins/solarized/theme.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-58-themes-plugins-solarized-tui.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/58-themes/plugins/solarized/tui.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-58-themes-plugins-solarized-web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/58-themes/plugins/solarized/web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-59-chat-app-principals.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/59-chat/app/principals.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-59-chat-app-v1-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/59-chat/app/v1/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-59-chat-app-v1-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/59-chat/app/v1/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-59-chat-app-v1.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/59-chat/app/v1.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-59-chat-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/59-chat/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-59-chat-plugins-chat-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/59-chat/plugins/chat/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-59-chat-plugins-chat-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/59-chat/plugins/chat/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-59-chat-plugins-chat-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/59-chat/plugins/chat/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-59-chat-plugins-login.server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/59-chat/plugins/login.server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-59-chat-start.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/59-chat/start.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-59-chat-tui-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/59-chat/tui/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-59-chat-web-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/59-chat/web/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-59-chat-web-style.css.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/59-chat/web/style.css`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-59-chat-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/59-chat/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-60-session-sync-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/60-session-sync/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-60-session-sync-radius.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/60-session-sync/radius.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-60-session-sync-session.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/60-session-sync/session.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-60-session-sync-sync.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/60-session-sync/sync.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-later-harbor-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/later/harbor/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-later-harbor-theme.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/later/harbor/theme.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-later-harbor-tui.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/later/harbor/tui.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-later-harbor-web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/later/harbor/web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-french-fr.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/french/fr.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-french-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/french/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-french-tui.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/french/tui.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-french-web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/french/web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-lists-contract.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/lists/contract.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-lists-lists.css.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/lists/lists.css`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-lists-messages.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/lists/messages.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-lists-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/lists/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-lists-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/lists/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-lists-tui.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/lists/tui.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-lists-web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/lists/web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-lists-worker.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/lists/worker.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-lists-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/lists/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-login.server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/login.server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-traces-clock.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/traces/clock.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-traces-clock.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/traces/clock.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-traces-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/traces/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-plugins-traces-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/plugins/traces/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-screenshots.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/screenshots.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-src-api-v1-index.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/src/api/v1/index.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-src-api-v1-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/src/api/v1/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-src-api-v1-tui.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/src/api/v1/tui.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-src-api-v1-web.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/src/api/v1/web.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-src-principals.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/src/principals.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-src-telemetry.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/src/telemetry.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-src-tui-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/src/tui/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-src-web-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/src/web/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-src-web-style.css.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/src/web/style.css`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-src-web-traces.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/src/web/traces.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-start.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/start.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-trace.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/trace.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-tutorial.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/tutorial.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-61-tutorial-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/61-tutorial/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-62-telemetry-app-principals.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/62-telemetry/app/principals.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-62-telemetry-app-v1.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/62-telemetry/app/v1.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-62-telemetry-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/62-telemetry/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-62-telemetry-plugins-tally-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/62-telemetry/plugins/tally/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-62-telemetry-plugins-tally-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/62-telemetry/plugins/tally/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-62-telemetry-start.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/62-telemetry/start.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-62-telemetry-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/62-telemetry/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-63-optimistic-answers.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/63-optimistic-answers.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-64-old-work.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/64-old-work.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-65-files.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/65-files.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-66-host-data.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/66-host-data.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-66-websocket-limits.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/66-websocket-limits.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-67-events.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/67-events.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-68-shared-holds.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/68-shared-holds.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-69-admission.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/69-admission.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-70-named-queries.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/70-named-queries.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-71-lists.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/71-lists.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-72-exists-and-joins.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/72-exists-and-joins.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-76-worker-reports-contract.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/76-worker-reports/contract.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-76-worker-reports-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/76-worker-reports/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-examples-76-worker-reports-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/examples/76-worker-reports/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-activity.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/activity.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-adapted.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/adapted.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-admission.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/admission.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-attempt.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/attempt.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-backoff.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/backoff.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-ctx.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/ctx.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-deadline.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/deadline.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-dependencies.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/dependencies.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-events.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/events.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-facet.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/facet.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-follow.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/follow.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-host-data.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/host-data.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-host.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/host.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-list.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/list.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-members.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/members.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-named-query.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/named-query.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-native.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/native.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-object.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/object.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-old-work.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/old-work.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-parked.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/parked.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-presence.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/presence.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-query-reader.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/query-reader.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-read-declarations.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/read-declarations.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-readiness.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/readiness.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-ref-state.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/ref-state.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-reference-events.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/reference-events.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-reference-keys.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/reference-keys.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-reference-source.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/reference-source.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-reference.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/reference.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-reload-cycle.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/reload-cycle.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-retry-on.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/retry-on.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-revocation.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/revocation.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-root.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/root.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-route-admission.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/route-admission.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-route.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/route.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-routines.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/routines.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-sleep.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/sleep.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-staging.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/staging.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-tiling.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/tiling.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-unbound-clock.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/unbound-clock.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-host-unbound.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/host/unbound.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-jobs-definition.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/jobs/definition.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-jobs-job.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/jobs/job.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-jobs-persisted.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/jobs/persisted.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-jobs-records.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/jobs/records.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-jobs-run.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/jobs/run.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-jobs-running.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/jobs/running.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-json.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/json.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-link-channel.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/link/channel.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-link-errors.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/link/errors.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-link-fixtures-ipc-echo.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/link/fixtures/ipc-echo.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-link-ipc.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/link/ipc.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-link-link.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/link/link.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-link-message.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/link/message.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-link-part.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/link/part.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-link-values.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/link/values.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-link-websocket.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/link/websocket.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-app.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/app.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-archive.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/archive.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-blobs.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/blobs.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-ephemeral-sign-ins.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/ephemeral-sign-ins.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-ephemeral.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/ephemeral.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-files-copy.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/files-copy.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-files-index.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/files-index.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-files.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/files.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-folder-views.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/folder-views.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-info.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/info.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-invite.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/invite.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-layout.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/layout.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-owner.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/owner.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-pairing.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/pairing.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-secrets.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/secrets.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-sign-ins.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/sign-ins.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-support.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/support.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-tar.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/tar.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-uploads.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/uploads.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-users.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/users.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-app-worker.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/app/worker.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-compression.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/compression.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-app-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/app/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-esm-host.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/esm-host.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-plugins-contracts-contract.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/plugins/contracts/contract.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-plugins-contracts-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/plugins/contracts/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-plugins-files-assets-data.txt.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/plugins/files/assets/data.txt`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-plugins-files-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/plugins/files/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-plugins-files-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/plugins/files/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-plugins-notes-label.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/plugins/notes/label.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-plugins-notes-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/plugins/notes/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-plugins-notes-server.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/plugins/notes/server.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-plugins-notes-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/plugins/notes/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-reload-app.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/reload/app.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-reload-entry.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/reload/entry.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-reload-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/reload/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-reload-plugins.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/reload/plugins.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-reload-web-api.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/reload/web-api.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-tui-api.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/tui/api.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-tui-drive.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/tui/drive.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-tui-escapes.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/tui/escapes.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-tui-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/tui/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-tui-os-layer.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/tui/os-layer.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-tui-sandbox-run.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/tui/sandbox-run.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-web-api.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/web/api.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-web-main.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/web/main.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-web-telemetry.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/web/telemetry.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-workers-child.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/workers/child.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-workers-control.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/workers/control.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-workers-lazy-close.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/workers/lazy-close.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-workers-plugins-notes-label.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/workers/plugins/notes/label.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-workers-plugins-notes-package.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/workers/plugins/notes/package.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-workers-plugins-notes-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/workers/plugins/notes/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-fixtures-workers-worker.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/fixtures/workers/worker.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-http-admission.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/http/admission.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-http-authenticate.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/http/authenticate.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-http-cookies.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/http/cookies.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-http-file.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/http/file.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-http-headers.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/http/headers.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-http-http.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/http/http.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-http-node.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/http/node.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-http-request.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/http/request.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-http-response.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/http/response.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-http-router.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/http/router.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-http-support.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/http/support.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-http-upgrades.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/http/upgrades.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-plugins-base-inputs.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/plugins/base-inputs.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-plugins-build.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/plugins/build.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-plugins-discover.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/plugins/discover.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-plugins-evaluate.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/plugins/evaluate.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-plugins-install.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/plugins/install.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-plugins-plugins.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/plugins/plugins.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-plugins-runtime.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/plugins/runtime.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-plugins-stack.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/plugins/stack.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-plugins-support.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/plugins/support.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-plugins-testing.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/plugins/testing.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-plugins-watcher.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/plugins/watcher.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-react-hooks.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/react/hooks.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-react-stores.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/react/stores.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-reload-base.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/reload/base.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-reload-contracts.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/reload/contracts.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-reload-failed.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/reload/failed.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-reload-jobs.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/reload/jobs.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-reload-pure.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/reload/pure.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-reload-restart.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/reload/restart.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-reload-rollout.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/reload/rollout.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-reload-web.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/reload/web.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-surfaces-bundle.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/surfaces/bundle.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-surfaces-surface-build.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/surfaces/surface-build.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-surfaces-tui.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/surfaces/tui.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-surfaces-web.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/surfaces/web.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-tui-actions.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/tui/actions.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-tui-credentials.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/tui/credentials.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-tui-filter.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/tui/filter.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-tui-launcher.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/tui/launcher.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-tui-pipe.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/tui/pipe.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-tui-sandbox.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/tui/sandbox.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-tui-support.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/tui/support.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-web-browser.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/web/browser.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-web-language.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/web/language.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-web-page.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/web/page.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-web-styles.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/web/styles.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-web-support.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/web/support.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-workers-base.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/workers/base.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-workers-child.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/workers/child.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-workers-control.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/workers/control.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-workers-lock.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/workers/lock.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-workers-main.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/workers/main.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-workers-process.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/workers/process.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-workers-support.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/workers/support.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-node-workers-workers.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/node/workers/workers.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-output-skip.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/output-skip.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-output.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/output.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-registries-entries.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/registries/entries.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-registries-record.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/registries/record.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-registries-registry.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/registries/registry.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-registries-value.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/registries/value.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-remote-calls.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/remote/calls.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-remote-consumer.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/remote/consumer.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-remote-hold.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/remote/hold.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-remote-host-link.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/remote/host-link.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-remote-path.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/remote/path.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-remote-provider.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/remote/provider.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-remote-relay.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/remote/relay.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-remote-remote-object.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/remote/remote-object.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-remote-replica.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/remote/replica.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-schema-declarations.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/schema/declarations.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-schema-owner.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/schema/owner.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-schema-proofs.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/schema/proofs.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-schema-recorded.json.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/schema/recorded.json`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-schema-schema-switch.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/schema/schema-switch.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-schema-stored-archive.jsonl.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/schema/stored/archive.jsonl`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-schema-stored-store.db.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/schema/stored/store.db`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-schema-write-stored.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/schema/write-stored.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-sqlite-cloudflare.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/sqlite/cloudflare.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-sqlite-helpers.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/sqlite/helpers.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-sqlite-migrations.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/sqlite/migrations.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-sqlite-node.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/sqlite/node.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-state-batch.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/state/batch.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-state-derive.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/state/derive.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-state-diff.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/state-diff.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-state-draft.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/state-draft.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-state-framed.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/state/framed.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-state-fuzz.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/state-fuzz.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-state-native-source.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/state/native-source.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-state-value.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/state-value.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-state-watchable.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/state/watchable.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-state-writable.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/state/writable.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-allocator.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/allocator.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-applier.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/applier.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-apply-batch.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/apply-batch.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-archive.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/archive.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-catalog.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/catalog.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-claims.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/claims.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-column-set.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/column-set.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-columns.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/columns.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-engine.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/engine.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-evaluate.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/evaluate.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-export.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/export.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-expression.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/expression.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-host-column.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/host-column.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-host-data.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/host-data.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-import-migration.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/import-migration.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-import.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/import.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-json-column.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/json-column.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-jsonl.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/jsonl.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-live-query.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/live-query.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-outbox.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/outbox.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-query.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/query.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-read-plan.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/read-plan.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-reads.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/reads.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-refusal.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/refusal.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-rows.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/rows.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-skip.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/skip.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-sql.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/sql.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-store.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/store.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-table-changes.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/table-changes.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-table-evolve.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/table-evolve.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-table-handle.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/table-handle.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-table-history.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/table-history.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-table-migration.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/table-migration.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-table-writes.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/table-writes.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-table.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/table.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-store-text.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/store/text.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-support.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/support.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-surfaces-active-language.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/surfaces/active-language.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-surfaces-active-theme.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/surfaces/active-theme.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-surfaces-client.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/surfaces/client.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-surfaces-connection.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/surfaces/connection.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-surfaces-format.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/surfaces/format.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-surfaces-language.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/surfaces/language.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-surfaces-locale-choice.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/surfaces/locale-choice.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-surfaces-messages.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/surfaces/messages.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-surfaces-page-state.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/surfaces/page-state.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-surfaces-preference.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/surfaces/preference.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-surfaces-registered.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/surfaces/registered.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-surfaces-themes.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/surfaces/themes.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-surfaces-translations.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/surfaces/translations.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-surfaces-variant.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/surfaces/variant.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-sync-lines.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/sync/lines.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-sync-node-files.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/sync/node-files.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-sync-sync.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/sync/sync.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-telemetry-ingest-facet.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/telemetry-ingest/facet.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-telemetry-ingest-recorder.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/telemetry-ingest/recorder.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-telemetry-ingest-sender.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/telemetry-ingest/sender.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-telemetry-sqlite-node.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/telemetry-sqlite-node.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-telemetry-sqlite-store.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/telemetry-sqlite-store.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-telemetry-sqlite.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/telemetry-sqlite.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-telemetry.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/telemetry.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-tui-frames.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/tui/frames.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-tui-scope.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/tui/scope.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `chord.packages-chord-test-watch.test.ts.internal.test`

- Area: `chord`, kind: `test`
- Upstream: `packages/chord/test/watch.test.ts`
- Dart: `pi_agent/lib/src/harness.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#62`

### `ai.packages-ai-src-api-azure-openai-responses.lazy.ts.azureOpenAIResponsesApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/api/azure-openai-responses.lazy.ts` → `azureOpenAIResponsesApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: API transport (HTTP client, request building, provider quirks) is not ported; the Dart port streams no requests for this provider.
- Issue: `##65`

### `ai.packages-ai-src-api-bedrock-converse-stream.lazy.ts.bedrockConverseStreamApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/api/bedrock-converse-stream.lazy.ts` → `bedrockConverseStreamApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: API transport (HTTP client, request building, provider quirks) is not ported; the Dart port streams no requests for this provider.
- Issue: `##65`

### `ai.packages-ai-src-api-bedrock-converse-stream.lazy.ts.setBedrockProviderLoader.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/api/bedrock-converse-stream.lazy.ts` → `setBedrockProviderLoader`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: API transport (HTTP client, request building, provider quirks) is not ported; the Dart port streams no requests for this provider.
- Issue: `##65`

### `ai.packages-ai-src-api-bedrock-converse-stream.lazy.ts.setBedrockProviderModule.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/api/bedrock-converse-stream.lazy.ts` → `setBedrockProviderModule`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: API transport (HTTP client, request building, provider quirks) is not ported; the Dart port streams no requests for this provider.
- Issue: `##65`

### `ai.packages-ai-src-api-google-generative-ai.lazy.ts.googleGenerativeAIApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/api/google-generative-ai.lazy.ts` → `googleGenerativeAIApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: API transport (HTTP client, request building, provider quirks) is not ported; the Dart port streams no requests for this provider.
- Issue: `##65`

### `ai.packages-ai-src-api-google-vertex.lazy.ts.googleVertexApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/api/google-vertex.lazy.ts` → `googleVertexApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: API transport (HTTP client, request building, provider quirks) is not ported; the Dart port streams no requests for this provider.
- Issue: `##65`

### `ai.packages-ai-src-api-lazy.ts.lazyApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/api/lazy.ts` → `lazyApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: API transport (HTTP client, request building, provider quirks) is not ported; the Dart port streams no requests for this provider.
- Issue: `##65`

### `ai.packages-ai-src-api-lazy.ts.LazyApiCapabilities.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/api/lazy.ts` → `LazyApiCapabilities`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: API transport (HTTP client, request building, provider quirks) is not ported; the Dart port streams no requests for this provider.
- Issue: `##65`

### `ai.packages-ai-src-api-lazy.ts.lazyStream.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/api/lazy.ts` → `lazyStream`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: API transport (HTTP client, request building, provider quirks) is not ported; the Dart port streams no requests for this provider.
- Issue: `##65`

### `ai.packages-ai-src-api-lazy.ts.LazyStreamObserver.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/api/lazy.ts` → `LazyStreamObserver`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: API transport (HTTP client, request building, provider quirks) is not ported; the Dart port streams no requests for this provider.
- Issue: `##65`

### `ai.packages-ai-src-api-openai-codex-responses.lazy.ts.openAICodexResponsesApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/api/openai-codex-responses.lazy.ts` → `openAICodexResponsesApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: API transport (HTTP client, request building, provider quirks) is not ported; the Dart port streams no requests for this provider.
- Issue: `##65`

### `ai.packages-ai-src-api-openai-completions.lazy.ts.openAICompletionsApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/api/openai-completions.lazy.ts` → `openAICompletionsApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: API transport (HTTP client, request building, provider quirks) is not ported; the Dart port streams no requests for this provider.
- Issue: `##65`

### `ai.packages-ai-src-api-openai-responses.lazy.ts.openAIResponsesApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/api/openai-responses.lazy.ts` → `openAIResponsesApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: API transport (HTTP client, request building, provider quirks) is not ported; the Dart port streams no requests for this provider.
- Issue: `##65`

### `ai.packages-ai-src-api-pi-messages.lazy.ts.piMessagesApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/api/pi-messages.lazy.ts` → `piMessagesApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: API transport (HTTP client, request building, provider quirks) is not ported; the Dart port streams no requests for this provider.
- Issue: `##65`

### `ai.packages-ai-src-auth-context.ts.defaultProviderAuthContext.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/context.ts` → `defaultProviderAuthContext`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-credential-store.ts.InMemoryCredentialStore.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/credential-store.ts` → `InMemoryCredentialStore`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-helpers.ts.envApiKeyAuth.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/helpers.ts` → `envApiKeyAuth`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-helpers.ts.lazyOAuth.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/helpers.ts` → `lazyOAuth`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.ApiKeyAuth.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `ApiKeyAuth`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.ApiKeyCredential.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `ApiKeyCredential`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.AuthCheck.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `AuthCheck`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.AuthContext.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `AuthContext`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.AuthEvent.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `AuthEvent`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.AuthInfoLink.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `AuthInfoLink`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.AuthInteraction.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `AuthInteraction`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.AuthOperationOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `AuthOperationOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.AuthPrompt.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `AuthPrompt`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.AuthResult.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `AuthResult`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.AuthType.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `AuthType`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.Credential.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `Credential`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.CredentialInfo.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `CredentialInfo`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.CredentialStore.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `CredentialStore`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.LoginOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `LoginOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.ModelAuth.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `ModelAuth`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.OAuthAuth.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `OAuthAuth`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.OAuthCredential.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `OAuthCredential`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.OAuthCredentials.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `OAuthCredentials`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.ProviderAuth.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `ProviderAuth`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-auth-types.ts.ProviderAuthInteraction.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/auth/types.ts` → `ProviderAuthInteraction`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider auth (OAuth flows, credential stores, federation) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-cache-warming.ts.CACHE_WARMING_IDLE_CONTINUATION_PROBABILITY.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/cache-warming.ts` → `CACHE_WARMING_IDLE_CONTINUATION_PROBABILITY`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Prompt-cache warming is not ported.
- Issue: `##65`

### `ai.packages-ai-src-cache-warming.ts.CACHE_WARMING_MAX_AGE_MS.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/cache-warming.ts` → `CACHE_WARMING_MAX_AGE_MS`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Prompt-cache warming is not ported.
- Issue: `##65`

### `ai.packages-ai-src-cache-warming.ts.CACHE_WARMING_MAX_IDLE_AGE_MS.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/cache-warming.ts` → `CACHE_WARMING_MAX_IDLE_AGE_MS`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Prompt-cache warming is not ported.
- Issue: `##65`

### `ai.packages-ai-src-cache-warming.ts.CACHE_WARMING_MINIMUM_EXPECTED_SAVINGS.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/cache-warming.ts` → `CACHE_WARMING_MINIMUM_EXPECTED_SAVINGS`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Prompt-cache warming is not ported.
- Issue: `##65`

### `ai.packages-ai-src-cache-warming.ts.CacheWarmingAction.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/cache-warming.ts` → `CacheWarmingAction`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Prompt-cache warming is not ported.
- Issue: `##65`

### `ai.packages-ai-src-cache-warming.ts.CacheWarmingDecision.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/cache-warming.ts` → `CacheWarmingDecision`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Prompt-cache warming is not ported.
- Issue: `##65`

### `ai.packages-ai-src-cache-warming.ts.CacheWarmingPhase.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/cache-warming.ts` → `CacheWarmingPhase`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Prompt-cache warming is not ported.
- Issue: `##65`

### `ai.packages-ai-src-cache-warming.ts.evaluateCacheWarming.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/cache-warming.ts` → `evaluateCacheWarming`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Prompt-cache warming is not ported.
- Issue: `##65`

### `ai.packages-ai-src-cache-warming.ts.getCacheWarmingDelayMs.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/cache-warming.ts` → `getCacheWarmingDelayMs`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Prompt-cache warming is not ported.
- Issue: `##65`

### `ai.packages-ai-src-cache-warming.ts.getCacheWarmingRequestOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/cache-warming.ts` → `getCacheWarmingRequestOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Prompt-cache warming is not ported.
- Issue: `##65`

### `ai.packages-ai-src-cache-warming.ts.getPromptCacheTtlMs.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/cache-warming.ts` → `getPromptCacheTtlMs`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Prompt-cache warming is not ported.
- Issue: `##65`

### `ai.packages-ai-src-cache-warming.ts.isCacheWarmingReplayable.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/cache-warming.ts` → `isCacheWarmingReplayable`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Prompt-cache warming is not ported.
- Issue: `##65`

### `ai.packages-ai-src-cli.ts.internal.internal`

- Area: `ai`, kind: `internal`
- Upstream: `packages/ai/src/cli.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The pi-ai CLI surface is not ported.
- Issue: `##65`

### `ai.packages-ai-src-env-api-keys.ts.ANTHROPIC_API_KEY_ENV.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/env-api-keys.ts` → `ANTHROPIC_API_KEY_ENV`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Environment API-key resolution is not ported.
- Issue: `##65`

### `ai.packages-ai-src-env-api-keys.ts.ANTHROPIC_AUTH_TOKEN_ENV.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/env-api-keys.ts` → `ANTHROPIC_AUTH_TOKEN_ENV`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Environment API-key resolution is not ported.
- Issue: `##65`

### `ai.packages-ai-src-env-api-keys.ts.ANTHROPIC_FEDERATION_RULE_ID_ENV.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/env-api-keys.ts` → `ANTHROPIC_FEDERATION_RULE_ID_ENV`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Environment API-key resolution is not ported.
- Issue: `##65`

### `ai.packages-ai-src-env-api-keys.ts.ANTHROPIC_IDENTITY_TOKEN_FILE_ENV.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/env-api-keys.ts` → `ANTHROPIC_IDENTITY_TOKEN_FILE_ENV`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Environment API-key resolution is not ported.
- Issue: `##65`

### `ai.packages-ai-src-env-api-keys.ts.ANTHROPIC_OAUTH_TOKEN_ENV.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/env-api-keys.ts` → `ANTHROPIC_OAUTH_TOKEN_ENV`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Environment API-key resolution is not ported.
- Issue: `##65`

### `ai.packages-ai-src-env-api-keys.ts.ANTHROPIC_ORGANIZATION_ID_ENV.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/env-api-keys.ts` → `ANTHROPIC_ORGANIZATION_ID_ENV`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Environment API-key resolution is not ported.
- Issue: `##65`

### `ai.packages-ai-src-env-api-keys.ts.ANTHROPIC_SERVICE_ACCOUNT_ID_ENV.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/env-api-keys.ts` → `ANTHROPIC_SERVICE_ACCOUNT_ID_ENV`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Environment API-key resolution is not ported.
- Issue: `##65`

### `ai.packages-ai-src-env-api-keys.ts.ANTHROPIC_WORKSPACE_ID_ENV.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/env-api-keys.ts` → `ANTHROPIC_WORKSPACE_ID_ENV`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Environment API-key resolution is not ported.
- Issue: `##65`

### `ai.packages-ai-src-env-api-keys.ts.findEnvKeys.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/env-api-keys.ts` → `findEnvKeys`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Environment API-key resolution is not ported.
- Issue: `##65`

### `ai.packages-ai-src-env-api-keys.ts.getEnvApiKey.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/env-api-keys.ts` → `getEnvApiKey`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Environment API-key resolution is not ported.
- Issue: `##65`

### `ai.packages-ai-src-image-models.ts.BuiltinImageProvider.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/image-models.ts` → `BuiltinImageProvider`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Image-model selection is not ported.
- Issue: `##65`

### `ai.packages-ai-src-image-models.ts.getImageModel.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/image-models.ts` → `getImageModel`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Image-model selection is not ported.
- Issue: `##65`

### `ai.packages-ai-src-image-models.ts.getImageModels.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/image-models.ts` → `getImageModels`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Image-model selection is not ported.
- Issue: `##65`

### `ai.packages-ai-src-image-models.ts.getImageProviders.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/image-models.ts` → `getImageProviders`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Image-model selection is not ported.
- Issue: `##65`

### `ai.packages-ai-src-images-api-registry.ts.getImagesApiProvider.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/images-api-registry.ts` → `getImagesApiProvider`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The image API registry is not ported.
- Issue: `##65`

### `ai.packages-ai-src-images-api-registry.ts.ImagesApiFunction.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/images-api-registry.ts` → `ImagesApiFunction`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The image API registry is not ported.
- Issue: `##65`

### `ai.packages-ai-src-images-api-registry.ts.ImagesApiProvider.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/images-api-registry.ts` → `ImagesApiProvider`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The image API registry is not ported.
- Issue: `##65`

### `ai.packages-ai-src-images-api-registry.ts.registerImagesApiProvider.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/images-api-registry.ts` → `registerImagesApiProvider`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The image API registry is not ported.
- Issue: `##65`

### `ai.packages-ai-src-images.ts.generateImages.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/images.ts` → `generateImages`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Image generation is not ported.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.AnthropicEffort.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `AnthropicEffort`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.AnthropicOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `AnthropicOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.AnthropicThinkingDisplay.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `AnthropicThinkingDisplay`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.AzureOpenAIResponsesOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `AzureOpenAIResponsesOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.BedrockOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `BedrockOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.BedrockThinkingDisplay.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `BedrockThinkingDisplay`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.contentText.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `contentText`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.getSystemMessageText.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `getSystemMessageText`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.GoogleApiThinkingLevel.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `GoogleApiThinkingLevel`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.GoogleOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `GoogleOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.GoogleVertexOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `GoogleVertexOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.MistralOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `MistralOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.OpenAICodexResponsesOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `OpenAICodexResponsesOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.OpenAICodexWebSocketDebugStats.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `OpenAICodexWebSocketDebugStats`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.OpenAICompletionsOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `OpenAICompletionsOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.OpenAIResponsesOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `OpenAIResponsesOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.PI_AI_VERSION.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `PI_AI_VERSION`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.PiMessagesEvent.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `PiMessagesEvent`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.PiMessagesOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `PiMessagesOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.PiMessagesRewriteImpact.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `PiMessagesRewriteImpact`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.renderSystemMessageUpdate.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `renderSystemMessageUpdate`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.ResolvedGoogleThinkingLevel.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `ResolvedGoogleThinkingLevel`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-index.ts.uuidv7.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/index.ts` → `uuidv7`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Barrel exports beyond the ported slices are not surfaced by package:pi/ai.dart.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamAnthropic.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamAnthropic`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamAzureOpenAIResponses.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamAzureOpenAIResponses`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamGoogle.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamGoogle`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamGoogleVertex.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamGoogleVertex`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamMistral.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamMistral`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamOpenAICodexResponses.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamOpenAICodexResponses`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamOpenAICompletions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamOpenAICompletions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamOpenAIResponses.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamOpenAIResponses`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamSimpleAnthropic.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamSimpleAnthropic`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamSimpleAzureOpenAIResponses.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamSimpleAzureOpenAIResponses`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamSimpleGoogle.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamSimpleGoogle`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamSimpleGoogleVertex.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamSimpleGoogleVertex`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamSimpleMistral.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamSimpleMistral`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamSimpleOpenAICodexResponses.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamSimpleOpenAICodexResponses`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamSimpleOpenAICompletions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamSimpleOpenAICompletions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-legacy-api-aliases.ts.streamSimpleOpenAIResponses.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/legacy-api-aliases.ts` → `streamSimpleOpenAIResponses`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Legacy API aliases are not ported.
- Issue: `##65`

### `ai.packages-ai-src-models-store.ts.InMemoryModelsStore.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models-store.ts` → `InMemoryModelsStore`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog store (resolution, refresh, auth wiring) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models-store.ts.ModelsStore.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models-store.ts` → `ModelsStore`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog store (resolution, refresh, auth wiring) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models-store.ts.ModelsStoreEntry.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models-store.ts` → `ModelsStoreEntry`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog store (resolution, refresh, auth wiring) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models-store.ts.ModelsStoreOperationOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models-store.ts` → `ModelsStoreOperationOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog store (resolution, refresh, auth wiring) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.AI_TELEMETRY_SCHEMA.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `AI_TELEMETRY_SCHEMA`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.calculateCost.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `calculateCost`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.clampThinkingLevel.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `clampThinkingLevel`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.createModels.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `createModels`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.CreateModelsOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `CreateModelsOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.createProvider.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `createProvider`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.CreateProviderOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `CreateProviderOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.getModelType.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `getModelType`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.getSupportedThinkingLevels.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `getSupportedThinkingLevels`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.hasApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `hasApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.isModelType.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `isModelType`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.Models.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `Models`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.ModelsApiStreamOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `ModelsApiStreamOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.modelsAreEqual.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `modelsAreEqual`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.ModelsClassifierOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `ModelsClassifierOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.ModelsDeferredCancelOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `ModelsDeferredCancelOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.ModelsDeferredFetchOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `ModelsDeferredFetchOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.ModelsError.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `ModelsError`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.ModelsImagesOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `ModelsImagesOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.ModelsPublication.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `ModelsPublication`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.ModelsRefreshOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `ModelsRefreshOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.ModelsRefreshResult.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `ModelsRefreshResult`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.ModelsRequestTransforms.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `ModelsRequestTransforms`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.ModelsSimpleStreamOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `ModelsSimpleStreamOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.MutableModels.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `MutableModels`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.Provider.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `Provider`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-models.ts.RefreshModelsContext.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/models.ts` → `RefreshModelsContext`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The model catalog (cost tiers, compat resolution, context limits) is not ported; the Dart port carries only inline model descriptors.
- Issue: `##65`

### `ai.packages-ai-src-oauth.ts.internal.internal`

- Area: `ai`, kind: `internal`
- Upstream: `packages/ai/src/oauth.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: OAuth device/authorization flows are not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-faux.ts.createFauxCore.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/faux.ts` → `createFauxCore`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The faux test provider is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-faux.ts.fauxAssistantMessage.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/faux.ts` → `fauxAssistantMessage`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The faux test provider is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-faux.ts.FauxContentBlock.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/faux.ts` → `FauxContentBlock`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The faux test provider is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-faux.ts.FauxModelDefinition.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/faux.ts` → `FauxModelDefinition`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The faux test provider is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-faux.ts.fauxProvider.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/faux.ts` → `fauxProvider`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The faux test provider is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-faux.ts.FauxProviderHandle.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/faux.ts` → `FauxProviderHandle`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The faux test provider is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-faux.ts.FauxProviderRegistration.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/faux.ts` → `FauxProviderRegistration`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The faux test provider is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-faux.ts.FauxProviderState.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/faux.ts` → `FauxProviderState`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The faux test provider is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-faux.ts.FauxResponseFactory.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/faux.ts` → `FauxResponseFactory`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The faux test provider is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-faux.ts.FauxResponseStep.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/faux.ts` → `FauxResponseStep`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The faux test provider is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-faux.ts.fauxText.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/faux.ts` → `fauxText`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The faux test provider is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-faux.ts.fauxThinking.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/faux.ts` → `fauxThinking`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The faux test provider is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-faux.ts.fauxToolCall.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/faux.ts` → `fauxToolCall`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The faux test provider is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-faux.ts.RegisterFauxProviderOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/faux.ts` → `RegisterFauxProviderOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The faux test provider is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-images-register-builtins.ts.generateImagesOpenRouter.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/images/register-builtins.ts` → `generateImagesOpenRouter`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Image provider registration is not ported.
- Issue: `##65`

### `ai.packages-ai-src-providers-images-register-builtins.ts.registerBuiltInImagesApiProviders.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/providers/images/register-builtins.ts` → `registerBuiltInImagesApiProviders`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Image provider registration is not ported.
- Issue: `##65`

### `ai.packages-ai-src-session-resources.ts.cleanupSessionResources.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/session-resources.ts` → `cleanupSessionResources`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Session resources are not ported.
- Issue: `##65`

### `ai.packages-ai-src-session-resources.ts.registerSessionResourceCleanup.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/session-resources.ts` → `registerSessionResourceCleanup`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Session resources are not ported.
- Issue: `##65`

### `ai.packages-ai-src-session-resources.ts.SessionResourceCleanup.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/session-resources.ts` → `SessionResourceCleanup`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Session resources are not ported.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.AnyModel.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `AnyModel`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.Api.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `Api`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ApiOptionsMap.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ApiOptionsMap`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ApiStreamOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ApiStreamOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.AssistantImages.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `AssistantImages`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.AssistantMessage.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `AssistantMessage`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.AssistantMessageEvent.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `AssistantMessageEvent`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.AssistantMessageEventStream.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `AssistantMessageEventStream`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.BaseModel.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `BaseModel`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierAnswer.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierAnswer`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierBoolAnswer.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierBoolAnswer`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierBoolQuestion.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierBoolQuestion`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierChoiceAnswer.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierChoiceAnswer`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierChoiceQuestion.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierChoiceQuestion`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierContext.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierContext`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierFunction.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierFunction`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierModel.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierModel`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierQuestion.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierQuestion`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierResult.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierResult`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierScoreAnswer.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierScoreAnswer`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierScoreQuestion.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierScoreQuestion`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ClassifierStopReason.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ClassifierStopReason`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ConstrainedSamplingConfig.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ConstrainedSamplingConfig`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.Context.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `Context`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.DeferredCancelOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `DeferredCancelOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.DeferredFetchOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `DeferredFetchOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.DeferredHandle.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `DeferredHandle`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.FetchFunction.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `FetchFunction`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.GrammarFormat.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `GrammarFormat`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.GrammarVariants.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `GrammarVariants`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ImageApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ImageApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ImageContent.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ImageContent`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ImageModel.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ImageModel`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ImagesContext.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ImagesContext`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ImagesFunction.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ImagesFunction`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ImagesInputContent.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ImagesInputContent`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ImagesOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ImagesOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ImagesOutputContent.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ImagesOutputContent`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ImagesStopReason.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ImagesStopReason`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.JsonObject.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `JsonObject`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.JsonRepresentation.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `JsonRepresentation`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.JsonValue.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `JsonValue`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.KnownApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `KnownApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.KnownClassifierApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `KnownClassifierApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.KnownImageApi.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `KnownImageApi`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.KnownProvider.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `KnownProvider`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.Message.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `Message`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.Model.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `Model`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ModelType.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ModelType`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ModelTypeMap.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ModelTypeMap`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.NestedToolCallRecord.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `NestedToolCallRecord`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.NestedToolCalls.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `NestedToolCalls`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ProviderClassifier.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ProviderClassifier`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ProviderEnv.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ProviderEnv`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ProviderHeaders.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ProviderHeaders`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ProviderId.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ProviderId`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ProviderImages.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ProviderImages`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ProviderImagesOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ProviderImagesOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ProviderRequestOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ProviderRequestOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ProviderResponse.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ProviderResponse`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ProviderStreamOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ProviderStreamOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ProviderStreams.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ProviderStreams`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.SamplingParams.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `SamplingParams`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.SamplingParamsByThinkingLevel.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `SamplingParamsByThinkingLevel`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.SimpleStreamOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `SimpleStreamOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.StopReason.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `StopReason`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.StreamFunction.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `StreamFunction`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.StreamOptions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `StreamOptions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.SystemMessage.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `SystemMessage`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.TextContent.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `TextContent`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.TextSignatureV1.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `TextSignatureV1`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ThinkingBudgets.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ThinkingBudgets`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ThinkingContent.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ThinkingContent`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.Tool.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `Tool`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ToolCall.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ToolCall`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ToolChoice.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ToolChoice`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ToolReference.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ToolReference`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.ToolResultMessage.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `ToolResultMessage`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.TranscriptContext.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `TranscriptContext`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.Transport.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `Transport`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.Usage.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `Usage`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-types.ts.UserMessage.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/types.ts` → `UserMessage`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Type-level surface beyond the runtime subset the Dart port models in pi_agent/lib/src/types.dart.
- Issue: `##65`

### `ai.packages-ai-src-utils-diagnostics.ts.appendAssistantMessageDiagnostic.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/diagnostics.ts` → `appendAssistantMessageDiagnostic`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider diagnostics collection is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-diagnostics.ts.AssistantMessageDiagnostic.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/diagnostics.ts` → `AssistantMessageDiagnostic`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider diagnostics collection is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-diagnostics.ts.createAssistantMessageDiagnostic.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/diagnostics.ts` → `createAssistantMessageDiagnostic`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider diagnostics collection is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-diagnostics.ts.DiagnosticErrorInfo.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/diagnostics.ts` → `DiagnosticErrorInfo`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider diagnostics collection is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-diagnostics.ts.extractDiagnosticError.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/diagnostics.ts` → `extractDiagnosticError`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider diagnostics collection is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-diagnostics.ts.formatThrownValue.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/diagnostics.ts` → `formatThrownValue`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Provider diagnostics collection is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-identity.ts.withClientIdentity.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/identity.ts` → `withClientIdentity`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The withClientIdentity models wrapper is not ported: the Dart port has no Models facade to wrap.
- Issue: `##65`

### `ai.packages-ai-src-utils-json-parse.ts.parseStreamingJson.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/json-parse.ts` → `parseStreamingJson`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: The one-shot lax parse of partial JSON is not surfaced in Dart; the incremental machinery it shares is ported (StreamingJsonParser).
- Issue: `##65`

### `ai.packages-ai-src-utils-string-enum.ts.StringEnum.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/string-enum.ts` → `StringEnum`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: String-enum helpers are not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.collapseSystemMessages.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `collapseSystemMessages`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.createInitialSystemMessage.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `createInitialSystemMessage`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.declarationsEqual.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `declarationsEqual`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.getCurrentSystemMessage.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `getCurrentSystemMessage`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.getCurrentSystemPrompt.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `getCurrentSystemPrompt`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.getCurrentTools.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `getCurrentTools`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.getDeclaredTools.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `getDeclaredTools`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.getInitialSystemMessage.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `getInitialSystemMessage`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.getToolStateChanges.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `getToolStateChanges`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.hasNonAdditiveToolChanges.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `hasNonAdditiveToolChanges`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.hasToolRedefinitions.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `hasToolRedefinitions`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.normalizeContext.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `normalizeContext`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.resolveTranscript.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `resolveTranscript`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.resolveTranscriptTools.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `resolveTranscriptTools`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.ToolStateChanges.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `ToolStateChanges`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.toToolDeclaration.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `toToolDeclaration`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.TranscriptMessages.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `TranscriptMessages`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.TranscriptTools.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `TranscriptTools`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.TranscriptToolSupport.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `TranscriptToolSupport`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-transcript.ts.withoutInitialSystemMessage.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/transcript.ts` → `withoutInitialSystemMessage`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Transcript normalization (system collapsing, current-tool extraction) is not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-validation.ts.validateToolArguments.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/validation.ts` → `validateToolArguments`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Runtime validation helpers are not ported.
- Issue: `##65`

### `ai.packages-ai-src-utils-validation.ts.validateToolCall.api`

- Area: `ai`, kind: `api`
- Upstream: `packages/ai/src/utils/validation.ts` → `validateToolCall`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Runtime validation helpers are not ported.
- Issue: `##65`

### `ai.packages-ai-test-abort.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/abort.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-auth-token.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-auth-token.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-cache-write-1h-cost.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-cache-write-1h-cost.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-eager-tool-input-compat.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-eager-tool-input-compat.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-eager-tool-input-e2e.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-eager-tool-input-e2e.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-empty-thinking-signature-compat.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-empty-thinking-signature-compat.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-error-tool-result-images.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-error-tool-result-images.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-federation-sdk.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-federation-sdk.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-federation.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-federation.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-force-adaptive-thinking.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-force-adaptive-thinking.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-long-cache-retention-e2e.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-long-cache-retention-e2e.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-message-threads.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-message-threads.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-mid-conversation-effort.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-mid-conversation-effort.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-oauth.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-oauth.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-opus-4-8-smoke.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-opus-4-8-smoke.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-sse-parsing.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-sse-parsing.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-strict-tool-fallback.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-strict-tool-fallback.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-strict-tool-schema.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-strict-tool-schema.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-temperature-compat.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-temperature-compat.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-thinking-binding-e2e.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-thinking-binding-e2e.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-thinking-disable.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-thinking-disable.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-anthropic-tool-name-normalization.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/anthropic-tool-name-normalization.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-azure-models.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/azure-models.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-azure-openai-base-url.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/azure-openai-base-url.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-azure-openai-completions.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/azure-openai-completions.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-azure-openai-responses-reasoning-replay.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/azure-openai-responses-reasoning-replay.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-azure-openai-tool-choice.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/azure-openai-tool-choice.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-azure-utils.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/azure-utils.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-baseten-models.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/baseten-models.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-cache-write-1h-cost.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-cache-write-1h-cost.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-convert-messages.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-convert-messages.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-credentials.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-credentials.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-custom-headers.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-custom-headers.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-endpoint-resolution.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-endpoint-resolution.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-error-metadata.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-error-metadata.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-models.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-models.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-proxy-credentials.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-proxy-credentials.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-raw-stop-reason.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-raw-stop-reason.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-redacted-reasoning.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-redacted-reasoning.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-response-headers.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-response-headers.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-stream-state.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-stream-state.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-strict-tool-fallback.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-strict-tool-fallback.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-thinking-payload.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-thinking-payload.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-bedrock-utils.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/bedrock-utils.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-cache-retention.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/cache-retention.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-catalog-generation-utils.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/catalog-generation-utils.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-clamp-max-tokens.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/clamp-max-tokens.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-classifier-images-live.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/classifier-images-live.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-classifier-models.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/classifier-models.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-cloudflare-ai-binding.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/cloudflare-ai-binding.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-cloudflare-stream.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/cloudflare-stream.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-cloudflare-utils.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/cloudflare-utils.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-cloudflare-workers-ai-system-one.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/cloudflare-workers-ai-system-one.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-codex-websocket-cached-probe.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/codex-websocket-cached-probe.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-compat-env.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/compat-env.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-compat-schema.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/compat-schema.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-constrained-sampling.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/constrained-sampling.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-context-estimate.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/context-estimate.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-context-overflow.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/context-overflow.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-cross-provider-handoff.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/cross-provider-handoff.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-data-json-test-suite.json.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/data/json-test-suite.json`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-data-red-circle.png.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/data/red-circle.png`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-empty.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/empty.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-env-api-keys.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/env-api-keys.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-error-body.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/error-body.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-event-stream.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/event-stream.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-faux-provider.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/faux-provider.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-fetch-option.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/fetch-option.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-fireworks-model-generation.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/fireworks-model-generation.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-fireworks-models.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/fireworks-models.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-github-copilot-anthropic.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/github-copilot-anthropic.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-github-copilot-oauth.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/github-copilot-oauth.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-github-copilot-request-size-overflow.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/github-copilot-request-size-overflow.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-google-raw-stop-reason.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/google-raw-stop-reason.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-google-shared-convert-tools.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/google-shared-convert-tools.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-google-shared-gemini3-unsigned-tool-call.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/google-shared-gemini3-unsigned-tool-call.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-google-shared-image-tool-result-routing.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/google-shared-image-tool-result-routing.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-google-shared-retry.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/google-shared-retry.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-google-shared-signed-empty-blocks.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/google-shared-signed-empty-blocks.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-google-stop-reason-continuation.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/google-stop-reason-continuation.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-google-thinking-disable.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/google-thinking-disable.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-google-thinking-level-map.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/google-thinking-level-map.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-google-thinking-signature.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/google-thinking-signature.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-google-vertex-api-key-resolution.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/google-vertex-api-key-resolution.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-identity.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/identity.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-image-model-data.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/image-model-data.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-image-tool-result.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/image-tool-result.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-images-models.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/images-models.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-images.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/images.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-interleaved-thinking.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/interleaved-thinking.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-json-parse.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/json-parse.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-kimi-coding-oauth.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/kimi-coding-oauth.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-lax-message-content.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/lax-message-content.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-lazy-module-load.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/lazy-module-load.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-llama-cpp-classify.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/llama-cpp-classify.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-max-thinking.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/max-thinking.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-memory-helpers.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/memory-helpers.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-message-types.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/message-types.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-meta-oauth.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/meta-oauth.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-mistral-http-transport.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/mistral-http-transport.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-mistral-raw-stop-reason.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/mistral-raw-stop-reason.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-mistral-reasoning-mode.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/mistral-reasoning-mode.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-mistral-tool-schema.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/mistral-tool-schema.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-model-catalog-types.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/model-catalog-types.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-model-cost-tiers.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/model-cost-tiers.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-model-data-validation.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/model-data-validation.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-model-types.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/model-types.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-models-entry.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/models-entry.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-models-runtime.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/models-runtime.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-node-http-proxy.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/node-http-proxy.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-oauth-auth.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/oauth-auth.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-oauth-callback-server.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/oauth-callback-server.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-oauth-device-code.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/oauth-device-code.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-oauth.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/oauth.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-chatgpt-oauth.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-chatgpt-oauth.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-codex-cache-affinity-e2e.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-codex-cache-affinity-e2e.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-codex-oauth.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-codex-oauth.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-codex-stream.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-codex-stream.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-completions-cache-control-format.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-completions-cache-control-format.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-completions-empty-tools.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-completions-empty-tools.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-completions-non-null-assistant-content.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-completions-non-null-assistant-content.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-completions-prompt-cache.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-completions-prompt-cache.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-completions-provider-stream-event.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-completions-provider-stream-event.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-completions-raw-stop-reason.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-completions-raw-stop-reason.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-completions-reasoning-details.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-completions-reasoning-details.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-completions-response-model.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-completions-response-model.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-completions-retry.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-completions-retry.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-completions-thinking-as-text.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-completions-thinking-as-text.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-completions-thinking-token-budget.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-completions-thinking-token-budget.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-completions-tool-choice.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-completions-tool-choice.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-completions-tool-result-images.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-completions-tool-result-images.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-completions-vllm-priority.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-completions-vllm-priority.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-decisions.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-decisions.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-reasoning-replay-e2e.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-reasoning-replay-e2e.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-cache-affinity-e2e.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-cache-affinity-e2e.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-chatgpt-sign-in.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-chatgpt-sign-in.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-compat.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-compat.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-empty-tool-result.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-empty-tool-result.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-foreign-toolcall-id.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-foreign-toolcall-id.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-input-transformations.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-input-transformations.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-message-id.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-message-id.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-mid-convo-effort.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-mid-convo-effort.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-namespace.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-namespace.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-partial-json-cleanup.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-partial-json-cleanup.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-prompt-cache.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-prompt-cache.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-reasoning-replay-e2e.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-reasoning-replay-e2e.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-terminal-event.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-terminal-event.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-tool-result-images.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-tool-result-images.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openai-responses-usage-limit.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openai-responses-usage-limit.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-opencode-model-generation.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/opencode-model-generation.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-opencode-provider-headers.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/opencode-provider-headers.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openrouter-cache-write-repro.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openrouter-cache-write-repro.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openrouter-cost.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openrouter-cost.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openrouter-images.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openrouter-images.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openrouter-oauth.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openrouter-oauth.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openrouter-reasoning-options.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openrouter-reasoning-options.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-openrouter-user-models.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/openrouter-user-models.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-overflow.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/overflow.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-pi-messages.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/pi-messages.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-pre-generation-error.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/pre-generation-error.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-provider-error-body-passthrough.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/provider-error-body-passthrough.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-provider-error-body-regression.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/provider-error-body-regression.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-provider-retry.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/provider-retry.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-providers.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/providers.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-qwen-token-plan-models.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/qwen-token-plan-models.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-radius-oauth.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/radius-oauth.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-radius-provider.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/radius-provider.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-radius-thinking-replay-e2e.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/radius-thinking-replay-e2e.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-reasoning-options.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/reasoning-options.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-responseid.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/responseid.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-retry.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/retry.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-sampling-options.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/sampling-options.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-scratch.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/scratch.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-stream.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/stream.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-streaming-json.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/streaming-json.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-streaming-tool-arguments.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/streaming-tool-arguments.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-strict-tool-limits.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/strict-tool-limits.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-supports-xhigh.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/supports-xhigh.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-system-message-replay.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/system-message-replay.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-telemetry-options.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/telemetry-options.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-telemetry.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/telemetry.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-text.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/text.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-together-models.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/together-models.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-tokens.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/tokens.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-tool-call-id-normalization.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/tool-call-id-normalization.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-tool-call-without-result.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/tool-call-without-result.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-total-tokens.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/total-tokens.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-transcript-tool-changes.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/transcript-tool-changes.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-transform-messages-copilot-openai-to-anthropic.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/transform-messages-copilot-openai-to-anthropic.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-transform-messages-cross-model-thinking.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/transform-messages-cross-model-thinking.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-typesafe-system-one.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/typesafe-system-one.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-unicode-surrogate.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/unicode-surrogate.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-uuid.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/uuid.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-validation-probes.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/validation-probes.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-validation.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/validation.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-xai-oauth.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/xai-oauth.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-xai-responses.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/xai-responses.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-xhigh.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/xhigh.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-xiaomi-models.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/xiaomi-models.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-xiaomi-token-plan-ams-anthropic-empty-signature-smoke.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/xiaomi-token-plan-ams-anthropic-empty-signature-smoke.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-zai-coding-plan-models.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/zai-coding-plan-models.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `ai.packages-ai-test-zen.test.ts.internal.test`

- Area: `ai`, kind: `test`
- Upstream: `packages/ai/test/zen.test.ts`
- Dart: `pi_agent/lib/src/llm_client.dart`
- Divergence: Upstream test behaviors not yet mirrored in the Dart suite; each lands with the slice that ports them.
- Issue: `##65`

### `agent.packages-agent-examples-mcp-codemode-main.ts.internal.example`

- Area: `agent`, kind: `example`
- Upstream: `packages/agent/examples/mcp-codemode/main.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Example (examples/mcp-codemode/main.ts) is not ported; examples are out of the Dart package surface. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-examples-mcp-codemode-tools.ts.internal.example`

- Area: `agent`, kind: `example`
- Upstream: `packages/agent/examples/mcp-codemode/tools.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Example (examples/mcp-codemode/tools.ts) is not ported; examples are out of the Dart package surface. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-agent-loop.ts.AgentEventSink.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/agent-loop.ts` → `AgentEventSink`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: AgentEventSink is not a Dart export; the loop emits AgentEvent through a stream, not a sink interface. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-agent-loop.ts.DEFAULT_AGENT_IDENTITY.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/agent-loop.ts` → `DEFAULT_AGENT_IDENTITY`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: DEFAULT_AGENT_IDENTITY has no Dart equivalent; the port sets identity per request via client identity utils. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-agent-loop.ts.RunToolCallOptions.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/agent-loop.ts` → `RunToolCallOptions`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: RunToolCallOptions is not modeled; runToolCall takes explicit parameters in the port. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-agent-loop.ts.ToolCallHooks.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/agent-loop.ts` → `ToolCallHooks`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: ToolCallHooks is not a named Dart type; beforeToolCall/afterToolCall are passed on AgentLoopConfig. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-agent.ts.AgentInitialState.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/agent.ts` → `AgentInitialState`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: AgentInitialState is not ported; AgentState carries the initial state directly. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-index.ts.setDefaultStreamFn.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/index.ts` → `setDefaultStreamFn`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: setDefaultStreamFn (a global default) is not ported; the stream fn is wired per Agent. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-proxy.ts.ProxyAssistantMessageEvent.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/proxy.ts` → `ProxyAssistantMessageEvent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: proxy.ts stream adapter is not ported to Dart. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-proxy.ts.ProxyStreamOptions.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/proxy.ts` → `ProxyStreamOptions`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: proxy.ts stream adapter is not ported to Dart. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-proxy.ts.streamProxy.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/proxy.ts` → `streamProxy`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: proxy.ts stream adapter is not ported to Dart. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-types.ts.AgentLoopTurnUpdate.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/types.ts` → `AgentLoopTurnUpdate`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: AgentLoopTurnUpdate is not ported; turn updates are AgentEvent variants. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-types.ts.AgentRequestUpdate.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/types.ts` → `AgentRequestUpdate`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: AgentRequestUpdate is not ported; the port has no request-update streaming type. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-types.ts.AgentToolCall.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/types.ts` → `AgentToolCall`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: AgentToolCall (TS tool-call shape) is not ported; the port uses ToolCallBlock. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-types.ts.AgentToolCallOutcome.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/types.ts` → `AgentToolCallOutcome`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: AgentToolCallOutcome is not ported; the loop uses an internal finalized-call record. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-types.ts.AgentToolParams.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/types.ts` → `AgentToolParams`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: AgentToolParams is not ported; tool parameters are a plain JSON map. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-types.ts.AgentToolUpdateCallback.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/types.ts` → `AgentToolUpdateCallback`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: AgentToolUpdateCallback is not a named Dart type; onUpdate is a closure parameter. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-types.ts.AgentTurnContext.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/types.ts` → `AgentTurnContext`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: AgentTurnContext is not ported; the loop passes ShouldStopAfterTurnContext instead. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-types.ts.AgentTurnDecision.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/types.ts` → `AgentTurnDecision`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: AgentTurnDecision is not ported; turn continuation is decided by the loop, not a returned decision. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-types.ts.CustomAgentMessages.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/types.ts` → `CustomAgentMessages`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: CustomAgentMessages is not ported; the port has a CustomMessage agent message. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-types.ts.FinishTurn.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/types.ts` → `FinishTurn`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: FinishTurn is not ported; the loop ends a turn on a terminal stop reason. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-types.ts.PrepareNextTurnContext.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/types.ts` → `PrepareNextTurnContext`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: PrepareNextTurnContext is not ported; the loop has no prepare-next-turn hook. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-types.ts.PrepareRequest.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/types.ts` → `PrepareRequest`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: PrepareRequest is not ported; the loop builds the request from AgentContext directly. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-types.ts.PrepareRequestContext.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/types.ts` → `PrepareRequestContext`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: PrepareRequestContext is not ported with PrepareRequest. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-src-types.ts.StreamFn.api`

- Area: `agent`, kind: `api`
- Upstream: `packages/agent/src/types.ts` → `StreamFn`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: StreamFn (TS provider stream signature) is not a named Dart type; the port uses LoopStreamFn. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-test-proxy.test.ts.internal.test`

- Area: `agent`, kind: `test`
- Upstream: `packages/agent/test/proxy.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: proxy.test.ts has no Dart counterpart; the proxy stream adapter is not ported. Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-test-utils-calculate.ts.internal.test`

- Area: `agent`, kind: `test`
- Upstream: `packages/agent/test/utils/calculate.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Test helper utils/calculate.ts is not ported (Dart tests compute inline). Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-test-utils-get-current-time.ts.internal.test`

- Area: `agent`, kind: `test`
- Upstream: `packages/agent/test/utils/get-current-time.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Test helper utils/get-current-time.ts is not ported (Dart tests use a virtual clock). Tracked in #71.
- Issue: `##71`

### `agent.packages-agent-test-utils-wait-for-tick.ts.internal.test`

- Area: `agent`, kind: `test`
- Upstream: `packages/agent/test/utils/wait-for-tick.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Test helper utils/wait-for-tick.ts is not ported (Dart tests await microtasks directly). Tracked in #71.
- Issue: `##71`

### `durable.packages-durable-src-codemode-index.ts.DEFAULT_CODEMODE_INLINE_BUDGET.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/codemode/index.ts` → `DEFAULT_CODEMODE_INLINE_BUDGET`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-codemode-index.ts.namespacesOf.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/codemode/index.ts` → `namespacesOf`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-documents.ts.defineDoc.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/documents.ts` → `defineDoc`
- Dart: `pi_agent/lib/src/durable/entries.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-documents.ts.defineDocFamily.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/documents.ts` → `defineDocFamily`
- Dart: `pi_agent/lib/src/durable/entries.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-entries.ts.AssistantEntry.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/entries.ts` → `AssistantEntry`
- Dart: `pi_agent/lib/src/durable/entries.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-entries.ts.CompactionEntry.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/entries.ts` → `CompactionEntry`
- Dart: `pi_agent/lib/src/durable/entries.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-entries.ts.defineEntry.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/entries.ts` → `defineEntry`
- Dart: `pi_agent/lib/src/durable/entries.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-entries.ts.ResetEntry.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/entries.ts` → `ResetEntry`
- Dart: `pi_agent/lib/src/durable/entries.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-entries.ts.SystemEntry.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/entries.ts` → `SystemEntry`
- Dart: `pi_agent/lib/src/durable/entries.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-entries.ts.ToolResultEntry.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/entries.ts` → `ToolResultEntry`
- Dart: `pi_agent/lib/src/durable/entries.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-entries.ts.UserEntry.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/entries.ts` → `UserEntry`
- Dart: `pi_agent/lib/src/durable/entries.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-errors.ts.errorMessage.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/errors.ts` → `errorMessage`
- Dart: `pi_agent/lib/src/durable/errors.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-errors.ts.ReadAfterWrite.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/errors.ts` → `ReadAfterWrite`
- Dart: `pi_agent/lib/src/durable/errors.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-errors.ts.SessionFailed.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/errors.ts` → `SessionFailed`
- Dart: `pi_agent/lib/src/durable/errors.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-errors.ts.StorageRequestError.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/errors.ts` → `StorageRequestError`
- Dart: `pi_agent/lib/src/durable/errors.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-ids.ts.idFromNumber.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/ids.ts` → `idFromNumber`
- Dart: `pi_agent/lib/src/chord/ids.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-ids.ts.seqFromNumber.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/ids.ts` → `seqFromNumber`
- Dart: `pi_agent/lib/src/chord/ids.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-images-cloudflare.ts.createCloudflarePhotonImages.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/images/cloudflare.ts` → `createCloudflarePhotonImages`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-images-fit.ts.createFitImagesExtension.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/images/fit.ts` → `createFitImagesExtension`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-images-fit.ts.fitImage.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/images/fit.ts` → `fitImage`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-images-fit.ts.fitImages.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/images/fit.ts` → `fitImages`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-images-fit.ts.FittedImage.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/images/fit.ts` → `FittedImage`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-images-fit.ts.FittedImages.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/images/fit.ts` → `FittedImages`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-images-index.ts.createPhotonImages.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/images/index.ts` → `createPhotonImages`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-images-node.ts.createNodePhotonImages.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/images/node.ts` → `createNodePhotonImages`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-images-node.ts.NodePhotonImagesOptions.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/images/node.ts` → `NodePhotonImagesOptions`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.BlockedReason.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `BlockedReason`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.ConversationView.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `ConversationView`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.ConversationWindow.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `ConversationWindow`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.createRegistry.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `createRegistry`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.createSession.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `createSession`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.DEFAULT_HARNESS_IDENTITY.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `DEFAULT_HARNESS_IDENTITY`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.defineDoc.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `defineDoc`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.defineDocFamily.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `defineDocFamily`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.defineExtension.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `defineExtension`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.defineTask.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `defineTask`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.defineTool.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `defineTool`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.DURABLE_TELEMETRY_SCHEMA.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `DURABLE_TELEMETRY_SCHEMA`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.Harness.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `Harness`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.hook.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `hook`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.hookTask.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `hookTask`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.InboxDoc.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `InboxDoc`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.MemoryStorage.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `MemoryStorage`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.NativeWatchCall.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `NativeWatchCall`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.ProviderDoc.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `ProviderDoc`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.registryReader.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `registryReader`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.ROOT_CONVERSATION_ID.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `ROOT_CONVERSATION_ID`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.section.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `section`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.TaskGraph.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `TaskGraph`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.TaskGraphNode.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `TaskGraphNode`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.TaskGraphState.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `TaskGraphState`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.TaskGraphWatch.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `TaskGraphWatch`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.UsageDoc.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `UsageDoc`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.WatchCall.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `WatchCall`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.WatchEnd.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `WatchEnd`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.WatchHandle.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `WatchHandle`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.wrapSection.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `wrapSection`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-index.ts.wrapTool.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/index.ts` → `wrapTool`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-indexeddb.ts.IndexedDbStorage.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/indexeddb.ts` → `IndexedDbStorage`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-indexeddb.ts.IndexedDbStorageOptions.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/indexeddb.ts` → `IndexedDbStorageOptions`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-jsonl-index.ts.internal.internal`

- Area: `durable`, kind: `internal`
- Upstream: `packages/durable/src/storage/jsonl/index.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-jsonl-node.ts.JsonlStorage.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/jsonl/node.ts` → `JsonlStorage`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-jsonl-node.ts.JsonlStorageReadOnlyError.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/jsonl/node.ts` → `JsonlStorageReadOnlyError`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-jsonl-node.ts.openNodeJsonlStorage.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/jsonl/node.ts` → `openNodeJsonlStorage`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-memory.ts.MemoryStorage.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/memory.ts` → `MemoryStorage`
- Dart: `pi_agent/lib/src/durable/storage/memory.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-memory.ts.PreparedMemoryCommit.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/memory.ts` → `PreparedMemoryCommit`
- Dart: `pi_agent/lib/src/durable/storage/memory.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-scan.ts.nextCursor.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/scan.ts` → `nextCursor`
- Dart: `pi_agent/lib/src/durable/storage/storage.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-scan.ts.scanStart.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/scan.ts` → `scanStart`
- Dart: `pi_agent/lib/src/durable/storage/storage.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-sqlite-cloudflare.ts.DurableObjectSqliteDatabase.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/sqlite/cloudflare.ts` → `DurableObjectSqliteDatabase`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-sqlite-cloudflare.ts.openDurableObjectSqliteStorage.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/sqlite/cloudflare.ts` → `openDurableObjectSqliteStorage`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-sqlite-index.ts.SqliteDatabase.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/sqlite/index.ts` → `SqliteDatabase`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-sqlite-index.ts.SqliteExecutor.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/sqlite/index.ts` → `SqliteExecutor`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-sqlite-index.ts.SqliteStorage.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/sqlite/index.ts` → `SqliteStorage`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-sqlite-index.ts.SqliteValue.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/sqlite/index.ts` → `SqliteValue`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-sqlite-node.ts.NodeSqliteStorageOptions.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/sqlite/node.ts` → `NodeSqliteStorageOptions`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-sqlite-node.ts.openNodeSqliteStorage.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/sqlite/node.ts` → `openNodeSqliteStorage`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-storage-store-index.ts.StoreStorage.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/storage/store/index.ts` → `StoreStorage`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-testing-index.ts.commitWrites.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/testing/index.ts` → `commitWrites`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-testing-index.ts.createEnvConformance.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/testing/index.ts` → `createEnvConformance`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-testing-index.ts.createExpectAssertions.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/testing/index.ts` → `createExpectAssertions`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-testing-index.ts.createStorageConformance.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/testing/index.ts` → `createStorageConformance`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-testing-index.ts.registerEnvConformance.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/testing/index.ts` → `registerEnvConformance`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-testing-index.ts.registerStorageConformance.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/testing/index.ts` → `registerStorageConformance`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-testing-storage-conformance.ts.createStorageConformance.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/testing/storage-conformance.ts` → `createStorageConformance`
- Dart: `pi_agent/lib/src/durable/storage/conformance.dart`
- Divergence: Ported by pi#11 (spec 003 foundation slice). Evidence: the upstream-derived tests named in `dart_test`; no differential scenario pins this behavior against the TypeScript oracle yet, so the row is `implemented_unverified`, not `verified`.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-tool-search-index.ts.internal.internal`

- Area: `durable`, kind: `internal`
- Upstream: `packages/durable/src/tool-search/index.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-tools-index.ts.CodingTools.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/tools/index.ts` → `CodingTools`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-tools-index.ts.createCodingTools.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/tools/index.ts` → `createCodingTools`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-tools-index.ts.createEditTool.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/tools/index.ts` → `createEditTool`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-tools-index.ts.createReadTool.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/tools/index.ts` → `createReadTool`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-src-tools-index.ts.createWriteTool.api`

- Area: `durable`, kind: `api`
- Upstream: `packages/durable/src/tools/index.ts` → `createWriteTool`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-chat-support.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/chat-support.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-codemode-bench.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/codemode-bench.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-codemode-checkpoints.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/codemode-checkpoints.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-codemode-describe.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/codemode-describe.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-codemode-imports.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/codemode-imports.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-codemode-models.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/codemode-models.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-codemode.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/codemode.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-conversation-transcript.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/conversation-transcript.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-conversation-view-bench.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/conversation-view-bench.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-document-append-bench.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/document-append-bench.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-env-node-conformance.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/env-node-conformance.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-env-node-list-race.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/env-node-list-race.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-env-node-spill.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/env-node-spill.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-env-node.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/env-node.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-env-truncate.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/env-truncate.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-00-conversation.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/00-conversation.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-01-documents.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/01-documents.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-02-forks.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/02-forks.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-03-owned-conversations.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/03-owned-conversations.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-04-watches.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/04-watches.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-05-harness.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/05-harness.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-06-configuration.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/06-configuration.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-07-harness-conversations.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/07-harness-conversations.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-08-context.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/08-context.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-09-registry-reload.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/09-registry-reload.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-10-extension-state.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/10-extension-state.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-11-tasks.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/11-tasks.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-12-recovery.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/12-recovery.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-13-chat.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/13-chat.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-14-system-prompt.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/14-system-prompt.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-15-real-model.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/15-real-model.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-16-coding-tools.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/16-coding-tools.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-17-print.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/17-print.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-18-json.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/18-json.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-19-inbox.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/19-inbox.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-20-late-join.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/20-late-join.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-21-subagent-foreground.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/21-subagent-foreground.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-22-subagent-background.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/22-subagent-background.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-23-child-tasks.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/23-child-tasks.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-24-compaction.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/24-compaction.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-25-coding-agent.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/25-coding-agent.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-26-plan-mode.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/26-plan-mode.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-27-reviewer.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/27-reviewer.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-28-sandbox-per-conversation.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/28-sandbox-per-conversation.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-29-tool-override.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/29-tool-override.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-30-reload-and-restart.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/30-reload-and-restart.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-31-transcript.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/31-transcript.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-32-tests-after-edits.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/32-tests-after-edits.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-33-turn-limit-and-continue.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/33-turn-limit-and-continue.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-34-submit-in-commit.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/34-submit-in-commit.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-35-durable-on-the-store.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/35-durable-on-the-store.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-36-durable-views.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/36-durable-views.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-37-harness-registry.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/37-harness-registry.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-38-signals.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/38-signals.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-39-ask-a-person.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/39-ask-a-person.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-40-tool-waits-for-webhook.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/40-tool-waits-for-webhook.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-41-tool-polls.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/41-tool-polls.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-42-parallel-children.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/42-parallel-children.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-43-subagent-waits.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/43-subagent-waits.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-44-approval-gate.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/44-approval-gate.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-45-review-on-yield.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/45-review-on-yield.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-46-after-tools-terminate.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/46-after-tools-terminate.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-examples-47-fit-images.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/examples/47-fit-images.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-fixtures-delete-buffer.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/fixtures/delete-buffer.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-fixtures-utf8-byte-length-without-buffer.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/fixtures/utf8-byte-length-without-buffer.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-after-run.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-after-run.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-blocked.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-blocked.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-callers.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-callers.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-cancellation-barrier.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-cancellation-barrier.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-compaction.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-compaction.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-context-range.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-context-range.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-context.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-context.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-continue.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-continue.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-conversations.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-conversations.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-deferred-progress.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-deferred-progress.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-failed-run-inbox.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-failed-run-inbox.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-generation-recovery.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-generation-recovery.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-generation.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-generation.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-group-commit.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-group-commit.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-hook-reads.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-hook-reads.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-hook-tasks.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-hook-tasks.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-host-inputs.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-host-inputs.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-idle-scopes.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-idle-scopes.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-inbox.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-inbox.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-input-entries.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-input-entries.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-inspect.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-inspect.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-json.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-json.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-lifecycle.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-lifecycle.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-live-deltas.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-live-deltas.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-nested-tools-restart.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-nested-tools-restart.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-nested-tools.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-nested-tools.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-observers.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-observers.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-ownership.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-ownership.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-park-children.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-park-children.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-partial-changes.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-partial-changes.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-prompt.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-prompt.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-read-only.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-read-only.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-registry-reader.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-registry-reader.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-registry.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-registry.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-reports.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-reports.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-restart-failure.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-restart-failure.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-run-failure.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-run-failure.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-scheduler-indexes.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-scheduler-indexes.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-scheduler-retention.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-scheduler-retention.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-signals.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-signals.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-sleep.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-sleep.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-storage-failure.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-storage-failure.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-structured-output.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-structured-output.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-structured.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-structured.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-submissions.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-submissions.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-submit-in-commit.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-submit-in-commit.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-support.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-support.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-task-graph.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-task-graph.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-tasks-recovery.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-tasks-recovery.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-tasks.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-tasks.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-telemetry-options.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-telemetry-options.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-telemetry.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-telemetry.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-tool-gates.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-tool-gates.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-tool-hooks.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-tool-hooks.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-tool-parks.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-tool-parks.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-tools-recovery.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-tools-recovery.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-tools.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-tools.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-turn-limit.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-turn-limit.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-view-run.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-view-run.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-harness-view.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/harness-view.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-heap-retained.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/heap-retained.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-image-fixtures.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/image-fixtures.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-images-fit.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/images-fit.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-images-wasm-module.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/images-wasm-module.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-indexeddb-storage.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/indexeddb-storage.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-jsonl-storage.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/jsonl-storage.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-live-support.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/live-support.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-memory-storage.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/memory-storage.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-nested-images-bench.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/nested-images-bench.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-nested-tools-bench.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/nested-tools-bench.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-provider-session-cache-e2e.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/provider-session-cache-e2e.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-scheduler-fanout-bench.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/scheduler-fanout-bench.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-scheduler-memory-bench.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/scheduler-memory-bench.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-search.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/search.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-adoption.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-adoption.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-cached-storage.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-cached-storage.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-checkpoints-migrations.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-checkpoints-migrations.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-conversation-tails.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-conversation-tails.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-deferred-commits.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-deferred-commits.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-definitions.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-definitions.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-document-cache-bench.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-document-cache-bench.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-document-retention.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-document-retention.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-documents.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-documents.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-forks.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-forks.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-group-commit.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-group-commit.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-observers.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-observers.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-support.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-support.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-tables.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-tables.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-session-watches.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/session-watches.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-setup-document-retention.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/setup-document-retention.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-spec-usage.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/spec-usage.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-sqlite-cloudflare.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/sqlite-cloudflare.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-sqlite-commit.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/sqlite-commit.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-sqlite-facade.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/sqlite-facade.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-sqlite-migrations.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/sqlite-migrations.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-sqlite-storage.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/sqlite-storage.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-storage-memory.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/storage-memory.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-storage-runtime-boundary.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/storage-runtime-boundary.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-storage.bench.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/storage.bench.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-store-storage-commit.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/store-storage-commit.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-store-storage-node.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/store-storage-node.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-store-storage-support.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/store-storage-support.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-store-storage.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/store-storage.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-system-order-cache-e2e.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/system-order-cache-e2e.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-task-support.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/task-support.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-tool-args-typebox.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/tool-args-typebox.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-tool-output-bench.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/tool-output-bench.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-tool-search.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/tool-search.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-tools-images.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/tools-images.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-tools-read-differential.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/tools-read-differential.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-tools.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/tools.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `durable.packages-durable-test-types.test.ts.internal.test`

- Area: `durable`, kind: `test`
- Upstream: `packages/durable/test/types.test.ts`
- Dart: `pi_agent/lib/src/session.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#80`

### `codemode.packages-codemode-examples-cloudflare-agent-src-index.ts.internal.example`

- Area: `codemode`, kind: `example`
- Upstream: `packages/codemode/examples/cloudflare/agent/src/index.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-examples-cloudflare-agent-wrangler.jsonc.internal.example`

- Area: `codemode`, kind: `example`
- Upstream: `packages/codemode/examples/cloudflare/agent/wrangler.jsonc`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-examples-cloudflare-readme.md.internal.example`

- Area: `codemode`, kind: `example`
- Upstream: `packages/codemode/examples/cloudflare/README.md`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-examples-cloudflare-sandbox-src-index.ts.internal.example`

- Area: `codemode`, kind: `example`
- Upstream: `packages/codemode/examples/cloudflare/sandbox/src/index.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-examples-cloudflare-sandbox-wrangler.jsonc.internal.example`

- Area: `codemode`, kind: `example`
- Upstream: `packages/codemode/examples/cloudflare/sandbox/wrangler.jsonc`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-cloudflare.ts.cloudflareQuickJSWasm.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/cloudflare.ts` → `cloudflareQuickJSWasm`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-cloudflare.ts.CodemodeSandboxDurableObject.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/cloudflare.ts` → `CodemodeSandboxDurableObject`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-cloudflare.ts.createInlineCodemodeSandbox.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/cloudflare.ts` → `createInlineCodemodeSandbox`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-cloudflare.ts.DEFAULT_REMOTE_MEMORY_LIMIT_BYTES.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/cloudflare.ts` → `DEFAULT_REMOTE_MEMORY_LIMIT_BYTES`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-declarations.ts.DEFAULT_INPUT_SCHEMA_MAX_CHARS.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/declarations.ts` → `DEFAULT_INPUT_SCHEMA_MAX_CHARS`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-declarations.ts.renderDeclarations.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/declarations.ts` → `renderDeclarations`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-declarations.ts.RenderDeclarationsOptions.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/declarations.ts` → `RenderDeclarationsOptions`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-declarations.ts.renderToolOutputType.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/declarations.ts` → `renderToolOutputType`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-declarations.ts.renderToolSample.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/declarations.ts` → `renderToolSample`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-declarations.ts.renderToolSignature.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/declarations.ts` → `renderToolSignature`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-declarations.ts.resolveSchemaRef.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/declarations.ts` → `resolveSchemaRef`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-declarations.ts.schemaToType.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/declarations.ts` → `schemaToType`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-declarations.ts.toCodemodeIdentifier.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/declarations.ts` → `toCodemodeIdentifier`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-index.ts.CodemodeSandbox.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/index.ts` → `CodemodeSandbox`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-index.ts.CodemodeSandboxBase.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/index.ts` → `CodemodeSandboxBase`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-index.ts.loadQuickJSWasm.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/index.ts` → `loadQuickJSWasm`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-portable.ts.CodemodeWasmModule.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/portable.ts` → `CodemodeWasmModule`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-portable.ts.HostToWorkerMessage.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/portable.ts` → `HostToWorkerMessage`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-portable.ts.VmStartData.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/portable.ts` → `VmStartData`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-portable.ts.WorkerToHostMessage.api`

- Area: `codemode`, kind: `api`
- Upstream: `packages/codemode/src/portable.ts` → `WorkerToHostMessage`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-src-runtime-worker.ts.internal.internal`

- Area: `codemode`, kind: `internal`
- Upstream: `packages/codemode/src/runtime/worker.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-test-declarations.test.ts.internal.test`

- Area: `codemode`, kind: `test`
- Upstream: `packages/codemode/test/declarations.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-test-deterministic.test.ts.internal.test`

- Area: `codemode`, kind: `test`
- Upstream: `packages/codemode/test/deterministic.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-test-fixtures-raw-worker.ts.internal.test`

- Area: `codemode`, kind: `test`
- Upstream: `packages/codemode/test/fixtures/raw-worker.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-test-fixtures-worker-process-exit.ts.internal.test`

- Area: `codemode`, kind: `test`
- Upstream: `packages/codemode/test/fixtures/worker-process-exit.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-test-portable.test.ts.internal.test`

- Area: `codemode`, kind: `test`
- Upstream: `packages/codemode/test/portable.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-test-sandbox.test.ts.internal.test`

- Area: `codemode`, kind: `test`
- Upstream: `packages/codemode/test/sandbox.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `codemode.packages-codemode-test-worker-lifetime.test.ts.internal.test`

- Area: `codemode`, kind: `test`
- Upstream: `packages/codemode/test/worker-lifetime.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#84`

### `env.packages-env-src-index.ts.LocalExecutionEnv.api`

- Area: `env`, kind: `api`
- Upstream: `packages/env/src/index.ts` → `LocalExecutionEnv`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-src-index.ts.openProcess.api`

- Area: `env`, kind: `api`
- Upstream: `packages/env/src/index.ts` → `openProcess`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-src-index.ts.openTerminal.api`

- Area: `env`, kind: `api`
- Upstream: `packages/env/src/index.ts` → `openTerminal`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-src-index.ts.RemoteExecutionEnv.api`

- Area: `env`, kind: `api`
- Upstream: `packages/env/src/index.ts` → `RemoteExecutionEnv`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-src-index.ts.RemoteProcess.api`

- Area: `env`, kind: `api`
- Upstream: `packages/env/src/index.ts` → `RemoteProcess`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-src-index.ts.RemoteTerminal.api`

- Area: `env`, kind: `api`
- Upstream: `packages/env/src/index.ts` → `RemoteTerminal`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-src-index.ts.RemoteWatcher.api`

- Area: `env`, kind: `api`
- Upstream: `packages/env/src/index.ts` → `RemoteWatcher`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-test-build-daemon.ts.internal.test`

- Area: `env`, kind: `test`
- Upstream: `packages/env/test/build-daemon.ts`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-test-conformance.test.ts.internal.test`

- Area: `env`, kind: `test`
- Upstream: `packages/env/test/conformance.test.ts`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-test-connection.test.ts.internal.test`

- Area: `env`, kind: `test`
- Upstream: `packages/env/test/connection.test.ts`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-test-daemon.ts.internal.test`

- Area: `env`, kind: `test`
- Upstream: `packages/env/test/daemon.ts`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-test-differential.test.ts.internal.test`

- Area: `env`, kind: `test`
- Upstream: `packages/env/test/differential.test.ts`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-test-old-daemon.ts.internal.test`

- Area: `env`, kind: `test`
- Upstream: `packages/env/test/old-daemon.ts`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-test-process.test.ts.internal.test`

- Area: `env`, kind: `test`
- Upstream: `packages/env/test/process.test.ts`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-test-remote-abort.test.ts.internal.test`

- Area: `env`, kind: `test`
- Upstream: `packages/env/test/remote-abort.test.ts`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-test-remote.test.ts.internal.test`

- Area: `env`, kind: `test`
- Upstream: `packages/env/test/remote.test.ts`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-test-ssh-external.test.ts.internal.test`

- Area: `env`, kind: `test`
- Upstream: `packages/env/test/ssh-external.test.ts`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-test-ssh.test.ts.internal.test`

- Area: `env`, kind: `test`
- Upstream: `packages/env/test/ssh.test.ts`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `env.packages-env-test-terminal.test.ts.internal.test`

- Area: `env`, kind: `test`
- Upstream: `packages/env/test/terminal.test.ts`
- Dart: `pi_agent/lib/src/execution_env.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#85`

### `mcp.packages-mcp-src-index.ts.AuthProvider.api`

- Area: `mcp`, kind: `api`
- Upstream: `packages/mcp/src/index.ts` → `AuthProvider`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-src-index.ts.McpClient.api`

- Area: `mcp`, kind: `api`
- Upstream: `packages/mcp/src/index.ts` → `McpClient`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-src-index.ts.McpFetch.api`

- Area: `mcp`, kind: `api`
- Upstream: `packages/mcp/src/index.ts` → `McpFetch`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-src-index.ts.StdioTransport.api`

- Area: `mcp`, kind: `api`
- Upstream: `packages/mcp/src/index.ts` → `StdioTransport`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-src-index.ts.UnauthorizedContext.api`

- Area: `mcp`, kind: `api`
- Upstream: `packages/mcp/src/index.ts` → `UnauthorizedContext`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-src-oauth-index.ts.createMcpAuthProvider.api`

- Area: `mcp`, kind: `api`
- Upstream: `packages/mcp/src/oauth/index.ts` → `createMcpAuthProvider`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-src-testing-index.ts.createInMemoryTransportPair.api`

- Area: `mcp`, kind: `api`
- Upstream: `packages/mcp/src/testing/index.ts` → `createInMemoryTransportPair`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-src-testing-index.ts.InMemoryTransport.api`

- Area: `mcp`, kind: `api`
- Upstream: `packages/mcp/src/testing/index.ts` → `InMemoryTransport`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-auth-provider.test.ts.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/auth-provider.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-authorization-server.ts.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/authorization-server.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-client.test.ts.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/client.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-config.test.ts.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/config.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-fixtures-exiting-parent-server.mjs.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/fixtures/exiting-parent-server.mjs`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-fixtures-stdio-server.mjs.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/fixtures/stdio-server.mjs`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-fixtures-stubborn-server.mjs.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/fixtures/stubborn-server.mjs`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-helpers.ts.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/helpers.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-lines.test.ts.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/lines.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-loopback.test.ts.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/loopback.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-oauth.test.ts.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/oauth.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-output-limit.test.ts.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/output-limit.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-pipe.test.ts.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/pipe.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-sign-in.test.ts.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/sign-in.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `mcp.packages-mcp-test-stdio.test.ts.internal.test`

- Area: `mcp`, kind: `test`
- Upstream: `packages/mcp/test/stdio.test.ts`
- Dart: `pi_agent/lib/src/tools.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#83`

### `coding-agent.packages-coding-agent-examples-extensions-auto-commit-on-exit.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/auto-commit-on-exit.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-bash-spawn-hook.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/bash-spawn-hook.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-bookmark.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/bookmark.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-border-status-editor.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/border-status-editor.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-built-in-tool-renderer.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/built-in-tool-renderer.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-claude-rules.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/claude-rules.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-commands.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/commands.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-confirm-destructive.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/confirm-destructive.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-custom-compaction.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/custom-compaction.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-custom-footer.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/custom-footer.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-custom-header.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/custom-header.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-custom-provider-anthropic-index.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/custom-provider-anthropic/index.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-custom-provider-anthropic-package-lock.json.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/custom-provider-anthropic/package-lock.json`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-custom-provider-anthropic-package.json.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/custom-provider-anthropic/package.json`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-custom-provider-gitlab-duo-index.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/custom-provider-gitlab-duo/index.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-custom-provider-gitlab-duo-package.json.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/custom-provider-gitlab-duo/package.json`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-custom-provider-gitlab-duo-test.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/custom-provider-gitlab-duo/test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-debug-provider.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/debug-provider.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-dirty-repo-guard.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/dirty-repo-guard.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-doom-overlay-doom-build-doom.js.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/doom-overlay/doom/build/doom.js`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-doom-overlay-doom-build-doom.wasm.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/doom-overlay/doom/build/doom.wasm`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-doom-overlay-doom-build.sh.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/doom-overlay/doom/build.sh`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-doom-overlay-doom-component.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/doom-overlay/doom-component.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-doom-overlay-doom-doomgeneric_pi.c.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/doom-overlay/doom/doomgeneric_pi.c`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-doom-overlay-doom-engine.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/doom-overlay/doom-engine.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-doom-overlay-doom-keys.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/doom-overlay/doom-keys.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-doom-overlay-index.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/doom-overlay/index.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-doom-overlay-readme.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/doom-overlay/README.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-doom-overlay-wad-finder.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/doom-overlay/wad-finder.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-dynamic-resources-dynamic.json.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/dynamic-resources/dynamic.json`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-dynamic-resources-dynamic.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/dynamic-resources/dynamic.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-dynamic-resources-index.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/dynamic-resources/index.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-dynamic-resources-skill.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/dynamic-resources/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-dynamic-tools.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/dynamic-tools.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-entry-renderer.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/entry-renderer.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-event-bus.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/event-bus.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-file-trigger.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/file-trigger.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-git-checkpoint.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/git-checkpoint.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-git-merge-and-resolve.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/git-merge-and-resolve.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-github-issue-autocomplete.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/github-issue-autocomplete.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-gondolin-index.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/gondolin/index.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-gondolin-package-lock.json.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/gondolin/package-lock.json`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-gondolin-package.json.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/gondolin/package.json`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-handoff.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/handoff.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-hello.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/hello.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-hidden-thinking-label.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/hidden-thinking-label.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-inline-bash.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/inline-bash.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-input-transform-streaming.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/input-transform-streaming.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-input-transform.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/input-transform.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-interactive-shell.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/interactive-shell.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-jev-router.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/jev-router.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-mac-system-theme.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/mac-system-theme.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-message-renderer.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/message-renderer.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-minimal-mode.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/minimal-mode.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-modal-editor.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/modal-editor.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-model-status.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/model-status.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-notify.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/notify.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-overlay-qa-tests.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/overlay-qa-tests.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-overlay-test.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/overlay-test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-permission-gate.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/permission-gate.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-pirate.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/pirate.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-plan-mode-index.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/plan-mode/index.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-plan-mode-readme.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/plan-mode/README.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-plan-mode-utils.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/plan-mode/utils.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-preset.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/preset.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-project-trust.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/project-trust.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-prompt-customizer.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/prompt-customizer.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-protected-paths.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/protected-paths.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-provider-payload.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/provider-payload.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-qna.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/qna.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-question.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/question.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-questionnaire.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/questionnaire.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-rainbow-editor.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/rainbow-editor.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-readme.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/README.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-reload-runtime.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/reload-runtime.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-rpc-demo.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/rpc-demo.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-send-user-message.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/send-user-message.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-session-name.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/session-name.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-shutdown-command.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/shutdown-command.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-snake.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/snake.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-space-invaders.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/space-invaders.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-ssh.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/ssh.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-status-line.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/status-line.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-structured-output.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/structured-output.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-subagent-agents-planner.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/subagent/agents/planner.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-subagent-agents-reviewer.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/subagent/agents/reviewer.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-subagent-agents-scout.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/subagent/agents/scout.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-subagent-agents-worker.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/subagent/agents/worker.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-subagent-agents.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/subagent/agents.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-subagent-index.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/subagent/index.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-subagent-prompts-implement-and-review.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/subagent/prompts/implement-and-review.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-subagent-prompts-implement.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/subagent/prompts/implement.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-subagent-prompts-scout-and-plan.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/subagent/prompts/scout-and-plan.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-subagent-readme.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/subagent/README.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-summarize.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/summarize.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-system-prompt-header.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/system-prompt-header.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-tic-tac-toe.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/tic-tac-toe.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-timed-confirm.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/timed-confirm.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-titlebar-spinner.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/titlebar-spinner.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-todo.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/todo.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-tool-override.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/tool-override.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-tools.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/tools.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-trigger-compact.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/trigger-compact.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-truncated-tool.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/truncated-tool.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-widget-placement.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/widget-placement.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-with-deps-index.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/with-deps/index.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-with-deps-package-lock.json.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/with-deps/package-lock.json`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-with-deps-package.json.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/with-deps/package.json`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-working-indicator.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/working-indicator.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-extensions-working-message-test.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/extensions/working-message-test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-readme.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/README.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-rpc-client.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/rpc-client.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-rpc-extension-ui.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/rpc-extension-ui.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-01-minimal.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/01-minimal.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-02-custom-model.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/02-custom-model.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-03-custom-prompt.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/03-custom-prompt.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-04-skills.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/04-skills.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-05-tools.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/05-tools.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-06-extensions.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/06-extensions.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-07-context-files.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/07-context-files.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-08-prompt-templates.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/08-prompt-templates.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-09-api-keys-and-oauth.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/09-api-keys-and-oauth.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-10-settings.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/10-settings.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-11-sessions.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/11-sessions.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-12-full-control.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/12-full-control.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-13-session-runtime.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/13-session-runtime.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-14-codemode-mcp.ts.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/14-codemode-mcp.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-sdk-readme.md.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/sdk/README.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-examples-tsconfig.json.internal.example`

- Area: `coding-agent`, kind: `example`
- Upstream: `packages/coding-agent/examples/tsconfig.json`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-bun-cli.ts.internal.internal`

- Area: `coding-agent`, kind: `internal`
- Upstream: `packages/coding-agent/src/bun/cli.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-bun-runtime-setup.ts.internal.internal`

- Area: `coding-agent`, kind: `internal`
- Upstream: `packages/coding-agent/src/bun/runtime-setup.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-bun-sandbox-env-setup.ts.internal.internal`

- Area: `coding-agent`, kind: `internal`
- Upstream: `packages/coding-agent/src/bun/sandbox-env-setup.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-cli.ts.internal.internal`

- Area: `coding-agent`, kind: `internal`
- Upstream: `packages/coding-agent/src/cli.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-agent-session-runtime.ts.AgentSessionRuntime.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/agent-session-runtime.ts` → `AgentSessionRuntime`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-agent-session-runtime.ts.createAgentSessionRuntime.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/agent-session-runtime.ts` → `createAgentSessionRuntime`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-agent-session-runtime.ts.CreateAgentSessionRuntimeFactory.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/agent-session-runtime.ts` → `CreateAgentSessionRuntimeFactory`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-agent-session-runtime.ts.CreateAgentSessionRuntimeResult.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/agent-session-runtime.ts` → `CreateAgentSessionRuntimeResult`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-agent-session-runtime.ts.SessionImportFileNotFoundError.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/agent-session-runtime.ts` → `SessionImportFileNotFoundError`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-branch-summarization.ts.BranchSummaryDetails.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/branch-summarization.ts` → `BranchSummaryDetails`
- Dart: `pi_agent/lib/src/coding_agent/compaction.dart`
- Divergence: BranchSummaryDetails is the JSON shape stored on a branch_summary entry; the Dart BranchSummaryEntry carries no details field yet. Tracked in #44.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-branch-summarization.ts.BranchSummaryResult.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/branch-summarization.ts` → `BranchSummaryResult`
- Dart: `pi_agent/lib/src/coding_agent/compaction.dart`
- Divergence: BranchSummaryResult is the provider-backed generateBranchSummary result; that model/stream path is a later slice. Tracked in #44.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-branch-summarization.ts.generateBranchSummary.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/branch-summarization.ts` → `generateBranchSummary`
- Dart: `pi_agent/lib/src/coding_agent/compaction.dart`
- Divergence: generateBranchSummary needs a model + stream (completeSummarization); deferred to a provider-backed slice. The pure prepareBranchEntries it builds on is ported. Tracked in #44.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-branch-summarization.ts.GenerateBranchSummaryOptions.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/branch-summarization.ts` → `GenerateBranchSummaryOptions`
- Dart: `pi_agent/lib/src/coding_agent/compaction.dart`
- Divergence: GenerateBranchSummaryOptions configures the provider-backed generateBranchSummary; deferred with it to a later slice. Tracked in #44.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.calculateContextTokens.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `calculateContextTokens`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.compact.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `compact`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.CompactionDetails.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `CompactionDetails`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.CompactionPreparation.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `CompactionPreparation`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.CompactionResult.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `CompactionResult`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.CompactionSettings.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `CompactionSettings`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.completeSummarization.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `completeSummarization`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.ContextUsageEstimate.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `ContextUsageEstimate`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.CutPointResult.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `CutPointResult`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.DEFAULT_COMPACTION_SETTINGS.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `DEFAULT_COMPACTION_SETTINGS`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.estimateContextTokens.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `estimateContextTokens`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.estimateProjectedContextTokens.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `estimateProjectedContextTokens`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.estimateTokens.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `estimateTokens`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.findCutPoint.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `findCutPoint`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.findTurnStartIndex.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `findTurnStartIndex`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.generateSummary.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `generateSummary`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.generateSummaryWithUsage.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `generateSummaryWithUsage`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.getLastAssistantUsage.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `getLastAssistantUsage`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.getSummarizationFailure.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `getSummarizationFailure`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.prepareCompaction.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `prepareCompaction`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-compaction.ts.shouldCompact.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/compaction.ts` → `shouldCompact`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-compaction-utils.ts.SUMMARIZATION_SYSTEM_PROMPT.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/compaction/utils.ts` → `SUMMARIZATION_SYSTEM_PROMPT`
- Dart: `pi_agent/lib/src/coding_agent/compaction.dart`
- Divergence: SUMMARIZATION_SYSTEM_PROMPT already has a Dart equivalent (summarizationSystemPrompt in src/compaction.dart); the coding-agent export is the same text, not re-exported here. Tracked in #44.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-export-html-index.ts.exportFromFile.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/export-html/index.ts` → `exportFromFile`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-export-html-index.ts.ExportOptions.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/export-html/index.ts` → `ExportOptions`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-export-html-index.ts.exportSessionToHtml.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/export-html/index.ts` → `exportSessionToHtml`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-export-html-index.ts.ToolHtmlRenderer.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/export-html/index.ts` → `ToolHtmlRenderer`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-export-html-template.js.internal.internal`

- Area: `coding-agent`, kind: `internal`
- Upstream: `packages/coding-agent/src/core/export-html/template.js`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-export-html-vendor-highlight.min.js.internal.internal`

- Area: `coding-agent`, kind: `internal`
- Upstream: `packages/coding-agent/src/core/export-html/vendor/highlight.min.js`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-export-html-vendor-marked-cjk-friendly.min.js.internal.internal`

- Area: `coding-agent`, kind: `internal`
- Upstream: `packages/coding-agent/src/core/export-html/vendor/marked-cjk-friendly.min.js`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-export-html-vendor-marked.min.js.internal.internal`

- Area: `coding-agent`, kind: `internal`
- Upstream: `packages/coding-agent/src/core/export-html/vendor/marked.min.js`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-extensions-index.ts.ExtensionRunner.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/extensions/index.ts` → `ExtensionRunner`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-extensions-index.ts.SlashCommandInfo.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/extensions/index.ts` → `SlashCommandInfo`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-extensions-index.ts.SlashCommandSource.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/extensions/index.ts` → `SlashCommandSource`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-extensions-index.ts.SourceInfo.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/extensions/index.ts` → `SourceInfo`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-extensions-index.ts.wrapRegisteredTool.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/extensions/index.ts` → `wrapRegisteredTool`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-extensions-index.ts.wrapRegisteredTools.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/extensions/index.ts` → `wrapRegisteredTools`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-index.ts.areExperimentalFeaturesEnabled.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/index.ts` → `areExperimentalFeaturesEnabled`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-index.ts.CacheWarmingDecision.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/index.ts` → `CacheWarmingDecision`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-index.ts.CacheWarmingStatus.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/index.ts` → `CacheWarmingStatus`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-index.ts.createEventBus.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/index.ts` → `createEventBus`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-index.ts.createSyntheticSourceInfo.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/index.ts` → `createSyntheticSourceInfo`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-index.ts.executeBashWithOperations.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/index.ts` → `executeBashWithOperations`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-index.ts.allToolNames.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/index.ts` → `allToolNames`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-index.ts.createAllToolDefinitions.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/index.ts` → `createAllToolDefinitions`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-index.ts.createAllTools.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/index.ts` → `createAllTools`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-index.ts.createCodingToolDefinitions.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/index.ts` → `createCodingToolDefinitions`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-index.ts.createCodingTools.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/index.ts` → `createCodingTools`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-index.ts.createReadOnlyToolDefinitions.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/index.ts` → `createReadOnlyToolDefinitions`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-index.ts.createReadOnlyTools.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/index.ts` → `createReadOnlyTools`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-index.ts.createTool.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/index.ts` → `createTool`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-index.ts.createToolDefinition.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/index.ts` → `createToolDefinition`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-index.ts.Tool.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/index.ts` → `Tool`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-index.ts.ToolDef.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/index.ts` → `ToolDef`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-index.ts.ToolName.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/index.ts` → `ToolName`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-index.ts.ToolsOptions.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/index.ts` → `ToolsOptions`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-index.ts.withFileMutationQueue.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/index.ts` → `withFileMutationQueue`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-renderers-index.ts.createAllToolRenderers.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/renderers/index.ts` → `createAllToolRenderers`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-renderers-index.ts.ToolRenderers.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/renderers/index.ts` → `ToolRenderers`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-core-tools-renderers-index.ts.withBuiltInRenderers.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/core/tools/renderers/index.ts` → `withBuiltInRenderers`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-experimental-source-resolver.ts.internal.internal`

- Area: `coding-agent`, kind: `internal`
- Upstream: `packages/coding-agent/src/experimental/source-resolver.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-extensions-codemode-index.ts.CodemodeExtensionOptions.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/extensions/codemode/index.ts` → `CodemodeExtensionOptions`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-extensions-codemode-index.ts.createCodemodeExtension.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/extensions/codemode/index.ts` → `createCodemodeExtension`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-extensions-codemode-worker.ts.internal.internal`

- Area: `coding-agent`, kind: `internal`
- Upstream: `packages/coding-agent/src/extensions/codemode/worker.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-extensions-index.ts.builtInExtensions.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/extensions/index.ts` → `builtInExtensions`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-extensions-llama-index.ts.llamaExtension.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/extensions/llama/index.ts` → `llamaExtension`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-extensions-mcp-index.ts.createMcpExtension.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/extensions/mcp/index.ts` → `createMcpExtension`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-extensions-mcp-index.ts.MAX_SERVERS_SECTION_CHARS.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/extensions/mcp/index.ts` → `MAX_SERVERS_SECTION_CHARS`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-extensions-mcp-index.ts.MCP_SERVERS_SECTION.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/extensions/mcp/index.ts` → `MCP_SERVERS_SECTION`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-extensions-mcp-index.ts.McpExtensionOptions.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/extensions/mcp/index.ts` → `McpExtensionOptions`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-extensions-mcp-index.ts.McpServerListing.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/extensions/mcp/index.ts` → `McpServerListing`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-extensions-mcp-index.ts.McpTransportFactory.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/extensions/mcp/index.ts` → `McpTransportFactory`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-extensions-mcp-index.ts.renderServersSection.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/extensions/mcp/index.ts` → `renderServersSection`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-extensions-tool-search-index.ts.createToolSearchExtension.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/extensions/tool-search/index.ts` → `createToolSearchExtension`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.CodemodeStoreEntryData.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `CodemodeStoreEntryData`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.CodemodeToolDetails.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `CodemodeToolDetails`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.convertToLlm.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `convertToLlm`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.convertToPng.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `convertToPng`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.copyToClipboard.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `copyToClipboard`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.DefaultPackageManager.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `DefaultPackageManager`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.DefaultResourceLoader.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `DefaultResourceLoader`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.detectSupportedImageMimeTypeFromFile.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `detectSupportedImageMimeTypeFromFile`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.formatDimensionNote.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `formatDimensionNote`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.formatReadLineRange.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `formatReadLineRange`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.generateDiffString.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `generateDiffString`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.generateUnifiedPatch.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `generateUnifiedPatch`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.LoadedMcpConfig.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `LoadedMcpConfig`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.loadProjectContextFiles.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `loadProjectContextFiles`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.main.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `main`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.McpExposure.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `McpExposure`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.McpServerConfig.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `McpServerConfig`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.McpServerEntry.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `McpServerEntry`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.ModelRegistry.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `ModelRegistry`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.parseArgs.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `parseArgs`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.parseFrontmatter.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `parseFrontmatter`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.ReadonlyFooterDataProvider.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `ReadonlyFooterDataProvider`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.readStoredCredential.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `readStoredCredential`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.RegisteredMcpServer.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `RegisteredMcpServer`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.resizeImage.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `resizeImage`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.ResourceCollision.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `ResourceCollision`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.ResourceDiagnostic.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `ResourceDiagnostic`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.ResourceLoader.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `ResourceLoader`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-index.ts.stripFrontmatter.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/index.ts` → `stripFrontmatter`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-index.ts.InteractiveMode.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/index.ts` → `InteractiveMode`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-index.ts.JsonAgentSessionEvent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/index.ts` → `JsonAgentSessionEvent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-index.ts.RpcClient.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/index.ts` → `RpcClient`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-index.ts.runPrintMode.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/index.ts` → `runPrintMode`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-index.ts.runRpcMode.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/index.ts` → `runRpcMode`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.ArminComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `ArminComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.AssistantMessageComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `AssistantMessageComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.BashExecutionComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `BashExecutionComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.BorderedLoader.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `BorderedLoader`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.BranchSummaryMessageComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `BranchSummaryMessageComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.CompactionSummaryMessageComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `CompactionSummaryMessageComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.CustomEditor.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `CustomEditor`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.CustomMessageComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `CustomMessageComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.DynamicBorder.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `DynamicBorder`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.ExtensionEditorComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `ExtensionEditorComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.ExtensionInputComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `ExtensionInputComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.ExtensionSelectorComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `ExtensionSelectorComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.FooterComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `FooterComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.keyHint.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `keyHint`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.keyText.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `keyText`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.LoginDialogComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `LoginDialogComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.ModelSelectorComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `ModelSelectorComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.OAuthSelectorComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `OAuthSelectorComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.rawKeyHint.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `rawKeyHint`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.renderDiff.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `renderDiff`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.ScopedModelsSelectorComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `ScopedModelsSelectorComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.SessionSelectorComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `SessionSelectorComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.SettingsSelectorComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `SettingsSelectorComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.ShowImagesSelectorComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `ShowImagesSelectorComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.SkillInvocationMessageComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `SkillInvocationMessageComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.ThemeSelectorComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `ThemeSelectorComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.ThinkingSelectorComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `ThinkingSelectorComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.ToolExecutionComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `ToolExecutionComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.TreeSelectorComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `TreeSelectorComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.truncateToVisualLines.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `truncateToVisualLines`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.TrustSelectorComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `TrustSelectorComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.UserMessageComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `UserMessageComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-modes-interactive-components-index.ts.UserMessageSelectorComponent.api`

- Area: `coding-agent`, kind: `api`
- Upstream: `packages/coding-agent/src/modes/interactive/components/index.ts` → `UserMessageSelectorComponent`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-rpc-entry.ts.internal.internal`

- Area: `coding-agent`, kind: `internal`
- Upstream: `packages/coding-agent/src/rpc-entry.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-src-utils-image-resize-worker.ts.internal.internal`

- Area: `coding-agent`, kind: `internal`
- Upstream: `packages/coding-agent/src/utils/image-resize-worker.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-agent-session-auto-compaction-queue.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/agent-session-auto-compaction-queue.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-agent-session-branching.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/agent-session-branching.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-agent-session-compaction.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/agent-session-compaction.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-agent-session-concurrent.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/agent-session-concurrent.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-agent-session-dynamic-provider.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/agent-session-dynamic-provider.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-agent-session-dynamic-tools.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/agent-session-dynamic-tools.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-agent-session-queued-images.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/agent-session-queued-images.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-agent-session-retry.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/agent-session-retry.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-agent-session-runtime-diagnostics.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/agent-session-runtime-diagnostics.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-agent-session-runtime-events.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/agent-session-runtime-events.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-agent-session-stats.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/agent-session-stats.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-agent-session-tree-navigation.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/agent-session-tree-navigation.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-ansi-utils.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/ansi-utils.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-args.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/args.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-assistant-message.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/assistant-message.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-auth-check.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/auth-check.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-auth-login.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/auth-login.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-auth-logout.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/auth-logout.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-auth-storage.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/auth-storage.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-auth-terminal.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/auth-terminal.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-auth-url-copy.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/auth-url-copy.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-bash-close-hang-windows.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/bash-close-hang-windows.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-bash-execution-width.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/bash-execution-width.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-bash-executor-truncation.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/bash-executor-truncation.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-block-images.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/block-images.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-branch-summary-extensions.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/branch-summary-extensions.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-bug-report.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/bug-report.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-builtin-tool-strict-mode.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/builtin-tool-strict-mode.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-cache-stats.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/cache-stats.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-cache-warmer.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/cache-warmer.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-changelog.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/changelog.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-chat-viewport.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/chat-viewport.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-clipboard-command.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/clipboard-command.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-clipboard-image-bmp-conversion.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/clipboard-image-bmp-conversion.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-clipboard-image-native-errors.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/clipboard-image-native-errors.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-clipboard-image.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/clipboard-image.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-clipboard-paste-file-paths.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/clipboard-paste-file-paths.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-clipboard.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/clipboard.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-code-highlighter.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/code-highlighter.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-codemode-renderer.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/codemode-renderer.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-codemode-worker-admission.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/codemode-worker-admission.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-codemode-worker-config.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/codemode-worker-config.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-collapsible-message-components.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/collapsible-message-components.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-compaction-extensions-example.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/compaction-extensions-example.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-compaction-extensions.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/compaction-extensions.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-compaction-nested-calls.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/compaction-nested-calls.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-compaction-serialization.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/compaction-serialization.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-compaction-summary-reasoning.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/compaction-summary-reasoning.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-compaction.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/compaction.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-config-schemas.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/config-schemas.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-config-selector-keybindings.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/config-selector-keybindings.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-config-selector.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/config-selector.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-config-value-migration.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/config-value-migration.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-config.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/config.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-crash-log.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/crash-log.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-credential-print.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/credential-print.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-custom-editor-keybindings.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/custom-editor-keybindings.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-custom-message.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/custom-message.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-default-tools-setting.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/default-tools-setting.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-deleted-cwd.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/deleted-cwd.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-diff.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/diff.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-documentation.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/documentation.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-edit-diff-window.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/edit-diff-window.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-edit-tool-diff-before-write.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/edit-tool-diff-before-write.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-edit-tool-legacy-input.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/edit-tool-legacy-input.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-edit-tool-no-full-redraw.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/edit-tool-no-full-redraw.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-exec-runtime-limit.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/exec-runtime-limit.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-exec-utf8-chunks.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/exec-utf8-chunks.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-exec.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/exec.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-experimental.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/experimental.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-export-html-ansi-links.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/export-html-ansi-links.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-export-html-cjk.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/export-html-cjk.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-export-html-cost.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/export-html-cost.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-export-html-deep-tree.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/export-html-deep-tree.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-export-html-skill-block.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/export-html-skill-block.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-export-html-system-messages.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/export-html-system-messages.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-export-html-whitespace.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/export-html-whitespace.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-export-html-xss.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/export-html-xss.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-export-jsonl-share.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/export-jsonl-share.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-extension-keybinding-hints.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/extension-keybinding-hints.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-extension-selector.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/extension-selector.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-extensions-discovery.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/extensions-discovery.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-extensions-input-event.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/extensions-input-event.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-extensions-runner.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/extensions-runner.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-external-editor.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/external-editor.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-file-mutation-queue.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/file-mutation-queue.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-find-abort-before-spawn.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/find-abort-before-spawn.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-first-time-setup-fork.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/first-time-setup-fork.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-first-time-setup.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/first-time-setup.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-assistant-message-with-thinking-code.json.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/assistant-message-with-thinking-code.json`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-before-compaction.jsonl.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/before-compaction.jsonl`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-fake-external-editor.mjs.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/fake-external-editor.mjs`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-flush-stdout-exit.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/flush-stdout-exit.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-large-session.jsonl.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/large-session.jsonl`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-collision-first-calendar-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills-collision/first/calendar/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-collision-second-calendar-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills-collision/second/calendar/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-consecutive-hyphens-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills/consecutive-hyphens/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-disable-model-invocation-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills/disable-model-invocation/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-invalid-name-chars-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills/invalid-name-chars/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-invalid-yaml-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills/invalid-yaml/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-long-name-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills/long-name/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-missing-description-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills/missing-description/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-multiline-description-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills/multiline-description/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-name-mismatch-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills/name-mismatch/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-nested-child-skill-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills/nested/child-skill/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-no-frontmatter-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills/no-frontmatter/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-root-skill-preferred-nested-child-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills/root-skill-preferred/nested-child/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-root-skill-preferred-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills/root-skill-preferred/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-unknown-field-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills/unknown-field/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-skills-valid-skill-skill.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/skills/valid-skill/SKILL.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-fixtures-subagent-child.mjs.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/fixtures/subagent-child.mjs`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-flush-stdout.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/flush-stdout.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-footer-data-provider.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/footer-data-provider.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-footer-width.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/footer-width.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-format-resume-command.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/format-resume-command.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-frontmatter.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/frontmatter.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-git-merge-and-resolve-extension.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/git-merge-and-resolve-extension.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-git-ssh-url.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/git-ssh-url.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-git-update.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/git-update.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-grep-operations.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/grep-operations.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-http-dispatcher.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/http-dispatcher.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-image-process.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/image-process.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-image-processing.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/image-processing.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-image-resize-callers.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/image-resize-callers.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-image-resize-worker-teardown.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/image-resize-worker-teardown.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-initial-message.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/initial-message.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-input-transform-streaming-example.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/input-transform-streaming-example.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-anthropic-warning.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-anthropic-warning.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-assistant-diagnostics.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-assistant-diagnostics.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-bug-report-hint.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-bug-report-hint.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-clone-command.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-clone-command.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-compaction.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-compaction.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-extension-changelog.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-extension-changelog.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-extension-dialogs.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-extension-dialogs.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-import-command.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-import-command.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-model-scope.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-model-scope.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-paste.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-paste.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-resume-missing-cwd.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-resume-missing-cwd.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-startup-input.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-startup-input.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-status.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-status.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-suspend.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-suspend.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-mode-tree-navigation.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-mode-tree-navigation.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-interactive-tui.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/interactive-tui.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-jev-router-example.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/jev-router-example.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-keybindings-migration.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/keybindings-migration.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-keybindings.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/keybindings.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-llama-extension.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/llama-extension.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-llama-ui.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/llama-ui.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-login-dialog-device-code.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/login-dialog-device-code.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-management-http.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/management-http.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-max-thinking.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/max-thinking.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-mcp-command.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/mcp-command.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-mcp-conformance-baseline.json.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/mcp-conformance/baseline.json`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-mcp-conformance-client.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/mcp-conformance/client.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-mcp-conformance-readme.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/mcp-conformance/README.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-mcp-conformance-run.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/mcp-conformance/run.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-mcp-extension.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/mcp-extension.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-mcp-manager-view.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/mcp-manager-view.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-mcp-oauth-refresh.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/mcp-oauth-refresh.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-mcp-oauth-store.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/mcp-oauth-store.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-mermaid.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/mermaid.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-catalog-protocol.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-catalog-protocol.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-catalog-refresh.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-catalog-refresh.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-fallback-diagnostic.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-fallback-diagnostic.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-registry.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-registry.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-resolver.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-resolver.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-runtime-auth-options.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-runtime-auth-options.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-runtime-classifiers.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-runtime-classifiers.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-runtime-cloudflare-compat.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-runtime-cloudflare-compat.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-runtime-credential-sync.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-runtime-credential-sync.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-runtime-images.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-runtime-images.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-runtime-modify-models-compat.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-runtime-modify-models-compat.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-runtime-test-utils.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-runtime-test-utils.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-scope-session-replacement.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-scope-session-replacement.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-search.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-search.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-model-selector.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/model-selector.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-models-store.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/models-store.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-nested-tool-calls.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/nested-tool-calls.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-oauth-selector.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/oauth-selector.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-output-pad.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/output-pad.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-package-command-paths.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/package-command-paths.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-package-distribution.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/package-distribution.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-package-manager-ssh.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/package-manager-ssh.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-package-manager.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/package-manager.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-path-utils.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/path-utils.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-paths.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/paths.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-pi-user-agent.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/pi-user-agent.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-plan-mode-extension.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/plan-mode-extension.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-plan-mode-utils.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/plan-mode-utils.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-powershell-config.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/powershell-config.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-powershell-tool.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/powershell-tool.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-preferred-providers.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/preferred-providers.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-print-mode.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/print-mode.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-program-status-reporter.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/program-status-reporter.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-project-trust-saved-decision.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/project-trust-saved-decision.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-prompt-templates.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/prompt-templates.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-provider-matching.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/provider-matching.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-radius.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/radius.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-read-line-range-display.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/read-line-range-display.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-read-streaming.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/read-streaming.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-references.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/references.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-remote-catalog-provider.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/remote-catalog-provider.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-resolve-config-value.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/resolve-config-value.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-resource-loader-theme.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/resource-loader-theme.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-resource-loader.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/resource-loader.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-restore-sandbox-env.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/restore-sandbox-env.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-rpc-client-clear-queue.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/rpc-client-clear-queue.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-rpc-client-clone.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/rpc-client-clone.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-rpc-client-process-exit.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/rpc-client-process-exit.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-rpc-example.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/rpc-example.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-rpc-prompt-response-semantics.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/rpc-prompt-response-semantics.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-rpc-replacement-diagnostics.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/rpc-replacement-diagnostics.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-rpc.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/rpc.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-runtime-credentials.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/runtime-credentials.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-scoped-models-selector.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/scoped-models-selector.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-scrollbar-theme.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/scrollbar-theme.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-sdk-client-identity.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/sdk-client-identity.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-sdk-codex-cache-probe-tool-loop.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/sdk-codex-cache-probe-tool-loop.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-sdk-session-manager.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/sdk-session-manager.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-sdk-skills.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/sdk-skills.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-sdk-stream-options.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/sdk-stream-options.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-context-edit.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-context-edit.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-cwd.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-cwd.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-file-invalid.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-file-invalid.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-id-readonly.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-id-readonly.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-info-modified-timestamp.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-info-modified-timestamp.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-manager-build-context.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-manager/build-context.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-manager-custom-session-id.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-manager/custom-session-id.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-manager-file-operations.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-manager/file-operations.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-manager-labels.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-manager/labels.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-manager-load-entries.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-manager/load-entries.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-manager-migration.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-manager/migration.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-manager-save-entry.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-manager/save-entry.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-manager-tree-traversal.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-manager/tree-traversal.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-selector-path-delete.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-selector-path-delete.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-selector-rename.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-selector-rename.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-selector-search.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-selector-search.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-selector-selection.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-selector-selection.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-session-share.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/session-share.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-settings-diagnostics.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/settings-diagnostics.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-settings-manager-bug.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/settings-manager-bug.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-settings-manager-compaction.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/settings-manager-compaction.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-settings-manager.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/settings-manager.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-settings-selector.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/settings-selector.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-settings-submenu.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/settings-submenu.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-shell-kill-process-tree.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/shell-kill-process-tree.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-shell-path-exists.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/shell-path-exists.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-skills.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/skills.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-source-info.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/source-info.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-startup-session-name.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/startup-session-name.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-status-indicator.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/status-indicator.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-stdout-cleanliness.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/stdout-cleanliness.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-streaming-render-debug.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/streaming-render-debug.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-subagent-extension.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/subagent-extension.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-agent-session-bash-persistence.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/agent-session-bash-persistence.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-agent-session-boundaries.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/agent-session-boundaries.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-agent-session-codemode.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/agent-session-codemode.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-agent-session-compaction-model-overrides.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/agent-session-compaction-model-overrides.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-agent-session-compaction.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/agent-session-compaction.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-agent-session-mcp-oauth.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/agent-session-mcp-oauth.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-agent-session-mcp.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/agent-session-mcp.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-agent-session-model-extension.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/agent-session-model-extension.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-agent-session-prompt.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/agent-session-prompt.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-agent-session-queue.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/agent-session-queue.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-agent-session-retry-events.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/agent-session-retry-events.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-agent-session-runtime.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/agent-session-runtime.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-agent-session-tool-orchestration.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/agent-session-tool-orchestration.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-agent-session-tool-result-images.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/agent-session-tool-result-images.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-harness.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/harness.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-lax-message-content.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/lax-message-content.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-mcp-oauth-server.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/mcp-oauth-server.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-print-mode-session-start-events.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/print-mode-session-start-events.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-readme.md.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/README.md`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-10285-mcp-tool-renderers.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/10285-mcp-tool-renderers.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-10470-rpc-session-replacement-start-once.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/10470-rpc-session-replacement-start-once.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-11156-pi-ai-models-virtual-module.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/11156-pi-ai-models-virtual-module.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-11227-recovery-omits-tool-results.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/11227-recovery-omits-tool-results.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-11264-pi-events-handler-errors.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/11264-pi-events-handler-errors.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-11451-thinking-level-after-tree-navigation.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/11451-thinking-level-after-tree-navigation.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-11520-sdk-summary-oauth-auth.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/11520-sdk-summary-oauth-auth.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-11613-bash-timeout-after-shell-exit.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/11613-bash-timeout-after-shell-exit.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-11692-dispose-waits-for-oauth-refresh.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/11692-dispose-waits-for-oauth-refresh.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-12066-find-ancestor-glob.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/12066-find-ancestor-glob.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-12119-copy-after-abort-or-error.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/12119-copy-after-abort-or-error.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-12124-websocket-connection-limit-retry.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/12124-websocket-connection-limit-retry.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-1717-2113-agent-session-event-settlement.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/1717-2113-agent-session-event-settlement.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-2023-queued-slash-command-followup.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/2023-queued-slash-command-followup.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-2753-reload-stale-resource-settings.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/2753-reload-stale-resource-settings.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-2781-skill-collision-precedence.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/2781-skill-collision-precedence.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-2791-fswatch-error-crash.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/2791-fswatch-error-crash.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-2835-tools-allowlist-filters-extension-tools.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/2835-tools-allowlist-filters-extension-tools.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-2860-replaced-session-context.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/2860-replaced-session-context.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-3217-scoped-model-order.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/3217-scoped-model-order.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-3302-find-path-glob.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/3302-find-path-glob.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-3303-find-nested-gitignore.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/3303-find-nested-gitignore.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-3317-network-connection-lost-retry.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/3317-network-connection-lost-retry.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-3592-no-builtin-tools-keeps-extension-tools.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/3592-no-builtin-tools-keeps-extension-tools.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-3616-settings-inmemory-reload.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/3616-settings-inmemory-reload.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-3686-session-name-event.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/3686-session-name-event.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-3688-tree-cancel-compacting.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/3688-tree-cancel-compacting.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-3982-message-end-cost-override.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/3982-message-end-cost-override.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-4167-thinking-toggle-pending-tool-render.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/4167-thinking-toggle-pending-tool-render.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-5080-signal-shutdown-extension-cleanup.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/5080-signal-shutdown-extension-cleanup.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-5109-exclude-tools.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/5109-exclude-tools.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-5208-late-bash-output.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/5208-late-bash-output.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-5217-compaction-reason.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/5217-compaction-reason.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-5303-bash-output-truncation.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/5303-bash-output-truncation.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-5433-extension-oauth-prompt-input.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/5433-extension-oauth-prompt-input.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-5596-missing-theme-export.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/5596-missing-theme-export.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-5661-uppercase-header-values.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/5661-uppercase-header-values.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-5724-sigterm-signal-exit.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/5724-sigterm-signal-exit.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-5868-rpc-unknown-command-id.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/5868-rpc-unknown-command-id.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-5943-session-start-notify.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/5943-session-start-notify.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-5996-session-name-newlines.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/5996-session-name-newlines.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-5998-blocked-tool-terminate.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/5998-blocked-tool-terminate.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-6019-explicit-provider-retry-message.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/6019-explicit-provider-retry-message.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-6104-find-root-relativization.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/6104-find-root-relativization.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-6162-extension-active-tools-next-turn.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/6162-extension-active-tools-next-turn.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-6260-inline-extension-naming.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/6260-inline-extension-naming.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-6324-branch-summary-ambient-auth.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/6324-branch-summary-ambient-auth.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-6363-agent-settled-event.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/6363-agent-settled-event.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-6596-taskkill-enoent.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/6596-taskkill-enoent.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-6647-compaction-retries-transient-stream-drop.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/6647-compaction-retries-transient-stream-drop.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-6768-copilot-compaction-base-url.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/6768-copilot-compaction-base-url.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-6904-dns-transport-retry.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/6904-dns-transport-retry.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-6949-unavailable-scoped-model.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/6949-unavailable-scoped-model.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-6999-models-json-hot-reload.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/6999-models-json-hot-reload.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7027-credential-refresh-hang.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7027-credential-refresh-hang.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7048-compaction-truncated-summary.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7048-compaction-truncated-summary.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7150-rpc-prompt-during-compaction.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7150-rpc-prompt-during-compaction.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7153-scoped-models-refresh.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7153-scoped-models-refresh.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7187-malformed-package-manifest.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7187-malformed-package-manifest.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7193-event-bus-lifecycle.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7193-event-bus-lifecycle.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7209-model-selector-filter-resets-selection.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7209-model-selector-filter-resets-selection.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7253-manual-compact-during-response.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7253-manual-compact-during-response.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7269-cli-end-of-options.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7269-cli-end-of-options.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7290-json-stream-linear.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7290-json-stream-linear.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7301-stalled-availability-refresh.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7301-stalled-availability-refresh.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7443-model-command-cached-match.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7443-model-command-cached-match.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7497-session-discovery-symlink.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7497-session-discovery-symlink.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7572-provider-retry-settings-merge.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7572-provider-retry-settings-merge.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7731-tui-method-wrapping.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7731-tui-method-wrapping.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7829-invalid-settings-warning.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7829-invalid-settings-warning.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7911-json-stream-usage.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7911-json-stream-usage.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-7925-toolcall-start-metadata.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/7925-toolcall-start-metadata.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-8092-extension-realpath-jiti.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/8092-extension-realpath-jiti.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-8237-node-sea-extension-loading.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/8237-node-sea-extension-loading.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-8261-subagent-project-trust.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/8261-subagent-project-trust.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-8328-zero-usage-auto-compaction.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/8328-zero-usage-auto-compaction.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-8337-utf8-bom-parsing.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/8337-utf8-bom-parsing.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-8409-aborted-tool-auth-setup.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/8409-aborted-tool-auth-setup.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-8423-extension-factory-failure.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/8423-extension-factory-failure.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-8537-custom-message-tool-result-ordering.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/8537-custom-message-tool-result-ordering.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-8611-thinking-toggle-pending-bash-output.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/8611-thinking-toggle-pending-bash-output.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-8724-in-memory-fork-active-tool.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/8724-in-memory-fork-active-tool.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-8935-parallel-preflight-abort.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/8935-parallel-preflight-abort.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-8964-extension-provider-streaming.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/8964-extension-provider-streaming.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-8989-fork-compaction-label-boundary.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/8989-fork-compaction-label-boundary.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-9068-user-bash-fail-closed.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/9068-user-bash-fail-closed.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-9124-runtime-dispose-tool-settlement.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/9124-runtime-dispose-tool-settlement.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-9154-prompt-during-tree-navigation.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/9154-prompt-during-tree-navigation.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-9178-tree-during-compaction.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/9178-tree-during-compaction.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-9221-reload-during-tool.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/9221-reload-during-tool.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-9340-9777-auto-compaction-cancellation.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/9340-9777-auto-compaction-cancellation.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-9540-extension-loader-lazy.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/9540-extension-loader-lazy.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-9789-context-handler-system-messages.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/9789-context-handler-system-messages.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-copilot-request-size-overflow.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/copilot-request-size-overflow.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-extension-factory-cache.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/extension-factory-cache.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-pre-prompt-compaction-no-continue.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/pre-prompt-compaction-no-continue.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-startup-session-rebind-duplicate-subscription.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/startup-session-rebind-duplicate-subscription.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-regressions-tree-during-streaming.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/regressions/tree-during-streaming.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-suite-virtual-models.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/suite/virtual-models.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-syntax-highlight.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/syntax-highlight.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-system-prompt-updates.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/system-prompt-updates.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-system-prompt.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/system-prompt.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-system-theme.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/system-theme.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-terminal-question.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/terminal-question.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-test-harness.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/test-harness.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-test-harness.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/test-harness.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-test-network-env.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/test-network-env.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-test-theme-colors.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/test-theme-colors.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-theme-controller.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/theme-controller.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-theme-detection.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/theme-detection.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-theme-export.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/theme-export.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-theme-picker.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/theme-picker.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-theme-style.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/theme-style.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-themed-text.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/themed-text.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-thinking-selector.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/thinking-selector.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-tool-execution-component.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/tool-execution-component.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-tool-renderer-examples.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/tool-renderer-examples.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-tool-result-images.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/tool-result-images.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-tool-search.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/tool-search.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-tool-system-prompt-contributions.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/tool-system-prompt-contributions.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-tools-manager.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/tools-manager.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-tools.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/tools.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-tree-selector.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/tree-selector.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-trigger-compact-extension.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/trigger-compact-extension.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-truncate-surrogates.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/truncate-surrogates.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-truncate-to-width.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/truncate-to-width.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-trust-manager.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/trust-manager.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-trust-selector.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/trust-selector.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-usage-totals.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/usage-totals.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-user-message.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/user-message.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-utilities.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/utilities.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-version-check.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/version-check.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `coding-agent.packages-coding-agent-test-virtual-models.test.ts.internal.test`

- Area: `coding-agent`, kind: `test`
- Upstream: `packages/coding-agent/test/virtual-models.test.ts`
- Dart: `pi_agent/lib/src/agent.dart`
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#79`

### `tui.packages-tui-src-index.ts.Box.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `Box`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.CancellableLoader.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `CancellableLoader`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.Editor.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `Editor`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.EditorComponent.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `EditorComponent`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.formatProgramStatus.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `formatProgramStatus`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.fuzzyFilter.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `fuzzyFilter`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.fuzzyMatch.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `fuzzyMatch`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.getNativeClipboard.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `getNativeClipboard`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.HStack.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `HStack`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.Input.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `Input`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.isAppleTerminalSession.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `isAppleTerminalSession`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.Loader.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `Loader`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.Markdown.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `Markdown`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.Marked.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `Marked`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.MouseRegion.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `MouseRegion`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.oklabToOkhslLightness.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `oklabToOkhslLightness`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.ProcessTerminal.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `ProcessTerminal`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.renderLatex.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `renderLatex`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.SettingsList.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `SettingsList`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.Spacer.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `Spacer`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.StdinBuffer.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `StdinBuffer`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.Text.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `Text`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.TruncatedText.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `TruncatedText`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.TuiAltScreen.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `TuiAltScreen`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.TuiMainScreen.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `TuiMainScreen`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-src-index.ts.WheelScrollLines.api`

- Area: `tui`, kind: `api`
- Upstream: `packages/tui/src/index.ts` → `WheelScrollLines`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-alt-screen-large-transcript-bench.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/alt-screen-large-transcript-bench.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-autocomplete-skill-slash.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/autocomplete-skill-slash.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-autocomplete.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/autocomplete.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-bug-regression-isimageline-startswith-bug.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/bug-regression-isimageline-startswith-bug.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-chat-simple.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/chat-simple.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-colors.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/colors.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-container.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/container.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-editor-history-keybindings.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/editor-history-keybindings.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-editor.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/editor.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-exit-restore.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/exit-restore.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-fixtures-clipboard-reader.cjs.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/fixtures/clipboard-reader.cjs`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-fixtures-clipboard-worker-test.c.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/fixtures/clipboard-worker-test.c`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-fixtures-clipboard-worker-test.cjs.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/fixtures/clipboard-worker-test.cjs`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-fixtures-clipboard-x11-test.c.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/fixtures/clipboard-x11-test.c`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-fixtures-exit-without-stop.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/fixtures/exit-without-stop.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-fuzzy.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/fuzzy.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-image-test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/image-test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-input.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/input.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-key-tester.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/key-tester.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-keybindings.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/keybindings.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-keys.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/keys.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-latex.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/latex.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-layout.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/layout.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-markdown.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/markdown.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-mouse-components.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/mouse-components.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-native-clipboard-linux.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/native-clipboard-linux.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-native-module-path.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/native-module-path.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-native-platform.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/native-platform.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-overlay-non-capturing.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/overlay-non-capturing.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-overlay-options.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/overlay-options.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-overlay-short-content.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/overlay-short-content.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-overlay-terminal-image.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/overlay-terminal-image.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-program-status.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/program-status.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-regression-overlay-cjk-boundary.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/regression-overlay-cjk-boundary.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-regression-regional-indicator-width.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/regression-regional-indicator-width.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-regression-sigwinch-kill-eacces.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/regression-sigwinch-kill-eacces.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-regression-slice-by-column-ansi-order.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/regression-slice-by-column-ansi-order.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-render-churn-bench.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/render-churn-bench.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-select-list.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/select-list.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-settings-list.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/settings-list.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-slice-graphemes.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/slice-graphemes.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-stdin-buffer.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/stdin-buffer.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-suspend-signal.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/suspend-signal.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-tab-width.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/tab-width.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-terminal-colors.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/terminal-colors.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-terminal-image.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/terminal-image.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-terminal.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/terminal.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-test-themes.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/test-themes.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-text.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/text.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-truncate-to-width.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/truncate-to-width.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-truncated-text.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/truncated-text.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-tui-alt-screen.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/tui-alt-screen.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-tui-cell-size-input.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/tui-cell-size-input.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-tui-overlay-style-leak.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/tui-overlay-style-leak.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-tui-render.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/tui-render.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-tui-shrink.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/tui-shrink.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-viewport-overwrite-repro.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/viewport-overwrite-repro.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-virtual-terminal.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/virtual-terminal.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-visible-width.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/visible-width.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-wheel-scroll.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/wheel-scroll.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-word-navigation.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/word-navigation.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `tui.packages-tui-test-wrap-ansi.test.ts.internal.test`

- Area: `tui`, kind: `test`
- Upstream: `packages/tui/test/wrap-ansi.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#82`

### `evals.packages-evals-src-cli.ts.internal.internal`

- Area: `evals`, kind: `internal`
- Upstream: `packages/evals/src/cli.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#86`

### `evals.packages-evals-test-acme-server.test.ts.internal.test`

- Area: `evals`, kind: `test`
- Upstream: `packages/evals/test/acme-server.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#86`

### `evals.packages-evals-test-comparison.test.ts.internal.test`

- Area: `evals`, kind: `test`
- Upstream: `packages/evals/test/comparison.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#86`

### `evals.packages-evals-test-configured-runtime.test.ts.internal.test`

- Area: `evals`, kind: `test`
- Upstream: `packages/evals/test/configured-runtime.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#86`

### `evals.packages-evals-test-harness.test.ts.internal.test`

- Area: `evals`, kind: `test`
- Upstream: `packages/evals/test/harness.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#86`

### `evals.packages-evals-test-plan.test.ts.internal.test`

- Area: `evals`, kind: `test`
- Upstream: `packages/evals/test/plan.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#86`

### `evals.packages-evals-test-report.test.ts.internal.test`

- Area: `evals`, kind: `test`
- Upstream: `packages/evals/test/report.test.ts`
- Dart: _(none)_
- Divergence: Scaffolded by build-registry; not yet assessed for parity.
- Issue: `#arrrrny/pi#86`

## Approved exclusions

- `durable.packages-durable-src-env-node.ts.NodeExecutionEnv.api`: Node.js execution environment (packages/durable/src/env/node.ts). The Dart port models durable behavior natively and ships no Node env: LocalExecutionEnv (pi_agent/lib/src/execution_env.dart) runs the host /bin/sh on the Linux/macOS pool hosts. The 2026-11-25 sync's only durable change here is Windows Git Bash discovery (findGitBashOfGitOnPath via `git var GIT_SHELL_PATH`), which has no Dart surface. Platform/scope exclusion per spec 004 (the port models, rather than ports, durable behavior).
- `durable.packages-durable-src-env-node.ts.NodeWatchOptions.api`: Node.js file-watcher options (packages/durable/src/env/node.ts, NodeWatchOptions). The Dart port ships no Node file watcher and models durable behavior natively; the 2026-11-25 sync did not change NodeWatchOptions. Platform/scope exclusion per spec 004 (the port models, rather than ports, durable behavior).
- `durable.packages-durable-test-env-line-scan.test.ts.internal.test`: Upstream NodeTextLineReader linear-time line-scan test (packages/durable/test/env-line-scan.test.ts). The Dart port has no streaming Node line reader; its JSONL and session readers use content.split('\n') and file.readAsLines() (pi_agent/lib/src/durable/storage/jsonl.dart, session_storage.dart), which are already linear-time, so the upstream quadratic-rescan fix has no Dart surface to port. Platform/scope exclusion per spec 004.
