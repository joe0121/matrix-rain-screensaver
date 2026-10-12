# matrix-rain-screensaver

Matrix digital-rain screensaver for Wayland, built for Omarchy / Hyprland. The renderer is pure Python; the launcher needs `hyprctl`, `jq`, `socat` and `foot`, and the settings menu uses `gum` if present (plain prompts otherwise).

## Install

    git clone https://github.com/joe0121/matrix-rain-screensaver
    cd matrix-rain-screensaver
    ./install.sh

Installs to `~/.local/bin` and adds one launcher entry (no sudo): Matrix Screensaver, which opens the floating settings menu (also `matrix-screensaver-config`). Preview from inside the menu, or run `matrix-screensaver` directly.

Remove with `./uninstall.sh`.

## Settings

Open "Matrix Screensaver" from the launcher (or run `matrix-screensaver-config`). Pick one setting, change it, and the menu closes immediately with a notification.

- Idle time: minutes of inactivity before the screensaver starts. Written to `idle.screensaver` in `~/.config/omarchy/shell.json`, which the Omarchy shell hot-reloads. If lock would not come after it, lock moves to screensaver + 150s.
- Rain speed: 1 (slow) to 10 (fast).
- Characters: katakana (classic), Latin, binary, hex, Klingon (pIqaD), the word OMARCHY, your own text spelled down the columns, or random characters from your own string.
- Colour: green, cyan, blue, purple, pink, red, amber, white, rainbow, or any `#rrggbb`.
- Matrix mode: on = Omarchy's idle screensaver shows Matrix rain; off = stock Omarchy effects.
- Preview now.

Settings are stored in `~/.config/matrix-screensaver/config` (plain `key=value`, read each time the screensaver starts). Any key or mouse movement closes the screensaver on all monitors.

## Fonts

`./install.sh` checks for and offers to install:

- a Nerd Font (`ttf-jetbrains-mono-nerd` via pacman, sudo),
- a font with katakana glyphs (`noto-fonts-cjk` via pacman, sudo),
- pIqaD qolqoS for Klingon (SIL OFL, downloaded to `~/.local/share/fonts/matrix-screensaver`, no sudo).

pIqaD uses Unicode Private Use code points U+F8D0-F8FF, which some Nerd Fonts also use for icons. When that clash exists the installer adds a small fontconfig rule (`~/.config/fontconfig/conf.d/60-matrix-screensaver-piqad.conf`) so pIqaD wins after JetBrainsMono Nerd Font. Without the font, Klingon falls back to Latin transliteration.

Options: `--yes` install everything without asking, `--no-fonts` skip the check, `--fonts` only run the font step.

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
