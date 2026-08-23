#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
DIST_DIR="$ROOT_DIR/dist/xiaoxin-tui"
THEME_DIR=${THEME_DIR:-/boot/grub/themes/xiaoxin-tui}
GRUB_DEFAULT_FILE=${GRUB_DEFAULT_FILE:-/etc/default/grub}
GRUB_CONFIG_FILE=${GRUB_CONFIG_FILE:-/boot/grub/grub.cfg}
GRUB_MKCONFIG=${GRUB_MKCONFIG:-grub-mkconfig}
GRUB_SCRIPT_CHECK=${GRUB_SCRIPT_CHECK:-grub-script-check}
DRY_RUN=0
BUILD_FIRST=0

usage() {
  cat <<'EOF'
Usage: ./scripts/install.sh [--dry-run] [--build]

  --dry-run  Print the files and configuration that would be changed.
  --build    Rebuild dist/xiaoxin-tui before installation.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --build) BUILD_FIRST=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

if [ "$BUILD_FIRST" -eq 1 ]; then
  "$SCRIPT_DIR/build.sh"
fi

for file in background.png highlight_c.png JetBrainsMono-Menu-37.pf2 JetBrainsMono-Body-28.pf2 theme.txt icons/arch.png icons/windows.png; do
  if [ ! -s "$DIST_DIR/$file" ]; then
    echo "error: distribution file missing; run ./scripts/build.sh: $file" >&2
    exit 1
  fi
done

if [ ! -f "$GRUB_DEFAULT_FILE" ] || [ ! -f "$GRUB_CONFIG_FILE" ]; then
  echo "error: GRUB configuration files were not found" >&2
  exit 1
fi

timestamp=$(date +%Y%m%d%H%M%S)
default_backup="$GRUB_DEFAULT_FILE.bak-$timestamp"
config_backup="$GRUB_CONFIG_FILE.bak-$timestamp"
theme_backup="$THEME_DIR.bak-$timestamp"

for backup in "$default_backup" "$config_backup" "$theme_backup"; do
  if [ -e "$backup" ]; then
    echo "error: backup target already exists: $backup" >&2
    exit 1
  fi
done

if [ "$DRY_RUN" -eq 1 ]; then
  echo "Theme source:       $DIST_DIR"
  echo "Theme destination:  $THEME_DIR"
  [ ! -d "$THEME_DIR" ] || echo "Theme backup:       $theme_backup"
  echo "GRUB defaults:       $GRUB_DEFAULT_FILE"
  echo "Defaults backup:     $default_backup"
  echo "Generated config:    $GRUB_CONFIG_FILE"
  echo "Config backup:       $config_backup"
  echo "GFX mode:            2880x1800,auto"
  echo "No files changed (dry run)."
  exit 0
fi

if [ "$(id -u)" -ne 0 ]; then
  sudo -v
fi

tmp_default=$(mktemp)
tmp_config=$(mktemp)
cleanup() {
  rm -f "$tmp_default" "$tmp_config"
}
trap cleanup EXIT HUP INT TERM

as_root cp -a "$GRUB_DEFAULT_FILE" "$default_backup"
as_root cp -a "$GRUB_CONFIG_FILE" "$config_backup"
if [ -d "$THEME_DIR" ]; then
  as_root cp -a "$THEME_DIR" "$theme_backup"
fi

as_root install -d -m 0755 "$THEME_DIR/icons"
as_root install -m 0644 \
  "$DIST_DIR/background.png" \
  "$DIST_DIR/highlight_c.png" \
  "$DIST_DIR/JetBrainsMono-Menu-37.pf2" \
  "$DIST_DIR/JetBrainsMono-Body-28.pf2" \
  "$DIST_DIR/theme.txt" \
  "$THEME_DIR/"
as_root install -m 0644 \
  "$DIST_DIR/icons/arch.png" \
  "$DIST_DIR/icons/windows.png" \
  "$THEME_DIR/icons/"

awk -v theme_path="$THEME_DIR/theme.txt" -f "$SCRIPT_DIR/configure-grub.awk" "$GRUB_DEFAULT_FILE" >"$tmp_default"
as_root install -o root -g root -m 0644 "$tmp_default" "$GRUB_DEFAULT_FILE"

if ! as_root "$GRUB_MKCONFIG" -o "$tmp_config"; then
  as_root cp -a "$default_backup" "$GRUB_DEFAULT_FILE"
  echo "error: grub-mkconfig failed; GRUB defaults restored" >&2
  exit 1
fi

if ! as_root "$GRUB_SCRIPT_CHECK" "$tmp_config"; then
  as_root cp -a "$default_backup" "$GRUB_DEFAULT_FILE"
  echo "error: generated GRUB config is invalid; GRUB defaults restored" >&2
  exit 1
fi

if ! as_root install -o root -g root -m 0755 "$tmp_config" "$GRUB_CONFIG_FILE"; then
  as_root cp -a "$default_backup" "$GRUB_DEFAULT_FILE"
  as_root cp -a "$config_backup" "$GRUB_CONFIG_FILE"
  echo "error: could not install GRUB config; original files restored" >&2
  exit 1
fi

echo "Installed theme: $THEME_DIR"
echo "Defaults backup: $default_backup"
echo "Config backup:   $config_backup"
[ ! -d "$theme_backup" ] || echo "Theme backup:    $theme_backup"
