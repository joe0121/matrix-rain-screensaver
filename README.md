# matrix-rain-screensaver

Matrix digital-rain screensaver for Wayland, built for Omarchy / Hyprland. Pure Python, no dependencies beyond a terminal (foot, Alacritty, Ghostty or Kitty) and `gum` for the settings menu.

## Install

    git clone https://github.com/joe0121/matrix-rain-screensaver
    cd matrix-rain-screensaver
    ./install.sh

Installs to `~/.local/bin` and adds two launcher entries (no sudo):

- Matrix Screensaver: preview it now.
- Matrix Screensaver Settings: floating settings menu (also `matrix-screensaver-config`).

Remove with `./uninstall.sh`.

## Settings

- Idle time: minutes of inactivity before the screensaver starts. Written to `idle.screensaver` (seconds) in `~/.config/omarchy/shell.json`, which the Omarchy shell hot-reloads. If the lock time would not come after it, lock is moved to screensaver + 150s.
- Matrix mode: on = Omarchy's idle screensaver shows Matrix rain; off = stock Omarchy effects.
- Preview: starts the screensaver immediately.

Any key or mouse movement closes it on all monitors.

## How it hooks in

Omarchy's shell runs `omarchy-launch-screensaver`, which runs `ttfx ... --random-effect` inside a fullscreen terminal per monitor. `install.sh` puts a small `ttfx` wrapper in `~/.local/bin` (ahead of `/usr/bin` in PATH). With Matrix mode on, it runs `matrix-rain` for those calls and passes everything else to the real `ttfx`. Idle timing, locking, multi-monitor launch, dismissal and Omarchy's "screensaver off" toggle keep working. Nothing under `/usr` is modified.

`matrix-screensaver` is a standalone launcher (Hyprland, foot) that does the same without the Omarchy shell.

Note: if Omarchy's "stay awake" idle toggle is on, nothing idle-related fires, including this.

## Files

- `bin/matrix-rain`: the renderer (ANSI, halfwidth katakana, white head and green fade). Tune constants at the top.
- `bin/matrix-screensaver`: standalone fullscreen launcher.
- `bin/matrix-screensaver-config`: settings TUI.
- `bin/ttfx`: wrapper described above.

MIT licensed.
