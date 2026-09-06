---
name: profile-tabular-data
description: Profile messy Excel or CSV data before mapping. Use when deciding which columns carry identifiers, descriptions, categories, dates, noise, or candidate matching information, or when adapting the mapping pipeline to a new company/file format.
---

# Profile Tabular Data

## Goal
Understand data semantics before building matching text or rules.

## Procedure
1. Enumerate sheets/tables, row counts, headers, data types, null rates, and duplicate rates.
2. Sample real values from each candidate column.
3. Classify columns as:
   - stable business identifiers/codes,
   - names/descriptions,
   - categorical attributes,
   - numeric/measurement/specification,
   - dates/timestamps,
   - operational/admin noise,
   - unknown.
4. Detect columns whose header is misleading relative to values.
5. Identify fields that should participate in exact matching versus semantic text.
6. Record transformations; do not silently mutate the source workbook.
7. Produce a concise column profile and recommended matching fields.

## Rules
- Do not automatically embed every column.
- Dates/timestamps and row numbers are usually context/noise unless the business rule says otherwise.
- Keep raw values available for audit.
- If codes such as PART NO are strong identifiers, test deterministic normalization/matching before semantic search.
