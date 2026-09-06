#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:-$HOME/.agents/skills}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$TARGET"
for d in "$ROOT"/skills/*; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  rm -rf "$TARGET/$name"
  cp -R "$d" "$TARGET/$name"
  echo "Installed $name -> $TARGET/$name"
done
echo "Installed all Hung Data Agent Skills to $TARGET"
