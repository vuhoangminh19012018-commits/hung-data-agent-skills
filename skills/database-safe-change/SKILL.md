---
name: database-safe-change
description: Make safe PostgreSQL/pgvector schema or data changes with explicit prechecks, reversible migrations, and post-verification. Use when modifying tables, vector columns, indexes, constraints, aliases/concepts, or synchronization logic.
---

# Database Safe Change

## Before changing
1. Inspect current schema/migration mechanism.
2. Identify data volume and whether the change rewrites large tables.
3. Confirm backup/rollback path for destructive operations.
4. Never embed credentials in code, SQL scripts, Excel, or committed config.

## Change rules
- Prefer migrations over ad-hoc manual edits.
- Make schema changes idempotent or guarded where practical.
- Use transactions for logically atomic changes when supported.
- Backfill in controlled batches if the operation is expensive.
- Keep vector dimension/model migration explicit; never silently mix incompatible embeddings.

## After changing
Verify schema, representative rows, row counts, constraints/indexes, application tests, and vector query behavior. Report exactly what was migrated and what remains pending.
