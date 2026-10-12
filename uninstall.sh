#!/bin/bash
set -euo pipefail
bin="${PREFIX:-$HOME/.local/bin}"
apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
rm -f "$bin"/{matrix-rain,matrix-screensaver,matrix-screensaver-config,ttfx}
rm -f "$apps"/matrix-screensaver{,-settings}.desktop
echo "Removed. Settings in ~/.config/matrix-screensaver and idle times in ~/.config/omarchy/shell.json were left alone."
