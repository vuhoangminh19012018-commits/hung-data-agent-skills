---
name: understand-change
description: Translate a coding or data request into concrete acceptance criteria before implementation. Use for behavior changes, new features, ambiguous data rules, or changes where a wrong interpretation could create silent data errors.
---

# Understand Change

## Goal
Prevent the agent from coding the first plausible interpretation of the request.

## Procedure
1. Restate the requested outcome in operational terms.
2. Identify the input unit, expected output, invariants, and failure behavior.
3. Search existing code/tests/docs for current behavior and domain terminology.
4. Convert the request into a short acceptance checklist.
5. Identify edge cases that can create silent false positives or data loss.
6. Prefer existing terminology and interfaces over inventing new abstractions.
7. If the user has already provided a business rule, treat it as the source of truth; do not ask again.

## For data mapping
Define:
- which columns are identifiers versus descriptions versus noise,
- which normalization is allowed,
- whether matching is per row, PO, PART NO, concept, alias, or another business key,
- how duplicates are handled,
- what counts as a confident automatic match,
- what must remain for manual review.

## Exit condition
Do not implement until the acceptance criteria are specific enough to test.
