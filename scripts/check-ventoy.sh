#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
SRC_DIR="$ROOT_DIR/ventoy/src"
OUTPUT_ROOT="$ROOT_DIR/ventoy/dist/ventoy"
THEME_DIR="$OUTPUT_ROOT/theme/xiaoxin-tui"

sh -n "$ROOT_DIR/scripts/build-ventoy.sh"
jq empty "$SRC_DIR/ventoy.json"
jq empty "$OUTPUT_ROOT/ventoy.json"
cmp "$SRC_DIR/ventoy.json" "$OUTPUT_ROOT/ventoy.json"
cmp "$SRC_DIR/theme.txt" "$THEME_DIR/theme.txt"

if command -v xmllint >/dev/null 2>&1; then
  find "$SRC_DIR" -name '*.svg' -type f -exec xmllint --noout {} +
fi

for file in \
  background.png \
  highlight_c.png \
  scrollbar_frame_n.png \
  scrollbar_frame_c.png \
  scrollbar_frame_s.png \
  scrollbar_thumb_n.png \
  scrollbar_thumb_c.png \
  scrollbar_thumb_s.png \
  JetBrainsMono-Ventoy-24.pf2 \
  NotoSansMonoCJKSC-Menu-28.pf2 \
  theme.txt; do
  if [ ! -s "$THEME_DIR/$file" ]; then
    echo "error: missing or empty Ventoy theme file: $file" >&2
    exit 1
  fi
done

for icon in arch linux windows vtoydir vtoyefi vtoyimg vtoyiso vtoyret vtoyvhd vtoyvtoy vtoywim; do
  if [ ! -s "$THEME_DIR/icons/$icon.png" ]; then
    echo "error: missing or empty Ventoy icon: $icon.png" >&2
    exit 1
  fi
done

if command -v identify >/dev/null 2>&1; then
  [ "$(identify -format '%wx%h' "$THEME_DIR/background.png")" = "2880x1800" ]
  [ "$(identify -format '%wx%h' "$THEME_DIR/highlight_c.png")" = "1710x92" ]
fi

file "$THEME_DIR/JetBrainsMono-Ventoy-24.pf2" | grep -q "GRUB2 font"
file "$THEME_DIR/NotoSansMonoCJKSC-Menu-28.pf2" | grep -q "GRUB2 font"

echo "Ventoy theme checks passed."
