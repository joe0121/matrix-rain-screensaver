#!/bin/bash
# Install the Matrix screensaver for Omarchy / Hyprland (user-level, no sudo).
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
bin="${PREFIX:-$HOME/.local/bin}"
apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
conf="${XDG_CONFIG_HOME:-$HOME/.config}/matrix-screensaver"

mkdir -p "$bin" "$apps" "$conf"
for f in matrix-rain matrix-screensaver matrix-screensaver-config ttfx; do
  install -m 755 "$here/bin/$f" "$bin/$f"
done
for f in "$here"/share/applications/*.desktop; do
  sed "s|@BIN@|$bin|g" "$f" >"$apps/$(basename "$f")"
done
[[ -f $conf/config ]] || echo "matrix=on" >"$conf/config"
update-desktop-database "$apps" 2>/dev/null || true

case ":$PATH:" in *":$bin:"*) ;; *) echo "warning: $bin is not in PATH" ;; esac
echo "Installed. Open 'Matrix Screensaver Settings' from the launcher (or run matrix-screensaver-config)."
