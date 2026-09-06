---
name: embedding-pgvector
description: Implement and troubleshoot Qwen3-Embedding-0.6B plus PostgreSQL/pgvector semantic retrieval for unresolved business-data mapping. Use for embedding generation, vector schema/indexes, Top-K candidate search, similarity metrics, batching, and lightweight local operation.
---

# Embedding + pgvector

## Project default
Read `../../config/project-policy.md` when available. Current target model is `Qwen/Qwen3-Embedding-0.6B`, with 1024-dimensional vectors unless runtime/model metadata proves otherwise.

## Principles
- Generate embeddings only for fields/search text that carry matching meaning.
- Cache/reuse embeddings for verified concepts and aliases.
- Do not recompute all vectors when only a small subset changed.
- Keep model name/version and normalization/search-text recipe auditable.
- Unit-test ranking logic without requiring a live PostgreSQL instance.

## Retrieval flow
1. Build stable search text.
2. Generate query embedding.
3. Retrieve Top-K candidates, usually 5-20.
4. Return scores and candidate metadata.
5. Pass candidates to a separate decision/confidence layer.

## Database rules
- Validate vector dimension against the actual embedding output.
- Use parameterized SQL.
- Keep secrets outside source/workbooks.
- Add indexes only after measuring query needs/data volume.
- Confirm the similarity operator/metric is consistent with how thresholds are interpreted.

## Debugging
When quality is poor, separately inspect search-text construction, embedding model output, vector storage/dimension, distance metric, candidate set, and acceptance threshold.
