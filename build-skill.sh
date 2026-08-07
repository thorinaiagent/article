#!/usr/bin/env bash
# Собирает автономный скилл rmr-editor: SKILL.md + все правила в references/,
# упаковывает в dist/rmr-editor.zip для раздачи коллегам.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/dist/rmr-editor"
REF="$OUT/references"

rm -rf "$OUT"
mkdir -p "$REF"

# SKILL.md — исходник скилла
cp "$ROOT/skill/SKILL.md" "$OUT/SKILL.md"

# Правила (структуру каталогов сохраняем, чтобы внутренние ссылки не ломались)
cp "$ROOT/redpolitika.md" "$REF/"
cp -R "$ROOT/voice" "$REF/"
cp -R "$ROOT/tasks" "$REF/"
cp -R "$ROOT/examples" "$REF/"
mkdir -p "$REF/refaktoring-articles"
cp "$ROOT/refaktoring-articles/правила-редактуры.md" "$REF/refaktoring-articles/"
cp "$ROOT/refaktoring-articles/make_docx.py" "$REF/refaktoring-articles/"
cp -R "$ROOT/refaktoring-articles/правила" "$REF/refaktoring-articles/"

# Упаковка
cd "$ROOT/dist"
rm -f rmr-editor.zip
zip -r -q rmr-editor.zip rmr-editor

echo "Готово: $ROOT/dist/rmr-editor.zip"
