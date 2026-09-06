---
name: systematic-debugging
description: Diagnose incorrect code, tests, SQL, Excel output, mapping results, or pipeline behavior by reproducing and isolating the failure before changing implementation. Use whenever something is wrong but the root cause is not yet proven.
---

# Systematic Debugging

## Rule
Do not patch symptoms before locating the failure boundary.

## Procedure
1. Capture one minimal failing example and expected result.
2. Reproduce the failure with a command, test, query, or small data sample.
3. Trace the value through pipeline stages and find the first stage where actual diverges from expected.
4. Form one root-cause hypothesis at a time.
5. Test the hypothesis with the smallest observation/change possible.
6. Add or update a regression test that fails for the original bug.
7. Make the smallest implementation fix.
8. Re-run the focused reproduction.
9. Run the relevant regression suite.

## Data pipeline checkpoints
Inspect separately:
`raw -> parsed -> normalized -> exact/rule -> candidate retrieval -> score/confidence -> selected mapping -> report`.

## Anti-patterns
- changing thresholds before confirming the candidate set is correct,
- using embeddings to hide a normalization bug,
- rewriting multiple modules while the failure stage is unknown,
- accepting one passing example as proof of a general fix.
