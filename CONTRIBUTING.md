# Contributing

1. Edit SVG and theme sources under `src/`.
2. Run `make build` to refresh `dist/tui-grub-theme/` and the resolution profiles.
3. Run `make check` before committing.
4. Include an updated QEMU screenshot for visible layout changes.
5. Capture menu content from a live GRUB or Ventoy framebuffer. Do not
   composite icons, labels, selection states, or countdown values into it.

For the Ventoy variant, edit `ventoy/src/`, then run `make build-ventoy` and
`make check-ventoy`. Keep `ventoy/dist/ventoy/` deployable as a complete tree.

Keep runtime behavior in GRUB components. Static background text must not be
used to imitate menu selection or timeout state.
