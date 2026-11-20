# hexafunk

An Omarchy theme: olive-gray Gruvbox base, linen text, neon pink and teal accents.

| Role | Bright | Dim |
|---|---|---|
| keywords (dim: NORMAL mode, selection) | pink `#ff79bc` | `#c41a6e` |
| functions, git added (dim: position block, hints) | teal `#00f0d0` | `#19c9b0` |
| errors, deletions | red `#ff7370` | `#d94545` |
| strings (VISUAL mode) | green `#afb87a` | `#8f9a5a` |
| types, warnings, TODO, git modified | yellow `#fbc956` | `#d6a22e` |
| variables, paths | blue `#3eafcc` | `#2b8fab` |
| numbers, booleans, built-ins | purple `#c297ed` | `#9a6fd0` |
| operators, untracked | orange `#fa984c` | `#d9762a` |

Backgrounds `#181915 #23241e #2d2e26 #36382e #494b3f #5f6151 #747864`, comments `#8e927c`,
linen `#f5f1ea #eee8df #d4ccc1 #bcb4a9 #a59d93`.

## Files

| File | What it does |
|---|---|
| `colors.toml` | Palette. Omarchy generates terminals, Hyprland, the shell, gum, etc. from it. Choices are explained in its header. |
| `neovim.lua` | aether.nvim plus overrides for Vim, Treesitter and LSP semantic groups, git/diagnostic colors and the lualine theme. |
| `tmux.conf` | Powerline-style status bar. Overrides tmux-gruvbox while hexafunk is active. |
| `p10k.zsh` | powerlevel10k (rainbow) segment and frame colors. |
| `eza/theme.yml` | eza (`ls`/`ll`) colors: teal-dim directories, gray dates, linen for your own user, pink source and build files, purple symlinks. |
| `btop.theme` | Generated, then patched: `selected_fg` is linen (the template's pink-on-pink-dim is 2.3:1). |
| `vscode-theme.json` | Generated, then remapped to the hexafunk syntax roles by `tools/vscode_remap.py`. |
| `backgrounds/` | Hexagon wallpaper. |

## Install (this machine)

The theme folder must be a **symlink** to this repo, not a clone in place.
`omarchy theme set` treats a theme folder containing `.git` as installed from a
stranger and drops every `.lua` file (including `neovim.lua`).

```bash
ln -s ~/code/omarchy-hexafunk-theme ~/.config/omarchy/themes/hexafunk
omarchy theme set hexafunk
```

Then the extras in [`setup/`](setup/README.md) for tmux and p10k.

## After editing colors.toml

```bash
tools/regen-generated.sh
```

It regenerates `btop.theme` and `vscode-theme.json` from Omarchy's templates and
re-applies the hexafunk fixes. `neovim.lua`, `tmux.conf`, `p10k.zsh` and `eza/theme.yml` carry
their own hex values, so update those by hand.

## If someone installs it with `omarchy theme install`

They get colors.toml, btop, VS Code, tmux.conf, p10k.zsh, eza and the wallpaper.
`neovim.lua` is dropped and regenerated from the default aether template, so the
custom syntax roles won't come through. The tmux, p10k and eza overlays need
the lines from `setup/`.
