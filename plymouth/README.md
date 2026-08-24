# TUI Boot Plymouth Theme

This companion theme provides the animated handoff between the GRUB menu and
the graphical session. A 72-frame sequence draws the Arch outline from its
apex, transitions the cyan trace to a finished white outline, reveals
`SourceDream's Linuxbook`, and then reverses. Plymouth never waits for the
sequence to finish, so the theme does not add an artificial boot delay.

The layout is based on a 2880x1800 reference canvas and scales from the shorter
screen dimension. Press `Esc` during boot to switch to detailed system output.

## Files

- `tui-boot/tui-boot.plymouth`: Plymouth theme manifest.
- `tui-boot/tui-boot.script`: responsive frame playback and prompt handling.
- `tui-boot/frames/`: generated transparent PNG frames.
- `src/frame-template.svg`: line-art design and text source.
- `tools/build-assets.sh`: reproducibly renders all 72 PNG frames.

## Build

The asset builder requires GNU awk, librsvg (`rsvg-convert`), and JetBrains
Mono:

```sh
./plymouth/tools/build-assets.sh
make check-plymouth
```

See the root English and Simplified Chinese README files for the Arch Linux
installation and recovery parameters. Distribution-specific initramfs setup is
kept outside the theme itself.
