#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
theme_dir="${repo_root}/plymouth/tui-boot"

required_files='tui-boot.plymouth tui-boot.script line-dim.png line-cyan.png line-purple.png line-green.png dot.png title.png subtitle.png status.png'

for file in ${required_files}; do
    test -s "${theme_dir}/${file}" || {
        echo "Missing Plymouth asset: ${file}" >&2
        exit 1
    }
done

sh -n "${repo_root}/plymouth/tools/build-assets.sh"

grep -q '^ModuleName=script$' "${theme_dir}/tui-boot.plymouth"
grep -q 'Plymouth.SetRefreshFunction' "${theme_dir}/tui-boot.script"
grep -q 'Plymouth.SetDisplayPasswordFunction' "${theme_dir}/tui-boot.script"
grep -q 'Window.GetWidth()' "${theme_dir}/tui-boot.script"
grep -q 'Window.GetHeight()' "${theme_dir}/tui-boot.script"

if command -v shellcheck >/dev/null 2>&1; then
    shellcheck "${repo_root}/plymouth/tools/build-assets.sh"
fi

echo 'Plymouth companion theme checks passed.'
