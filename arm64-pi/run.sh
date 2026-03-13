#!/bin/sh
export QT_QPA_PLATFORM=eglfs
export QT_QPA_EGLFS_PHYSICAL_WIDTH=800
export QT_QPA_EGLFS_PHYSICAL_HEIGHT=480
export QT_FONT_DPI=96
exec /opt/squared/bin/Squared "$@"
