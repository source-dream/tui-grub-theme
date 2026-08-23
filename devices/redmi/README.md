# Redmi G profile

This profile adapts the TUI GRUB theme to the Redmi G 2022 display and boot
layout.

- Native resolution: `2560x1600`
- Linux ESP: `/boot` on the aigo P7000Z
- Primary loader: `/EFI/id=GRUB/grubx64.efi`
- Default boot target: Arch Linux

Build and validate it from the repository root:

```sh
./devices/redmi/scripts/build.sh
./devices/redmi/scripts/check.sh
```

The generated deployment tree is `devices/redmi/dist/redmi-tui/`.
