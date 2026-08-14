#!/usr/bin/env bash
# Собирает автономный скилл rmr-editor: SKILL.md + все правила в references/,
# пакует в dist/rmr-editor.zip для раздачи коллегам и загрузки в приложение Claude.
# Имена файлов в архиве — латиницей: claude.ai не принимает кириллицу в путях.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/dist/rmr-editor"
REF="$OUT/references"

# Транслитерация кириллических имён файлов в латиницу (нижний регистр).
# Схема совпадает с ручными именами правил ниже: х→h, ж→zh, й/ы→y, ё→yo и т. д.
# LC_ALL=C — чтобы sed на macOS матчил кириллицу побайтно.
translit() {
  printf '%s' "$1" | LC_ALL=C sed \
    -e 's/а/a/g' -e 's/б/b/g' -e 's/в/v/g' -e 's/г/g/g' -e 's/д/d/g' \
    -e 's/е/e/g' -e 's/ё/yo/g' -e 's/ж/zh/g' -e 's/з/z/g' -e 's/и/i/g' \
    -e 's/й/y/g' -e 's/к/k/g' -e 's/л/l/g' -e 's/м/m/g' -e 's/н/n/g' \
    -e 's/о/o/g' -e 's/п/p/g' -e 's/р/r/g' -e 's/с/s/g' -e 's/т/t/g' \
    -e 's/у/u/g' -e 's/ф/f/g' -e 's/х/h/g' -e 's/ц/ts/g' -e 's/ч/ch/g' \
    -e 's/ш/sh/g' -e 's/щ/sch/g' -e 's/ъ//g' -e 's/ы/y/g' -e 's/ь//g' \
    -e 's/э/e/g' -e 's/ю/yu/g' -e 's/я/ya/g'
}

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

# Пары до/после: копируем всё из before-after с транслитом имён,
# чтобы новые пары подхватывались автоматически.
for src in "$ROOT"/examples/before-after/*; do
  [ -f "$src" ] || continue
  cp "$src" "$REF/examples/before-after/$(translit "$(basename "$src")")"
done

# Чиним внутренние ссылки в скопированных файлах под латинские имена.
# Статичные замены для правил + динамические для всех пар before-after
# (имена примеров транслитерируются той же функцией, что и при копировании).
# LC_ALL=C — чтобы sed на macOS матчил кириллицу побайтно и не ругался.
SED_ARGS=(
  -e 's#как-писать-и-редактировать\.md#kak-pisat-i-redaktirovat.md#g'
  -e 's#голос-на-хабре\.md#golos-na-habre.md#g'
  -e 's#внутриком\.md#vnutrikom.md#g'
  -e 's#анонс-выпуска\.md#anons-vypuska.md#g'
  -e 's#сборка-из-фактуры\.md#sborka-iz-faktury.md#g'
  -e 's#бюллетень\.md#byulleten.md#g'
  -e 's#пост-rnd\.md#post-rnd.md#g'
  -e 's#правила-редактуры\.md#pravila-redaktury.md#g'
  -e 's#правила/redpolitika\.md#pravila/redpolitika.md#g'
)
for src in "$ROOT"/examples/before-after/*; do
  [ -f "$src" ] || continue
  base="$(basename "$src")"
  esc="$(printf '%s' "$base" | sed 's/\./\\./g')"
  SED_ARGS+=( -e "s#${esc}#$(translit "$base")#g" )
done

find "$REF" -type f \( -name '*.md' -o -name '*.py' \) -print0 | while IFS= read -r -d '' f; do
  LC_ALL=C sed -i '' "${SED_ARGS[@]}" "$f"
done

# Упаковка
cd "$ROOT/dist"
rm -f rmr-editor.zip
zip -r -q rmr-editor.zip rmr-editor

echo "Готово: $ROOT/dist/rmr-editor.zip"
