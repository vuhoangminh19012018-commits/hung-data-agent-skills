---
name: normalize-business-keys
description: Normalize PART NO, FG codes, aliases, product descriptions, technical tokens, and business identifiers for deterministic matching. Use when punctuation, spaces, case, separators, formatting differences, or company-specific spelling cause equivalent values not to match.
---

# Normalize Business Keys

## Principle
Normalization should reduce formatting noise without erasing meaningful distinctions.

## Keep multiple forms
For important fields retain:
- raw value,
- normalized display form,
- compact comparison key,
- extracted technical tokens when useful.

## Typical PART NO / code normalization
Apply only rules validated for that field, such as:
1. Unicode normalization.
2. Trim surrounding whitespace.
3. Case fold.
4. Normalize repeated internal whitespace.
5. Optionally remove separators such as spaces, `.`, `,`, `-`, `_`, `/`, `\`, parentheses when business rules say those separators are non-semantic.
6. Preserve digits and letters.
7. Do not remove characters that distinguish valid codes unless tested.

## Description normalization
- normalize Unicode/case/spacing,
- standardize known units/abbreviations through explicit tables,
- preserve technical numbers, model names, grade/specification tokens,
- avoid aggressive stopword removal when short descriptions rely on those words.

## Verification
Build paired examples of values that should match and near-miss values that must remain different. A normalization rule is not acceptable if it improves recall by creating uncontrolled false positives.
