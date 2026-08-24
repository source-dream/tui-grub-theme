#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
theme_dir="${repo_root}/plymouth/tui-boot"

required_files='tui-boot.plymouth tui-boot.script'

for file in ${required_files}; do
    test -s "${theme_dir}/${file}" || {
        echo "Missing Plymouth asset: ${file}" >&2
        exit 1
    }
done

test -s "${repo_root}/plymouth/src/frame-template.svg" || {
    echo 'Missing Plymouth frame template.' >&2
    exit 1
}

frame_count=$(find "${theme_dir}/frames" -maxdepth 1 -type f -name 'frame-*.png' | wc -l)
test "${frame_count}" -eq 36 || {
    echo "Expected 36 Plymouth frames, found ${frame_count}." >&2
    exit 1
}

sh -n "${repo_root}/plymouth/tools/build-assets.sh"

grep -q '^ModuleName=script$' "${theme_dir}/tui-boot.plymouth"
grep -q 'Plymouth.SetRefreshFunction' "${theme_dir}/tui-boot.script"
grep -q 'Plymouth.SetQuitFunction' "${theme_dir}/tui-boot.script"
grep -q 'Plymouth.SetDisplayPasswordFunction' "${theme_dir}/tui-boot.script"
grep -q 'Window.GetWidth()' "${theme_dir}/tui-boot.script"
grep -q 'Window.GetHeight()' "${theme_dir}/tui-boot.script"
grep -q 'frames/frame-35.png' "${theme_dir}/tui-boot.script"
test ! -e "${theme_dir}/frames/frame-36.png"

if command -v shellcheck >/dev/null 2>&1; then
    shellcheck "${repo_root}/plymouth/tools/build-assets.sh"
fi

echo 'Plymouth companion theme checks passed.'
