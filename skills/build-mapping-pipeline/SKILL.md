---
name: build-mapping-pipeline
description: Build or modify a layered business-data mapping pipeline using normalization, exact/rule matching, semantic candidate retrieval, confidence gating, unresolved handling, and audit evidence. Use for customs/accounting/product mapping and concept/alias matching workflows.
---

# Build Mapping Pipeline

## Required order
Use this decision ladder unless a proven project rule requires otherwise:

1. Profile input fields.
2. Normalize relevant values.
3. Verified exact alias/business-key match.
4. Deterministic rule match.
5. Semantic retrieval only for unresolved rows.
6. Confidence/decision gate.
7. Low-confidence -> unresolved/human review or disabled future fallback.
8. Write full audit evidence.

## Architecture rule
Retrieval and decision are separate functions. `top1 candidate` is not equivalent to `accepted match`.

## Mapping result contract
Each row should expose at least:
- source row/key,
- normalized key/search text,
- method (`exact`, `rule`, `vector`, `fallback`, `unresolved`),
- chosen concept/alias when any,
- score and score margin when semantic,
- confidence bucket,
- evidence/reason,
- review flag.

## Fallback rule
A generative LLM fallback must be an optional interface. It must not be required for normal local execution and must not be silently enabled.

## Testing
Test each layer independently and test end-to-end precedence so a weaker semantic match cannot override a verified deterministic match.
