from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


def parse_frontmatter(text: str) -> dict[str, str]:
    if not text.startswith("---\n"):
        raise ValueError("missing YAML frontmatter start")
    end = text.find("\n---\n", 4)
    if end < 0:
        raise ValueError("missing YAML frontmatter end")
    meta: dict[str, str] = {}
    for line in text[4:end].splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        if key.strip() in {"name", "description"}:
            meta[key.strip()] = value.strip().strip('"').strip("'")
    return meta


def main() -> int:
    errors: list[str] = []
    checked = 0
    for skill_dir in sorted(p for p in SKILLS.iterdir() if p.is_dir()):
        checked += 1
        skill_file = skill_dir / "SKILL.md"
        if not skill_file.exists():
            errors.append(f"{skill_dir.name}: missing SKILL.md")
            continue
        try:
            text = skill_file.read_text(encoding="utf-8")
            meta = parse_frontmatter(text)
        except Exception as exc:
            errors.append(f"{skill_dir.name}: {exc}")
            continue
        name = meta.get("name", "")
        desc = meta.get("description", "")
        if not name:
            errors.append(f"{skill_dir.name}: missing name")
        elif name != skill_dir.name:
            errors.append(f"{skill_dir.name}: name '{name}' must match directory")
        elif len(name) > 64 or not NAME_RE.fullmatch(name):
            errors.append(f"{skill_dir.name}: invalid name format")
        if not desc:
            errors.append(f"{skill_dir.name}: missing description")
        elif len(desc) > 1024:
            errors.append(f"{skill_dir.name}: description > 1024 chars")
        if len(text.splitlines()) > 500:
            errors.append(f"{skill_dir.name}: SKILL.md > 500 lines; move detail to references")

    if errors:
        print(f"FAIL: {checked} skills checked")
        for err in errors:
            print(f"- {err}")
        return 1
    print(f"PASS: {checked} skills valid")
    return 0


if __name__ == "__main__":
    sys.exit(main())
