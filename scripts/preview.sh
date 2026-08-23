#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
RESOLUTION=${RESOLUTION:-2880x1800}

if ! command -v grub2-theme-preview >/dev/null 2>&1; then
  echo "error: grub2-theme-preview is not installed" >&2
  echo "Install it together with QEMU, OVMF, mtools and xorriso." >&2
  exit 1
fi

exec grub2-theme-preview \
  "$ROOT_DIR/dist/tui-grub-theme" \
  --resolution "$RESOLUTION" \
  "$@"
