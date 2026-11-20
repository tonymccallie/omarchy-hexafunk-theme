# Setup outside the theme folder

These pieces live in your own dotfiles, not in the theme. Each one does nothing
when the current theme doesn't ship the matching file, so other themes are unaffected.

## tmux

Add to the end of `~/.tmux.conf`, **after** the tpm `run` line so it wins over
tmux-gruvbox:

```tmux
# Omarchy theme override for tmux (after tpm so it wins over tmux-gruvbox).
# Only themes that ship a tmux.conf, such as hexafunk, have one.
source-file -q ~/.local/state/omarchy/current/theme/tmux.conf
```

Re-theme running tmux servers on every theme switch:

```bash
omarchy hook install theme-set setup/20-tmux-theme
```

## powerlevel10k

Add to `~/.zshrc` right after the line that sources `~/.p10k.zsh`:

```zsh
# Omarchy theme colors for p10k (only themes that ship one, e.g. hexafunk)
[[ ! -f ~/.local/state/omarchy/current/theme/p10k.zsh ]] || source ~/.local/state/omarchy/current/theme/p10k.zsh
```

Open shells keep their old colors until `exec zsh`.
