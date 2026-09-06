---
name: excel-audit-report
description: Design or produce an Excel-friendly audit output for data mapping so users can understand matched, unresolved, duplicate, and suspicious rows. Use when mapping results must be reviewed by business users rather than only printed to logs.
---

# Excel Audit Report

## Goal
Make mapping decisions inspectable without reading code or SQL.

## Recommended views
1. Summary: counts by method/confidence/review status.
2. Mapped rows: source key, source description, normalized key, chosen concept, method, score/confidence, evidence.
3. Unresolved rows: enough source context to fix aliases/rules.
4. Suspicious/low-margin rows: accepted candidates that merit review.
5. Duplicates/conflicts: one source mapping to multiple verified concepts or competing aliases.
6. Quality comparison: when evaluating algorithms, show method-level metrics.

## Rules
- Preserve original source values next to normalized values.
- Do not hide unresolved rows.
- Use stable IDs such as `Concept_ID`/`Alias_ID` when available, not only display names.
- Keep report generation separate from core matching logic so it can be retested independently.
