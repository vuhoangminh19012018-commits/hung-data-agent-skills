---
name: evaluate-mapping-quality
description: Evaluate business-data matching quality without leakage. Use for train/test splits, dirty synthetic variants, benchmark comparisons, confidence thresholds, exact/fuzzy/embedding experiments, and deciding whether automatic mapping is safe.
---

# Evaluate Mapping Quality

## Core rule
Split source concepts/examples into train/base and test before generating dirty or alternate forms for evaluation. Never let test variants enter the alias/base index used to retrieve them.

## Procedure
1. Freeze the base/index population.
2. Create or identify a held-out labeled set.
3. Generate formatting noise/dirty variants only inside the held-out set when synthetic augmentation is needed.
4. Run each method on the same held-out examples.
5. Measure at least:
   - coverage,
   - top-1 accuracy,
   - top-K recall,
   - precision of auto-accepted matches,
   - unresolved rate,
   - false-positive rate.
6. For confidence thresholds, inspect score distributions and score margins, not only a single average.
7. Review concrete false positives and false negatives by category.
8. Compare methods such as technical-token rules, trigram/fuzzy matching, embedding retrieval, and combined gates on the same set.

## Priority
For business automation, high precision on auto-accepted rows is usually more important than forcing every row to map. Uncertain rows should remain reviewable.
