# Contributing

1. Edit SVG and theme sources under `src/`.
2. Run `make build` to refresh `dist/xiaoxin-tui/`.
3. Run `make check` before committing.
4. Include an updated QEMU screenshot for visible layout changes.

Keep runtime behavior in GRUB components. Static background text must not be
used to imitate menu selection or timeout state.
