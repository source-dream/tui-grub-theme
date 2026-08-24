# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### Added

- Added an optional responsive Plymouth line animation for the handoff from
  GRUB to the graphical session.
- Added reproducible Plymouth assets and a repository validation target.
- Added equivalent English and Simplified Chinese installation guides.
- Dedicated 2880x1800 Ventoy theme with a scrollable image library.
- Unicode-capable menu font and class icons for common Ventoy image types.
- Reproducible Ventoy package build and repository checks.
- Resolution-aware Ventoy layouts for six common 16:10, 16:9, and 4:3 modes.
- Shared high, medium, and low font tiers for cross-device readability.

### Changed

- Reworked the Plymouth animation into a 36-frame one-shot sequence that holds
  its completed frame for a stable graphical-session handoff.
- Replaced the rectangular GRUB timeout indicator with a centered 12px rounded pixmap bar that accounts for GRUB's 28px minimum component height.
- Replaced the GRUB and Ventoy previews with direct 2880x1800 QEMU framebuffer captures.
- Renamed every deployable theme directory to `tui-grub-theme`.
- Replaced device-named GRUB variants with generic resolution profiles.
- Removed host names, disk models, UUIDs, and device branding from backgrounds.
- Consolidated GRUB installation into one `--profile` aware installer.
- Renamed the adaptive Ventoy paths to `tui-grub-theme_WIDTHxHEIGHT`.
- Reworked the README around bootloader-specific installation workflows.

## [0.1.0] - 2026-08-23

### Added

- Initial TUI theme at 2880x1800.
- Native GRUB boot menu, class-based Arch and Windows icons, and timeout progress.
- Reproducible SVG and PFF2 build script.
- Backup-first installer with dry-run support.
- QEMU/OVMF validated preview and repository checks.
