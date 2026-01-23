autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

bindkey ' ' magic-space
bindkey -s '^Xgc' 'git commit -m ""\C-b'
