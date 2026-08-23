#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
SRC_DIR="$ROOT_DIR/ventoy/src"
OUTPUT_ROOT=${OUTPUT_ROOT:-"$ROOT_DIR/ventoy/dist/ventoy"}
THEME_ROOT="$OUTPUT_ROOT/theme"
SHARED_DIR="$THEME_ROOT/tui-grub-theme"
PROFILES_FILE="$SRC_DIR/profiles.txt"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

scale_value() {
  awk -v value="$1" -v scale="$2" 'BEGIN { printf "%d", (value * scale) + 0.5 }'
}

scale_theme() {
  input=$1
  output=$2
  scale_x=$3
  scale_y=$4
  body_size=$5
  menu_size=$6

  awk -v sx="$scale_x" -v sy="$scale_y" \
      -v body="$body_size" -v menu="$menu_size" '
    function rounded(value) { return int(value + 0.5) }
    function scaled_line(line, scale, value) {
      match(line, /[0-9]+/)
      value = substr(line, RSTART, RLENGTH)
      return substr(line, 1, RSTART - 1) rounded(value * scale) substr(line, RSTART + RLENGTH)
    }
    /^[[:space:]]*(left|width|icon_width|item_icon_space|scrollbar_width|scrollbar_left_pad)[[:space:]]*=/ {
      $0 = scaled_line($0, sx)
    }
    /^[[:space:]]*(top|height|icon_height|item_height|scrollbar_top_pad|scrollbar_bottom_pad)[[:space:]]*=/ {
      $0 = scaled_line($0, sy)
    }
    {
      gsub(/JetBrains Mono Ventoy 24 Regular 24/, "JetBrains Mono Ventoy " body " Regular " body)
      gsub(/Noto Sans Mono CJK SC Menu 28 Regular 28/, "Noto Sans Mono CJK SC Menu " menu " Regular " menu)
      print
    }
  ' "$input" > "$output"
}

build_font_pair() {
  body_size=$1
  menu_size=$2

  grub-mkfont \
    -n "JetBrains Mono Ventoy $body_size" \
    -s "$body_size" \
    -r 0x20-0x7e \
    -o "$SHARED_DIR/fonts/JetBrainsMono-Ventoy-$body_size.pf2" \
    "$NERD_FONT_FILE"

  grub-mkfont \
    -i "$CJK_FONT_INDEX" \
    -n "Noto Sans Mono CJK SC Menu $menu_size" \
    -s "$menu_size" \
    -r 0x20-0x024f,0x2000-0x206f,0x3000-0x303f,0x3400-0x4dbf,0x4e00-0x9fff,0xff00-0xffef \
    -o "$SHARED_DIR/fonts/NotoSansMonoCJKSC-Menu-$menu_size.pf2" \
    "$CJK_FONT_FILE"
}

require_command awk
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

install -d -m 0755 "$OUTPUT_ROOT" "$SHARED_DIR/fonts"

# Remove assets from the legacy single-resolution package. The shared
# directory now contains fonts only; layouts live in resolution-tagged peers.
rm -f -- \
  "$SHARED_DIR/background.png" \
  "$SHARED_DIR/highlight_c.png" \
  "$SHARED_DIR/menu_c.png" \
  "$SHARED_DIR/menu_e.png" \
  "$SHARED_DIR/scrollbar_frame_n.png" \
  "$SHARED_DIR/scrollbar_frame_c.png" \
  "$SHARED_DIR/scrollbar_frame_s.png" \
  "$SHARED_DIR/scrollbar_thumb_n.png" \
  "$SHARED_DIR/scrollbar_thumb_c.png" \
  "$SHARED_DIR/scrollbar_thumb_s.png" \
  "$SHARED_DIR/JetBrainsMono-Ventoy-24.pf2" \
  "$SHARED_DIR/NotoSansMonoCJKSC-Menu-28.pf2" \
  "$SHARED_DIR/theme.txt"
if [ -d "$SHARED_DIR/icons" ]; then
  rm -rf -- "$SHARED_DIR/icons"
fi

install -m 0644 "$SRC_DIR/ventoy.json" "$OUTPUT_ROOT/ventoy.json"

build_font_pair 24 28
build_font_pair 18 20
build_font_pair 14 16

while read -r width height tier; do
  case "$width" in
    ''|'#'*) continue ;;
  esac

  case "$tier" in
    large) body_size=24; menu_size=28 ;;
    medium) body_size=18; menu_size=20 ;;
    small) body_size=14; menu_size=16 ;;
    *) echo "error: unknown font tier: $tier" >&2; exit 1 ;;
  esac

  scale_x=$(awk -v width="$width" 'BEGIN { printf "%.9f", width / 2880 }')
  scale_y=$(awk -v height="$height" 'BEGIN { printf "%.9f", height / 1800 }')
  theme_dir="$THEME_ROOT/tui-grub-theme_${width}x${height}"

  install -d -m 0755 "$theme_dir/icons"
  scale_theme "$SRC_DIR/theme.txt" "$theme_dir/theme.txt" \
    "$scale_x" "$scale_y" "$body_size" "$menu_size"

  rsvg-convert -w "$width" -h "$height" "$SRC_DIR/background.svg" -o "$theme_dir/background.png"
  rsvg-convert \
    -w "$(scale_value 1670 "$scale_x")" \
    -h "$(scale_value 92 "$scale_y")" \
    "$SRC_DIR/highlight.svg" -o "$theme_dir/highlight_c.png"
  rsvg-convert -w 1 -h 1 "$SRC_DIR/menu-transparent.svg" -o "$theme_dir/menu_c.png"
  rsvg-convert \
    -w "$(scale_value 40 "$scale_x")" -h 1 \
    "$SRC_DIR/menu-transparent.svg" -o "$theme_dir/menu_e.png"

  scrollbar_width=$(scale_value 10 "$scale_x")
  scrollbar_cap=$(scale_value 6 "$scale_y")
  scrollbar_center=$(scale_value 8 "$scale_y")
  rsvg-convert -w "$scrollbar_width" -h "$scrollbar_cap" "$SRC_DIR/scrollbar_n.svg" -o "$theme_dir/scrollbar_thumb_n.png"
  rsvg-convert -w "$scrollbar_width" -h "$scrollbar_center" "$SRC_DIR/scrollbar_c.svg" -o "$theme_dir/scrollbar_thumb_c.png"
  rsvg-convert -w "$scrollbar_width" -h "$scrollbar_cap" "$SRC_DIR/scrollbar_s.svg" -o "$theme_dir/scrollbar_thumb_s.png"
  rsvg-convert -w "$scrollbar_width" -h "$scrollbar_cap" "$SRC_DIR/scrollbar_frame_n.svg" -o "$theme_dir/scrollbar_frame_n.png"
  rsvg-convert -w "$scrollbar_width" -h "$scrollbar_center" "$SRC_DIR/scrollbar_frame_c.svg" -o "$theme_dir/scrollbar_frame_c.png"
  rsvg-convert -w "$scrollbar_width" -h "$scrollbar_cap" "$SRC_DIR/scrollbar_frame_s.svg" -o "$theme_dir/scrollbar_frame_s.png"

  icon_width=$(scale_value 64 "$scale_x")
  icon_height=$(scale_value 48 "$scale_y")
  for icon_source in "$SRC_DIR"/icons/*.svg; do
    icon_name=$(basename "$icon_source" .svg)
    rsvg-convert -w "$icon_width" -h "$icon_height" "$icon_source" -o "$theme_dir/icons/$icon_name.png"
  done
done < "$PROFILES_FILE"

echo "Built adaptive Ventoy package: $OUTPUT_ROOT"
