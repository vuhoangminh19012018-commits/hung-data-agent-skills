# Mapping Architecture

## Principle
Use the cheapest, most explainable matcher capable of making a reliable decision.

## Stages

### A. Profile
Classify columns into identifiers/codes, descriptions, categorical attributes, numeric/date fields, and administrative noise. Dates and timestamps should not automatically become semantic matching text.

### B. Normalize
Keep multiple representations rather than one destructive string:
- `raw_value`
- `normalized_general`
- `normalized_compact`
- extracted technical tokens
- normalized code/PART NO

### C. Deterministic matching
Try in order:
1. verified exact alias
2. exact canonical/business key
3. deterministic domain rules
4. guarded fuzzy/technical-token rules when justified

### D. Semantic retrieval
Only unresolved rows go to embeddings. Build query text from fields that carry meaning. Retrieve a small candidate set from pgvector.

### E. Decision gate
Candidate retrieval and mapping decision are separate. A nearest vector is not automatically a valid match. Use score, score margin, deterministic evidence, candidate metadata, and business constraints.

### F. Fallback
Low-confidence rows stay unresolved or are routed to future remote LLM/human review. The fallback must return structured reasoning/evidence and must never overwrite verified mappings silently.

### G. Audit
Every output row should be explainable later.
