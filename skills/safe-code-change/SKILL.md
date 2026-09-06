---
name: safe-code-change
description: Implement a minimal, testable change in an existing repository while preserving unrelated behavior and local work. Use after the requested behavior and failure boundary are understood.
---

# Safe Code Change

## Principles
- Small diff beats broad rewrite.
- Reuse existing interfaces when possible.
- Separate behavior changes from cosmetic refactors.
- Keep optional heavy dependencies behind interfaces.

## Procedure
1. Read the exact functions/modules to change and their callers/tests.
2. Add or identify the focused test proving the requested behavior.
3. Change only the necessary code path.
4. Keep backward compatibility unless the request explicitly changes the contract.
5. Avoid introducing new dependencies unless they materially simplify the required behavior.
6. Run formatting/lint/type checks only if the project already uses them or the change requires them.
7. Run focused tests, then relevant regression tests.
8. Inspect the final diff for accidental edits, debug output, secrets, and dead code.

## For lightweight local projects
Do not move deterministic logic into an LLM. Do not add GPU/local-generative-model requirements merely because they are convenient to the agent.
