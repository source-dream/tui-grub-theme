BEGIN {
  gfxmode_seen = 0
  theme_seen = 0
}

/^[[:space:]]*GRUB_GFXMODE=/ {
  if (!gfxmode_seen) {
    print "GRUB_GFXMODE=2880x1800,auto"
    gfxmode_seen = 1
  }
  next
}

/^[[:space:]]*#?[[:space:]]*GRUB_THEME=/ {
  if (!theme_seen) {
    print "GRUB_THEME=\"" theme_path "\""
    theme_seen = 1
  }
  next
}

{
  print
}

END {
  if (!gfxmode_seen)
    print "GRUB_GFXMODE=2880x1800,auto"
  if (!theme_seen)
    print "GRUB_THEME=\"" theme_path "\""
}
