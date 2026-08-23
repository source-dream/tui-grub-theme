#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DEVICE_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
DIST_DIR="$DEVICE_DIR/dist/redmi-tui"
THEME_DIR=${THEME_DIR:-/boot/grub/themes/redmi-tui}
GRUB_DEFAULT_FILE=${GRUB_DEFAULT_FILE:-/etc/default/grub}
GRUB_CONFIG_FILE=${GRUB_CONFIG_FILE:-/boot/grub/grub.cfg}
GRUB_MKCONFIG=${GRUB_MKCONFIG:-grub-mkconfig}
GRUB_SCRIPT_CHECK=${GRUB_SCRIPT_CHECK:-grub-script-check}
GRUB_LOCALE=${GRUB_LOCALE:-zh_CN.UTF-8}
GRUB_RUNTIME_LANG=${GRUB_RUNTIME_LANG:-en_US}

as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

for file in \
  background.png \
  highlight_c.png \
  JetBrainsMono-Menu-33.pf2 \
  JetBrainsMono-Body-25.pf2 \
  theme.txt \
  icons/arch.png \
  icons/windows.png; do
  if [ ! -s "$DIST_DIR/$file" ]; then
    echo "error: missing deployment file: $file" >&2
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

if [ "$(id -u)" -ne 0 ]; then
  sudo -v
fi

tmp_default=$(mktemp)
tmp_config=$(mktemp)
cleanup() {
  rm -f "$tmp_default"
  as_root rm -f "$tmp_config"
}
trap cleanup EXIT HUP INT TERM

# grub-mkconfig opens its output as root. A root-owned file avoids
# fs.protected_regular rejecting that write in a sticky /tmp directory.
as_root chown root:root "$tmp_config"

as_root cp -a "$GRUB_DEFAULT_FILE" "$default_backup"
as_root cp -a "$GRUB_CONFIG_FILE" "$config_backup"
if [ -d "$THEME_DIR" ]; then
  as_root cp -a "$THEME_DIR" "$theme_backup"
fi

as_root install -d -m 0755 "$THEME_DIR/icons"
as_root install -m 0644 \
  "$DIST_DIR/background.png" \
  "$DIST_DIR/highlight_c.png" \
  "$DIST_DIR/JetBrainsMono-Menu-33.pf2" \
  "$DIST_DIR/JetBrainsMono-Body-25.pf2" \
  "$DIST_DIR/theme.txt" \
  "$THEME_DIR/"
as_root install -m 0644 \
  "$DIST_DIR/icons/arch.png" \
  "$DIST_DIR/icons/windows.png" \
  "$THEME_DIR/icons/"

awk -v theme_path="$THEME_DIR/theme.txt" \
  -f "$SCRIPT_DIR/configure-grub.awk" "$GRUB_DEFAULT_FILE" >"$tmp_default"
as_root install -o root -g root -m 0644 "$tmp_default" "$GRUB_DEFAULT_FILE"

if ! as_root env LANG="$GRUB_LOCALE" LC_ALL="$GRUB_LOCALE" \
  "$GRUB_MKCONFIG" -o "$tmp_config"; then
  as_root cp -a "$default_backup" "$GRUB_DEFAULT_FILE"
  echo "error: grub-mkconfig failed; GRUB defaults restored" >&2
  exit 1
fi

# Keep the runtime language used by the pre-deployment GRUB configuration
# while retaining its existing Chinese generated menu labels.
as_root sed -i \
  "s/^[[:space:]]*set lang=.*/  set lang=$GRUB_RUNTIME_LANG/" "$tmp_config"

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
