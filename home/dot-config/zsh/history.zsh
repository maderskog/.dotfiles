# History Configuration

HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE

# History behavior
setopt appendhistory
setopt sharehistory
setopt extended_history
setopt inc_append_history
setopt hist_expire_dups_first
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_verify
setopt hist_reduce_blanks
