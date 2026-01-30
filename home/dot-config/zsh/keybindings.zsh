autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^Xvi' edit-command-line

bindkey ' ' magic-space

bindkey -s '^Xgc' 'git commit -m ""\C-b'
