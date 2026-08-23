#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
SRC_DIR="$ROOT_DIR/ventoy/src"
OUTPUT_ROOT="$ROOT_DIR/ventoy/dist/ventoy"
THEME_ROOT="$OUTPUT_ROOT/theme"
SHARED_DIR="$THEME_ROOT/xiaoxin-tui"

scale_value() {
  awk -v value="$1" -v scale="$2" 'BEGIN { printf "%d", (value * scale) + 0.5 }'
}

sh -n "$ROOT_DIR/scripts/build-ventoy.sh"
jq empty "$SRC_DIR/ventoy.json"
jq empty "$OUTPUT_ROOT/ventoy.json"
cmp "$SRC_DIR/ventoy.json" "$OUTPUT_ROOT/ventoy.json"

[ "$(jq '.theme.default_file' "$OUTPUT_ROOT/ventoy.json")" = "0" ]
[ "$(jq '.theme.resolution_fit' "$OUTPUT_ROOT/ventoy.json")" = "1" ]
[ "$(jq '.theme.file | length' "$OUTPUT_ROOT/ventoy.json")" = "6" ]

for legacy_file in theme.txt background.png NotoSansMonoCJKSC-Menu-28.pf2; do
  if [ -e "$SHARED_DIR/$legacy_file" ]; then
    echo "error: stale single-resolution asset remains: $legacy_file" >&2
    exit 1
  fi
done
[ ! -d "$SHARED_DIR/icons" ]

if command -v xmllint >/dev/null 2>&1; then
  find "$SRC_DIR" -name '*.svg' -type f -exec xmllint --noout {} +
fi

for font in \
  JetBrainsMono-Ventoy-24.pf2 NotoSansMonoCJKSC-Menu-28.pf2 \
  JetBrainsMono-Ventoy-18.pf2 NotoSansMonoCJKSC-Menu-20.pf2 \
  JetBrainsMono-Ventoy-14.pf2 NotoSansMonoCJKSC-Menu-16.pf2; do
  if [ ! -s "$SHARED_DIR/fonts/$font" ]; then
    echo "error: missing or empty Ventoy font: $font" >&2
    exit 1
  fi
  file "$SHARED_DIR/fonts/$font" | grep -q "GRUB2 font"
done

while read -r width height tier; do
  case "$width" in
    ''|'#'*) continue ;;
  esac

  scale_x=$(awk -v width="$width" 'BEGIN { printf "%.9f", width / 2880 }')
  scale_y=$(awk -v height="$height" 'BEGIN { printf "%.9f", height / 1800 }')
  theme_dir="$THEME_ROOT/xiaoxin-tui_${width}x${height}"

  for file_name in \
    background.png highlight_c.png menu_c.png menu_e.png \
    scrollbar_frame_n.png scrollbar_frame_c.png scrollbar_frame_s.png \
    scrollbar_thumb_n.png scrollbar_thumb_c.png scrollbar_thumb_s.png theme.txt; do
    if [ ! -s "$theme_dir/$file_name" ]; then
      echo "error: missing or empty ${width}x${height} theme file: $file_name" >&2
      exit 1
    fi
  done

  for icon in arch linux windows vtoydir vtoyefi vtoyimg vtoyiso vtoyret vtoyvhd vtoyvtoy vtoywim; do
    if [ ! -s "$theme_dir/icons/$icon.png" ]; then
      echo "error: missing or empty ${width}x${height} icon: $icon.png" >&2
      exit 1
    fi
  done

  grep -q 'menu_pixmap_style = "menu_\*.png"' "$theme_dir/theme.txt"
  grep -q 'scrollbar_slice = "east"' "$theme_dir/theme.txt"
  grep -q "xiaoxin-tui_${width}x${height}/theme.txt" "$OUTPUT_ROOT/ventoy.json"

  if command -v identify >/dev/null 2>&1; then
    [ "$(identify -format '%wx%h' "$theme_dir/background.png")" = "${width}x${height}" ]
    [ "$(identify -format '%wx%h' "$theme_dir/highlight_c.png")" = "$(scale_value 1670 "$scale_x")x$(scale_value 92 "$scale_y")" ]
    [ "$(identify -format '%wx%h' "$theme_dir/menu_c.png")" = "1x1" ]
    [ "$(identify -format '%wx%h' "$theme_dir/menu_e.png")" = "$(scale_value 40 "$scale_x")x1" ]
  fi
done < "$SRC_DIR/profiles.txt"

echo "Adaptive Ventoy theme checks passed."
