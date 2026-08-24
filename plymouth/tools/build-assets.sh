#!/usr/bin/env bash
set -euo pipefail

export LC_ALL=C

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
plymouth_dir=$(cd -- "${script_dir}/.." && pwd)
template="${plymouth_dir}/src/frame-template.svg"
frames_dir="${plymouth_dir}/tui-boot/frames"

command -v awk >/dev/null
command -v rsvg-convert >/dev/null

mkdir -p "${frames_dir}"
rm -f "${frames_dir}"/frame-*.png

for index in $(seq 0 71); do
  read -r draw_offset guide_offset base_opacity draw_opacity final_opacity title_opacity title_shift < <(
    awk -v i="${index}" '
      function clamp(v) { return v < 0 ? 0 : (v > 1 ? 1 : v) }
      function ease(v) { v = clamp(v); return (1 - cos(v * 3.141592653589793)) / 2 }
      BEGIN {
        guide = ease(i / 14)
        draw = ease((i - 5) / 39)
        final = ease((i - 35) / 16)
        title = ease((i - 34) / 14)
        if (i >= 60) {
          reverse = ease((i - 60) / 11)
          guide *= 1 - reverse
          draw *= 1 - reverse
          final *= 1 - reverse
          title *= 1 - reverse
        }
        printf "%.4f %.4f %.4f %.4f %.4f %.4f %.4f\n", \
          994.0888 * (1 - draw), 206 * (1 - guide), 0.16 * draw, \
          draw * (1 - final * 0.72), final, title, 8 * (1 - title)
      }
    '
  )

  frame=$(printf '%02d' "${index}")
  sed \
    -e "s/{{DRAW_OFFSET}}/${draw_offset}/g" \
    -e "s/{{GUIDE_OFFSET}}/${guide_offset}/g" \
    -e "s/{{BASE_OPACITY}}/${base_opacity}/g" \
    -e "s/{{DRAW_OPACITY}}/${draw_opacity}/g" \
    -e "s/{{FINAL_OPACITY}}/${final_opacity}/g" \
    -e "s/{{TITLE_OPACITY}}/${title_opacity}/g" \
    -e "s/{{TITLE_SHIFT}}/${title_shift}/g" \
    "${template}" \
    | rsvg-convert -w 900 -h 600 -o "${frames_dir}/frame-${frame}.png"
done

echo "Generated 72 Plymouth frames in ${frames_dir}."
