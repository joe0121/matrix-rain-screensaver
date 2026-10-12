#!/bin/bash
# Install the Matrix screensaver for Omarchy / Hyprland (user-level; sudo only if you
# agree to install a missing system font package).
#   ./install.sh            install, ask before fonts
#   ./install.sh --yes      install and fetch/install any missing fonts without asking
#   ./install.sh --no-fonts skip the font check
#   ./install.sh --fonts    only run the font check/install
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
bin="${PREFIX:-$HOME/.local/bin}"
apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
conf="${XDG_CONFIG_HOME:-$HOME/.config}/matrix-screensaver"
fontdir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/matrix-screensaver"
fcconf="${XDG_CONFIG_HOME:-$HOME/.config}/fontconfig/conf.d"
PIQAD_URL="https://github.com/dadap/pIqaD-fonts/releases/download/pIqaD-fonts-r1/pIqaD-fonts.zip"

yes_all=0 do_fonts=1 do_install=1
for a in "$@"; do
  case $a in
    --yes|-y) yes_all=1 ;;
    --no-fonts) do_fonts=0 ;;
    --fonts) do_install=0 ;;
    *) echo "unknown option: $a" >&2; exit 2 ;;
  esac
done

confirm() { # confirm "question"
  ((yes_all)) && return 0
  [[ -t 0 ]] || return 1
  read -r -p "$1 [y/N] " r
  [[ $r == [yY]* ]]
}

pkg_install() { # pkg_install <pacman-package> <what>
  if ! command -v pacman >/dev/null; then
    echo "  Install $2 with your package manager."; return
  fi
  if confirm "  Install $2 ($1) with sudo pacman?"; then
    sudo pacman -S --needed --noconfirm "$1" || echo "  pacman failed; install $1 manually."
  else
    echo "  Skipped. Install later with: sudo pacman -S $1"
  fi
}

install_fonts() {
  echo "Checking fonts..."
  command -v fc-list >/dev/null || { echo "  fontconfig not found, skipping."; return; }

  # (Capture fc-list output instead of piping into grep -q: with pipefail, grep exiting
  # early SIGPIPEs fc-list and makes a successful match look like a failure.)
  all_fonts=$(fc-list : family)
  pua_fonts=$(fc-list ':charset=f8d0' family)

  # 1. A Nerd Font (Omarchy's default terminal font family)
  if ! grep -qi "nerd font" <<<"$all_fonts"; then
    echo "- No Nerd Font found."
    pkg_install ttf-jetbrains-mono-nerd "JetBrainsMono Nerd Font"
  else
    echo "- Nerd Font: ok"
  fi

  # 2. Halfwidth katakana (classic Matrix glyphs): any CJK font covers U+FF71
  if [[ -z $(fc-list ':charset=ff71' family) ]]; then
    echo "- No font with katakana glyphs."
    pkg_install noto-fonts-cjk "Noto CJK fonts"
  else
    echo "- Katakana glyphs: ok"
  fi

  # 3. Klingon pIqaD (U+F8D0-F8E9): pIqaD qolqoS, SIL OFL, fetched to ~/.local/share/fonts
  if ! grep -qi piqad <<<"$pua_fonts"; then
    echo "- No Klingon pIqaD font."
    if confirm "  Download pIqaD qolqoS (SIL OFL, 16 KB) from github.com/dadap/pIqaD-fonts?"; then
      tmp=$(mktemp -d); trap 'rm -rf "$tmp"' RETURN
      if curl -fsSL -o "$tmp/f.zip" "$PIQAD_URL" &&
         python3 - "$tmp/f.zip" "$fontdir" <<'PY'
import sys, zipfile, os
z, dest = sys.argv[1:3]
os.makedirs(dest, exist_ok=True)
with zipfile.ZipFile(z) as zf:
    for n in zf.namelist():
        base = os.path.basename(n)
        if base.endswith(".ttf") or base in ("LICENSE", "README"):
            open(os.path.join(dest, base), "wb").write(zf.read(n))
PY
      then
        fc-cache -f "$fontdir"
        echo "  Installed to $fontdir"
      else
        echo "  Download failed; Klingon will fall back to Latin letters."
      fi
    else
      echo "  Skipped; Klingon will fall back to Latin letters."
    fi
  else
    echo "- pIqaD font: ok"
  fi

  # 4. pIqaD sits in the Private Use Area, where older Nerd Fonts keep icons. If another
  #    font claims U+F8D0, make fontconfig prefer pIqaD qolqoS after JetBrainsMono Nerd Font.
  pua_fonts=$(fc-list ':charset=f8d0' family)
  if grep -qi piqad <<<"$pua_fonts" && grep -qvi piqad <<<"$pua_fonts"; then
    mkdir -p "$fcconf"
    cat >"$fcconf/60-matrix-screensaver-piqad.conf" <<'XML'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <!-- Prefer pIqaD qolqoS for Klingon glyphs (U+F8D0-F8FF) when a monospace Nerd Font is the primary font. -->
  <match target="pattern">
    <test name="family" qual="any"><string>JetBrainsMono Nerd Font</string></test>
    <edit name="family" mode="append" binding="same"><string>pIqaD qolqoS</string></edit>
  </match>
</fontconfig>
XML
    fc-cache -f >/dev/null 2>&1 || true
    echo "- Added fontconfig rule so pIqaD wins over Nerd Font icons at U+F8D0-F8FF"
  fi
}

if ((do_install)); then
  mkdir -p "$bin" "$apps" "$conf"
  for f in matrix-rain matrix-screensaver matrix-screensaver-config ttfx; do
    install -m 755 "$here/bin/$f" "$bin/$f"
  done
  for f in "$here"/share/applications/*.desktop; do
    sed "s|@BIN@|$bin|g" "$f" >"$apps/$(basename "$f")"
  done
  rm -f "$apps/matrix-screensaver-settings.desktop"  # old separate settings entry
  [[ -f $conf/config ]] || printf 'matrix=on\n' >"$conf/config"
  update-desktop-database "$apps" 2>/dev/null || true
  case ":$PATH:" in *":$bin:"*) ;; *) echo "warning: $bin is not in PATH" ;; esac
fi

((do_fonts)) && install_fonts

echo "Done. Open 'Matrix Screensaver' from the launcher (or run matrix-screensaver-config)."
