#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
DIST_DIR="$ROOT_DIR/dist/tui-grub-theme"

for script in "$ROOT_DIR"/scripts/*.sh; do
  sh -n "$script"
done

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "$ROOT_DIR"/scripts/*.sh
fi

if command -v xmllint >/dev/null 2>&1; then
  xmllint --noout \
    "$ROOT_DIR/src/background.svg" \
    "$ROOT_DIR/src/highlight.svg" \
    "$ROOT_DIR/src/icons/arch.svg" \
    "$ROOT_DIR/src/icons/windows.svg"
fi

for file in \
  background.png \
  highlight_c.png \
  JetBrainsMono-Menu-37.pf2 \
  JetBrainsMono-Body-28.pf2 \
  theme.txt \
  icons/arch.png \
  icons/windows.png; do
  if [ ! -s "$DIST_DIR/$file" ]; then
    echo "error: missing or empty distribution file: $file" >&2
    exit 1
  fi
done

cmp "$ROOT_DIR/src/theme.txt" "$DIST_DIR/theme.txt"

if command -v identify >/dev/null 2>&1; then
  [ "$(identify -format '%wx%h' "$DIST_DIR/background.png")" = "2880x1800" ]
  [ "$(identify -format '%wx%h' "$DIST_DIR/highlight_c.png")" = "1698x126" ]
  [ "$(identify -format '%wx%h' "$DIST_DIR/icons/arch.png")" = "152x52" ]
  [ "$(identify -format '%wx%h' "$DIST_DIR/icons/windows.png")" = "152x52" ]
fi

file "$DIST_DIR/JetBrainsMono-Menu-37.pf2" | grep -q "GRUB2 font"
file "$DIST_DIR/JetBrainsMono-Body-28.pf2" | grep -q "GRUB2 font"

echo "Default 2880x1800 profile checks passed."
