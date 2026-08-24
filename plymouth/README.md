# TUI Boot Plymouth Theme

This companion theme provides the animated handoff between the GRUB menu and
the graphical session. It intentionally uses only a few tiny raster assets and
scripted transforms; it does not delay boot to finish an animation cycle.

The layout is based on a 2880x1800 reference canvas and scales from the shorter
screen dimension. Press `Esc` during boot to switch to detailed system output.

## Files

- `tui-boot/tui-boot.plymouth`: Plymouth theme manifest.
- `tui-boot/tui-boot.script`: responsive line animation and prompt handling.
- `tools/build-assets.sh`: reproducibly renders the small PNG assets.

## Build

The asset builder requires ImageMagick and JetBrains Mono:

```sh
./plymouth/tools/build-assets.sh
make check-plymouth
```

See the root English and Simplified Chinese README files for the Arch Linux
installation and recovery parameters. Distribution-specific initramfs setup is
kept outside the theme itself.
