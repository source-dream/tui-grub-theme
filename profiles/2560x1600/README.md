# 2560x1600 GRUB Profile

This directory contains the `2560x1600` profile for `tui-grub-theme`.

Build and validate it from the repository root:

```sh
./profiles/2560x1600/scripts/build.sh
./profiles/2560x1600/scripts/check.sh
```

Install it through the shared backup-first installer:

```sh
./scripts/install.sh --profile 2560x1600 --dry-run
./scripts/install.sh --profile 2560x1600
```

The generated deployment tree is:

```text
profiles/2560x1600/dist/tui-grub-theme/
```

It installs to the same `/boot/grub/themes/tui-grub-theme/` path as the
default profile, so changing profiles does not leave device-named theme
directories behind.
