autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^Xvi' edit-command-line

bindkey ' ' magic-space

bindkey -s '^Xgc' 'git commit -m ""\C-b'

# Television shell integration (Ctrl+T = smart autocomplete, Ctrl+R = history)
if command -v tv >/dev/null 2>&1; then
  eval "$(tv init zsh)"
fi
