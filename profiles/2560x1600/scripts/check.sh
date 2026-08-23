#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROFILE_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
ROOT_DIR=$(CDPATH= cd -- "$PROFILE_DIR/../.." && pwd)
DIST_DIR="$PROFILE_DIR/dist/tui-grub-theme"

for script in "$SCRIPT_DIR"/*.sh; do
  sh -n "$script"
done

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "$SCRIPT_DIR"/*.sh
fi

if command -v xmllint >/dev/null 2>&1; then
  xmllint --noout \
    "$ROOT_DIR/src/background.svg" \
    "$ROOT_DIR/src/progress-track-w.svg" \
    "$ROOT_DIR/src/progress-track-c.svg" \
    "$ROOT_DIR/src/progress-track-e.svg" \
    "$ROOT_DIR/src/progress-fill-w.svg" \
    "$ROOT_DIR/src/progress-fill-c.svg" \
    "$ROOT_DIR/src/progress-fill-e.svg"
fi

for file in \
  background.png \
  highlight_c.png \
  progress-track_w.png \
  progress-track_c.png \
  progress-track_e.png \
  progress-fill_w.png \
  progress-fill_c.png \
  progress-fill_e.png \
  JetBrainsMono-Menu-33.pf2 \
  JetBrainsMono-Body-25.pf2 \
  theme.txt \
  icons/arch.png \
  icons/windows.png; do
  if [ ! -s "$DIST_DIR/$file" ]; then
    echo "error: missing or empty distribution file: $file" >&2
    exit 1
  fi
done

cmp "$PROFILE_DIR/src/theme.txt" "$DIST_DIR/theme.txt"

if command -v identify >/dev/null 2>&1; then
  [ "$(identify -format '%wx%h' "$DIST_DIR/background.png")" = "2560x1600" ]
  [ "$(identify -format '%wx%h' "$DIST_DIR/highlight_c.png")" = "1509x112" ]
  [ "$(identify -format '%wx%h' "$DIST_DIR/progress-track_w.png")" = "4x7" ]
  [ "$(identify -format '%wx%h' "$DIST_DIR/progress-track_c.png")" = "1x7" ]
  [ "$(identify -format '%wx%h' "$DIST_DIR/progress-track_e.png")" = "4x7" ]
  [ "$(identify -format '%wx%h' "$DIST_DIR/progress-fill_w.png")" = "4x7" ]
  [ "$(identify -format '%wx%h' "$DIST_DIR/progress-fill_c.png")" = "1x7" ]
  [ "$(identify -format '%wx%h' "$DIST_DIR/progress-fill_e.png")" = "4x7" ]
  [ "$(identify -format '%wx%h' "$DIST_DIR/icons/arch.png")" = "135x46" ]
  [ "$(identify -format '%wx%h' "$DIST_DIR/icons/windows.png")" = "135x46" ]
fi

file "$DIST_DIR/JetBrainsMono-Menu-33.pf2" | grep -q "GRUB2 font"
file "$DIST_DIR/JetBrainsMono-Body-25.pf2" | grep -q "GRUB2 font"

echo "2560x1600 profile checks passed."
