# Operating Workflow

## 1. Inspect
Establish repository state, branch, changed files, test commands, and project constraints. Never erase unrelated user work.

## 2. Understand
Translate the request into observable acceptance criteria. For data tasks, define the matching unit, normalization rules, allowable false positives, and output/audit requirements.

## 3. Baseline
Run the smallest existing test/smoke check that proves current behavior. If there is no test, create a focused reproducible example before editing behavior.

## 4. Change minimally
Modify the smallest surface needed. Reuse existing interfaces. Avoid unrelated refactors while fixing a bug.

## 5. Verify locally
Run focused tests first, then the relevant regression suite. For mapping changes, compare quality metrics and inspect representative false-positive/false-negative examples.

## 6. Audit
For automated mapping, preserve evidence: normalized inputs, rule hit or candidate score, confidence, chosen concept, and reason for manual review.

## 7. Finish with evidence
Report commands run, pass/fail counts, files changed, behavior changed, known limitations, and Git status.
