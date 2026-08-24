#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROFILE_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
ROOT_DIR=$(CDPATH= cd -- "$PROFILE_DIR/../.." && pwd)
SRC_DIR="$PROFILE_DIR/src"
SHARED_SRC_DIR="$ROOT_DIR/src"
OUTPUT_DIR=${OUTPUT_DIR:-"$PROFILE_DIR/dist/tui-grub-theme"}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

require_command rsvg-convert
require_command grub-mkfont
require_command install

if [ -z "${NERD_FONT_FILE:-}" ]; then
  require_command fc-match
  NERD_FONT_FILE=$(fc-match "JetBrainsMono Nerd Font Mono" -f '%{file}\n' | head -n 1)
fi

if [ ! -r "$NERD_FONT_FILE" ]; then
  echo "error: Nerd Font is not readable: $NERD_FONT_FILE" >&2
  exit 1
fi

if command -v xmllint >/dev/null 2>&1; then
  xmllint --noout \
    "$SHARED_SRC_DIR/background.svg" \
    "$SHARED_SRC_DIR/highlight.svg" \
    "$SHARED_SRC_DIR/progress-track-w.svg" \
    "$SHARED_SRC_DIR/progress-track-c.svg" \
    "$SHARED_SRC_DIR/progress-track-e.svg" \
    "$SHARED_SRC_DIR/progress-fill-w.svg" \
    "$SHARED_SRC_DIR/progress-fill-c.svg" \
    "$SHARED_SRC_DIR/progress-fill-e.svg" \
    "$SHARED_SRC_DIR/icons/arch.svg" \
    "$SHARED_SRC_DIR/icons/windows.svg"
fi

install -d -m 0755 "$OUTPUT_DIR/icons"
install -m 0644 "$SRC_DIR/theme.txt" "$OUTPUT_DIR/theme.txt"

rsvg-convert -w 2560 -h 1600 "$SHARED_SRC_DIR/background.svg" -o "$OUTPUT_DIR/background.png"
rsvg-convert -w 1509 -h 112 "$SHARED_SRC_DIR/highlight.svg" -o "$OUTPUT_DIR/highlight_c.png"
rsvg-convert -w 3 -h 28 "$SHARED_SRC_DIR/progress-track-w.svg" -o "$OUTPUT_DIR/progress-track_w.png"
rsvg-convert -w 1 -h 28 "$SHARED_SRC_DIR/progress-track-c.svg" -o "$OUTPUT_DIR/progress-track_c.png"
rsvg-convert -w 3 -h 28 "$SHARED_SRC_DIR/progress-track-e.svg" -o "$OUTPUT_DIR/progress-track_e.png"
rsvg-convert -w 3 -h 28 "$SHARED_SRC_DIR/progress-fill-w.svg" -o "$OUTPUT_DIR/progress-fill_w.png"
rsvg-convert -w 1 -h 28 "$SHARED_SRC_DIR/progress-fill-c.svg" -o "$OUTPUT_DIR/progress-fill_c.png"
rsvg-convert -w 3 -h 28 "$SHARED_SRC_DIR/progress-fill-e.svg" -o "$OUTPUT_DIR/progress-fill_e.png"
rsvg-convert -w 135 -h 46 "$SHARED_SRC_DIR/icons/arch.svg" -o "$OUTPUT_DIR/icons/arch.png"
rsvg-convert -w 135 -h 46 "$SHARED_SRC_DIR/icons/windows.svg" -o "$OUTPUT_DIR/icons/windows.png"

grub-mkfont \
  -n "JetBrains Mono Menu 33" \
  -s 33 \
  -r 0x20-0x7e \
  -o "$OUTPUT_DIR/JetBrainsMono-Menu-33.pf2" \
  "$NERD_FONT_FILE"

grub-mkfont \
  -n "JetBrains Mono Body 25" \
  -s 25 \
  -r 0x20-0x7e \
  -o "$OUTPUT_DIR/JetBrainsMono-Body-25.pf2" \
  "$NERD_FONT_FILE"

echo "Built 2560x1600 profile: $OUTPUT_DIR"
