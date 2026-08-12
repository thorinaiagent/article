#!/usr/bin/env bash
# Собирает автономный скилл rmr-editor: SKILL.md + все правила в references/,
# пакует в dist/rmr-editor.zip для раздачи коллегам и загрузки в приложение Claude.
# Имена файлов в архиве — латиницей: claude.ai не принимает кириллицу в путях.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/dist/rmr-editor"
REF="$OUT/references"

rm -rf "$OUT"
mkdir -p "$REF/voice" "$REF/tasks" "$REF/refaktoring-articles/pravila" "$REF/examples/before-after"

# SKILL.md — исходник скилла (пути внутри уже латиницей)
cp "$ROOT/skill/SKILL.md" "$OUT/SKILL.md"

# Правила: копируем с транслитерацией имён (содержимое остаётся русским)
cp "$ROOT/redpolitika.md"                              "$REF/redpolitika.md"
cp "$ROOT/voice/как-писать-и-редактировать.md"         "$REF/voice/kak-pisat-i-redaktirovat.md"
cp "$ROOT/voice/голос-на-хабре.md"                     "$REF/voice/golos-na-habre.md"
cp "$ROOT/voice/внутриком.md"                          "$REF/voice/vnutrikom.md"
cp "$ROOT/tasks/бюллетень.md"                          "$REF/tasks/byulleten.md"
cp "$ROOT/tasks/анонс-выпуска.md"                      "$REF/tasks/anons-vypuska.md"
cp "$ROOT/tasks/пост-rnd.md"                           "$REF/tasks/post-rnd.md"
cp "$ROOT/tasks/сборка-из-фактуры.md"                  "$REF/tasks/sborka-iz-faktury.md"
cp "$ROOT/refaktoring-articles/правила-редактуры.md"   "$REF/refaktoring-articles/pravila-redaktury.md"
cp "$ROOT/refaktoring-articles/make_docx.py"           "$REF/refaktoring-articles/make_docx.py"
cp "$ROOT/refaktoring-articles/правила/redpolitika.md" "$REF/refaktoring-articles/pravila/redpolitika.md"
cp "$ROOT/examples/README.md"                          "$REF/examples/README.md"
cp "$ROOT/examples/before-after/антихрупкий-лидер-до.md"     "$REF/examples/before-after/antihrupkiy-lider-do.md"
cp "$ROOT/examples/before-after/антихрупкий-лидер-после.md"  "$REF/examples/before-after/antihrupkiy-lider-posle.md"
cp "$ROOT/examples/before-after/антихрупкий-лидер-разбор.md" "$REF/examples/before-after/antihrupkiy-lider-razbor.md"

# Чиним внутренние ссылки в скопированных файлах под новые латинские имена.
# LC_ALL=C — чтобы sed на macOS матчил кириллицу побайтно и не ругался.
find "$REF" -type f \( -name '*.md' -o -name '*.py' \) -print0 | while IFS= read -r -d '' f; do
  LC_ALL=C sed -i '' \
    -e 's#как-писать-и-редактировать\.md#kak-pisat-i-redaktirovat.md#g' \
    -e 's#голос-на-хабре\.md#golos-na-habre.md#g' \
    -e 's#внутриком\.md#vnutrikom.md#g' \
    -e 's#анонс-выпуска\.md#anons-vypuska.md#g' \
    -e 's#сборка-из-фактуры\.md#sborka-iz-faktury.md#g' \
    -e 's#бюллетень\.md#byulleten.md#g' \
    -e 's#пост-rnd\.md#post-rnd.md#g' \
    -e 's#правила-редактуры\.md#pravila-redaktury.md#g' \
    -e 's#антихрупкий-лидер-до\.md#antihrupkiy-lider-do.md#g' \
    -e 's#антихрупкий-лидер-после\.md#antihrupkiy-lider-posle.md#g' \
    -e 's#антихрупкий-лидер-разбор\.md#antihrupkiy-lider-razbor.md#g' \
    -e 's#правила/redpolitika\.md#pravila/redpolitika.md#g' \
    "$f"
done

# Упаковка
cd "$ROOT/dist"
rm -f rmr-editor.zip
zip -r -q rmr-editor.zip rmr-editor

echo "Готово: $ROOT/dist/rmr-editor.zip"
