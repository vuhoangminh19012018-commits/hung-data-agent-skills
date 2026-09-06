# Hung Data Agent Skills

A small, opinionated Agent Skills repository for data-mapping and coding-agent work.

The goal is not to make the model "smarter". The goal is to make the agent work in a repeatable, safe sequence:

**inspect -> understand -> plan -> make the smallest change -> test -> regression-check -> report evidence**

For data mapping, the target pipeline is:

**raw Excel/CSV -> profile -> normalize -> exact/rule match -> Qwen3-Embedding-0.6B -> pgvector Top-K -> confidence gate -> optional remote LLM fallback -> Excel audit**

## Design principles

1. Local-first and lightweight.
2. Do not run a local generative LLM by default.
3. Never call a paid/external LLM API unless the user explicitly enables it.
4. Exact/rule matching comes before embeddings.
5. Embeddings retrieve candidates; they do not silently become ground truth.
6. Every automatic mapping needs evidence and a confidence path.
7. Never declare success without running the relevant tests/checks.
8. Prefer small, reversible code changes over broad rewrites.
9. Preserve Git history and do not clean/reset unrelated user changes.
10. Report what changed, what was tested, and what remains uncertain.

## Included skills

| Skill | Use it when |
|---|---|
| `inspect-repo` | Starting work, user says "check git", or repo state is unknown |
| `understand-change` | A request can affect behavior/data and needs requirements translated into acceptance criteria |
| `systematic-debugging` | A test, pipeline, import, SQL query, or output is wrong |
| `safe-code-change` | Editing an existing codebase without breaking unrelated behavior |
| `verify-before-finish` | Before saying a task is done |
| `profile-tabular-data` | Understanding Excel/CSV columns and which fields matter |
| `normalize-business-keys` | Normalizing PART NO, codes, descriptions, aliases and technical tokens |
| `build-mapping-pipeline` | Implementing or changing the exact/rule -> embedding -> fallback pipeline |
| `embedding-pgvector` | Qwen3-Embedding-0.6B, PostgreSQL/pgvector, candidate retrieval and indexing |
| `evaluate-mapping-quality` | Train/test split, dirty variants, leakage checks, thresholds and quality metrics |
| `excel-audit-report` | Producing human-reviewable Excel outputs and exception lists |
| `database-safe-change` | Schema/data migrations and SQL changes that must be reversible |

## Recommended default sequence

For a normal feature/change:

1. `inspect-repo`
2. `understand-change`
3. `safe-code-change`
4. `verify-before-finish`

For a bug:

1. `inspect-repo`
2. `systematic-debugging`
3. `safe-code-change`
4. `verify-before-finish`

For mapping/data work:

1. `profile-tabular-data`
2. `normalize-business-keys`
3. `build-mapping-pipeline`
4. `embedding-pgvector` only when rules are insufficient
5. `evaluate-mapping-quality`
6. `excel-audit-report`
7. `verify-before-finish`

## Install

Agent Skills are portable folders. The current open Agent Skills format requires a folder containing `SKILL.md`; optional scripts/references/assets can live beside it.

### Codex / compatible agents

Copy the skill folders to your user skills directory (commonly `~/.agents/skills`) or a client-supported project skills directory.

Windows PowerShell helper:

```powershell
./scripts/install.ps1 -Target "$HOME/.agents/skills"
```

Linux/macOS helper:

```bash
./scripts/install.sh "$HOME/.agents/skills"
```

### Use per project

Copy `templates/AGENTS.md` into the target code repository and adjust commands if needed. It tells the agent which workflow to follow and keeps project constraints visible.

## Validate

```bash
python scripts/validate_skills.py
```

The validator checks that every skill directory has a `SKILL.md`, that the frontmatter has `name` and `description`, and that the `name` matches the directory.

## Customize

Edit `config/project-policy.md` when the project changes. Detailed project/domain conventions are intentionally outside individual `SKILL.md` files so the skills stay small and reusable.
