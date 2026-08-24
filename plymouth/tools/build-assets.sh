#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
theme_dir=$(cd -- "${script_dir}/../tui-boot" && pwd)
font=$(fc-match -f '%{file}\n' 'JetBrains Mono:style=Medium' | head -n 1)

magick -size 4x4 xc:'#536079' "${theme_dir}/line-dim.png"
magick -size 4x4 xc:'#70c0e8' "${theme_dir}/line-cyan.png"
magick -size 4x4 xc:'#c099ff' "${theme_dir}/line-purple.png"
magick -size 4x4 xc:'#8bd49c' "${theme_dir}/line-green.png"
magick -size 18x18 xc:none -fill '#8bd49c' -draw 'circle 9,9 9,3' "${theme_dir}/dot.png"

magick -background none -fill '#d9e0ee' -font "${font}" -pointsize 52 \
  label:'ARCH // BOOT SEQUENCE' "${theme_dir}/title.png"
magick -background none -fill '#748096' -font "${font}" -pointsize 23 \
  label:'KERNEL HANDOFF  ·  EARLY KMS  ·  SYSTEMD' "${theme_dir}/subtitle.png"
magick -background none -fill '#8bd49c' -font "${font}" -pointsize 20 \
  label:'INITIALIZING USER SPACE' "${theme_dir}/status.png"
