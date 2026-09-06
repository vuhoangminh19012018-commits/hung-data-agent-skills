# Project Policy — Data Mapping Stack

This file captures project-specific constraints. Skills should read it when a task touches the mapping architecture.

## Current target architecture

```text
Raw Excel / CSV / customs / accounting data
    -> Column profiling
    -> Row text / feature construction
    -> Normalization
    -> Exact + deterministic rule matching
    -> Qwen3-Embedding-0.6B embeddings
    -> PostgreSQL + pgvector candidate retrieval (Top-K, usually 5-20)
    -> Confidence gate
       -> high confidence: map with audit evidence
       -> low confidence: unresolved / human review
       -> optional future remote LLM fallback
    -> Excel audit/report
```

## Hard constraints

- Optimize for an older/limited local PC.
- Do not add a local generative Qwen LLM as a requirement.
- Keep the LLM fallback behind an interface/mock until explicitly enabled.
- Never call external/paid APIs without explicit user approval/configuration.
- Prefer deterministic matching before semantic matching.
- Keep PostgreSQL/pgvector optional for unit tests; core logic should be testable without a live DB.
- Never store database passwords in Excel, source code, committed `.env`, tests, or examples.

## Current vector conventions

- Embedding model: `Qwen/Qwen3-Embedding-0.6B`
- Expected embedding dimension: `1024` unless the actual model/config proves otherwise.
- Candidate retrieval: Top-K typically `5` to `20`.
- Database deployment currently targets PostgreSQL with `pgvector`.

## Data model concepts already in use

Concept master fields may include:
- `Concept_ID`
- `Canonical_Name`
- `Category`
- `Material`
- `Function_Use`
- `Model_Grade`
- `Specification`
- `Dimension`
- `CustomCode`
- `HS`
- `Language`
- `Verified`
- `Source`
- `Search_Text`

Alias master fields may include:
- `Alias_ID`
- `Concept_ID`
- `Alias_Name`
- `Verified`
- `Normalized_Alias`
- `Embedding_Status`

## Evaluation rule

Never measure mapping quality on examples that leaked from training/base construction into the test set. Build dirty/variant test examples only after the split, and keep the source concept identity available for scoring but out of retrieval text when it would leak the answer.
