# AGENTS.md — Data Mapping Project

## Project goal
Build and maintain a lightweight, auditable mapping pipeline for messy Excel/CSV/business data.

## Architecture
Read `<skills-repo>/config/project-policy.md` before architecture changes.

Preferred path:
`profile -> normalize -> exact/rule -> embedding retrieval -> confidence -> unresolved/fallback -> Excel audit`.

## Non-negotiable rules
- Start repo work by inspecting Git state. Never discard unrelated local changes.
- Make the smallest correct change.
- Reproduce bugs before fixing them when practical.
- Run focused tests, then relevant regression tests.
- Do not introduce a local generative LLM requirement.
- Do not enable external LLM/API calls unless explicitly requested.
- Do not store secrets in the repository or workbook.
- Do not treat nearest-vector result as ground truth.
- Keep unresolved/low-confidence rows visible for review.

## Skills to use
- `inspect-repo`: repo/Git state and baseline.
- `understand-change`: convert request into acceptance criteria.
- `systematic-debugging`: reproduce and isolate failures.
- `safe-code-change`: implement minimal changes safely.
- `profile-tabular-data`: inspect Excel/CSV structure.
- `normalize-business-keys`: PART NO/code/text normalization.
- `build-mapping-pipeline`: deterministic + semantic pipeline changes.
- `embedding-pgvector`: vector generation/retrieval/indexing.
- `evaluate-mapping-quality`: leakage-safe evaluation and threshold tuning.
- `excel-audit-report`: user-facing audit workbook/output.
- `database-safe-change`: reversible DB/schema changes.
- `verify-before-finish`: mandatory final verification/reporting.

## Completion format
Use the contract in `<skills-repo>/docs/OUTPUT_CONTRACT.md`.
