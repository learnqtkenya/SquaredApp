#!/bin/sh
# Squared launcher — Raspberry Pi 4 / CM4, booted to a console (no desktop).
#
# No LD_LIBRARY_PATH here: the binary was built with /usr/local/qt6/lib in its
# RUNPATH, so the loader finds Qt on its own (system-Qt deployment model). All
# this script does is pick the display backend and tell Qt the screen's size.
#
# Other targets need a different version of THIS file (the binary is the same):
#   - Pi 5, console boot:  add  export QT_QPA_EGLFS_KMS_CONFIG=/opt/squared/eglfs.json
#   - Pi 5 / desktop image: export QT_QPA_PLATFORM=wayland  (needs qtwayland in the build)
#   - quick test on a desktop image over SSH: DISPLAY=:0 QT_QPA_PLATFORM=xcb ...
# See lecture 8.11 for the full Pi 5 variants.

export QT_QPA_PLATFORM=eglfs
export QT_QPA_EGLFS_PHYSICAL_WIDTH=800
export QT_QPA_EGLFS_PHYSICAL_HEIGHT=480
export QT_FONT_DPI=96
exec /opt/squared/bin/Squared "$@"
