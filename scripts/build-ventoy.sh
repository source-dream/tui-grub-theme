#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
SRC_DIR="$ROOT_DIR/ventoy/src"
OUTPUT_ROOT=${OUTPUT_ROOT:-"$ROOT_DIR/ventoy/dist/ventoy"}
THEME_DIR="$OUTPUT_ROOT/theme/xiaoxin-tui"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

require_command rsvg-convert
require_command grub-mkfont
require_command install
require_command fc-match

NERD_FONT_FILE=${NERD_FONT_FILE:-$(fc-match "JetBrainsMono Nerd Font Mono" -f '%{file}\n' | head -n 1)}
CJK_FONT_FILE=${CJK_FONT_FILE:-$(fc-match "Noto Sans Mono CJK SC" -f '%{file}\n' | head -n 1)}
CJK_FONT_INDEX=${CJK_FONT_INDEX:-$(fc-match "Noto Sans Mono CJK SC" -f '%{index}\n' | head -n 1)}

for font_file in "$NERD_FONT_FILE" "$CJK_FONT_FILE"; do
  if [ ! -r "$font_file" ]; then
    echo "error: font is not readable: $font_file" >&2
    exit 1
  fi
done

if command -v xmllint >/dev/null 2>&1; then
  find "$SRC_DIR" -name '*.svg' -type f -exec xmllint --noout {} +
fi

install -d -m 0755 "$THEME_DIR/icons"
install -m 0644 "$SRC_DIR/theme.txt" "$THEME_DIR/theme.txt"
install -m 0644 "$SRC_DIR/ventoy.json" "$OUTPUT_ROOT/ventoy.json"

rsvg-convert -w 2880 -h 1800 "$SRC_DIR/background.svg" -o "$THEME_DIR/background.png"
rsvg-convert -w 1710 -h 92 "$SRC_DIR/highlight.svg" -o "$THEME_DIR/highlight_c.png"
rsvg-convert -w 10 -h 6 "$SRC_DIR/scrollbar_n.svg" -o "$THEME_DIR/scrollbar_thumb_n.png"
rsvg-convert -w 10 -h 8 "$SRC_DIR/scrollbar_c.svg" -o "$THEME_DIR/scrollbar_thumb_c.png"
rsvg-convert -w 10 -h 6 "$SRC_DIR/scrollbar_s.svg" -o "$THEME_DIR/scrollbar_thumb_s.png"
rsvg-convert -w 10 -h 6 "$SRC_DIR/scrollbar_frame_n.svg" -o "$THEME_DIR/scrollbar_frame_n.png"
rsvg-convert -w 10 -h 8 "$SRC_DIR/scrollbar_frame_c.svg" -o "$THEME_DIR/scrollbar_frame_c.png"
rsvg-convert -w 10 -h 6 "$SRC_DIR/scrollbar_frame_s.svg" -o "$THEME_DIR/scrollbar_frame_s.png"

for icon_source in "$SRC_DIR"/icons/*.svg; do
  icon_name=$(basename "$icon_source" .svg)
  rsvg-convert -w 64 -h 48 "$icon_source" -o "$THEME_DIR/icons/$icon_name.png"
done

grub-mkfont \
  -n "JetBrains Mono Ventoy 24" \
  -s 24 \
  -r 0x20-0x7e \
  -o "$THEME_DIR/JetBrainsMono-Ventoy-24.pf2" \
  "$NERD_FONT_FILE"

grub-mkfont \
  -i "$CJK_FONT_INDEX" \
  -n "Noto Sans Mono CJK SC Menu 28" \
  -s 28 \
  -r 0x20-0x024f,0x2000-0x206f,0x3000-0x303f,0x3400-0x4dbf,0x4e00-0x9fff,0xff00-0xffef \
  -o "$THEME_DIR/NotoSansMonoCJKSC-Menu-28.pf2" \
  "$CJK_FONT_FILE"

echo "Built Ventoy package: $OUTPUT_ROOT"
