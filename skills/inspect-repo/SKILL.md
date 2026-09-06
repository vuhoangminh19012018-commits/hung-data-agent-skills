---
name: inspect-repo
description: Inspect an existing code repository before changing it. Use when the user says check git, continue work, inspect the project, or when branch state, local changes, test status, or project structure is unknown.
---

# Inspect Repository

## Goal
Understand the current repository state without modifying or deleting user work.

## Procedure
1. Confirm the working directory and repository root.
2. Run `git status --short --branch`.
3. Read the current branch and HEAD commit.
4. Inspect recent commits only as needed to understand the current phase.
5. Identify untracked/modified files and treat them as user work unless proven otherwise.
6. Find project instructions such as `AGENTS.md`, `README`, test config, and relevant docs.
7. Identify the smallest test/smoke command that establishes a baseline.
8. If requested to continue a previous task, inspect the files/commits tied to that task before editing.

## Safety rules
- Never run `git reset --hard`, `git clean`, checkout-overwrite, or destructive restore unless the user explicitly requests that exact destructive action.
- Never silently revert unrelated local changes.
- Do not create commits just to make the tree look clean.
- Do not infer that an untracked file is disposable.

## Output
Before editing, be able to state: branch, HEAD, local-change state, relevant project instructions, and baseline test status or why it cannot be run.
