---
name: verify-before-finish
description: Require fresh evidence before claiming a coding, database, mapping, or report task is complete. Use at the end of every implementation or fix, especially before saying done, fixed, pass, synchronized, or clean.
---

# Verify Before Finish

## Mandatory checks
1. Run the most relevant focused test/reproduction after the final edit.
2. Run the relevant regression test suite or explain the concrete blocker.
3. Inspect `git diff --check` when in Git.
4. Inspect `git status --short --branch`.
5. For data changes, inspect representative output rows and exception/unresolved rows.
6. For mapping algorithms, report measured quality only from a leakage-safe evaluation set.

## Evidence standard
Never infer success from code appearance. Completion claims must be backed by commands/results from the current final state.

## Completion report
Follow `../../docs/OUTPUT_CONTRACT.md` when available.
