#!/bin/bash
# Rebuild btop.theme and vscode-theme.json after editing colors.toml.
#
# Omarchy skips a template when the theme ships that file, so both are moved
# aside, the theme is re-applied to get fresh generated copies, and the
# hexafunk fixes are applied on top:
#   btop.theme         selected_fg = fg0 (the template uses the accent,
#                      pink on pink-dim is 2.3:1)
#   vscode-theme.json  syntax roles remapped by tools/vscode_remap.py
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
generated="$HOME/.local/state/omarchy/current/theme"
stash="$(mktemp -d)"

mv "$repo/btop.theme" "$repo/vscode-theme.json" "$stash/"
restore() { [[ -f $repo/btop.theme ]] || mv "$stash/btop.theme" "$repo/"; [[ -f $repo/vscode-theme.json ]] || mv "$stash/vscode-theme.json" "$repo/"; }
trap restore EXIT

omarchy theme set hexafunk >/dev/null
sleep 2

sed 's/^theme\[selected_fg\]=.*/theme[selected_fg]="#f5f1ea"/' "$generated/btop.theme" >"$repo/btop.theme"
python3 "$repo/tools/vscode_remap.py" "$generated/vscode-theme.json" "$repo/vscode-theme.json"

omarchy theme set hexafunk >/dev/null
echo "Regenerated btop.theme and vscode-theme.json; theme re-applied."
