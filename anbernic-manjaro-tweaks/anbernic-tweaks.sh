#!/bin/sh

# Fix Qt applications
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_QUICK_CONTROLS_MOBILE=1

# Kirigami
export KIRIGAMI_LOWPOWER_HARDWARE=1

# Fix Firefox
export MOZ_ENABLE_WAYLAND=1

# Give us some room to configure things:
export XDG_DATA_DIRS
XDG_DATA_DIRS="/usr/share/manjaro:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

# panfrost
export PAN_I_WANT_A_BROKEN_VULKAN_DRIVER=1
export MESA_VK_VERSION_OVERRIDE=1.4
export PAN_MESA_DEBUG=gl3

# software cursor
export KWIN_FORCE_SW_CURSOR=1

# steam
export STEAMOS=1
export STEAM_RUNTIME=1
export PROTON_USE_WOW64=1
export DBUS_FATAL_WARNINGS=0

