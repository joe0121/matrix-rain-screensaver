#!/bin/bash
set -euo pipefail
bin="${PREFIX:-$HOME/.local/bin}"
apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
rm -f "$bin"/{matrix-rain,matrix-screensaver,matrix-screensaver-config,ttfx}
rm -f "$apps"/matrix-screensaver{,-settings}.desktop
rm -f "${XDG_CONFIG_HOME:-$HOME/.config}/fontconfig/conf.d/60-matrix-screensaver-piqad.conf"
echo "Removed. Settings in ~/.config/matrix-screensaver and idle times in ~/.config/omarchy/shell.json were left alone, as were any fonts installed under ~/.local/share/fonts/matrix-screensaver."
