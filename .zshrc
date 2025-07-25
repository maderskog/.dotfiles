# Load modular configuration files
source ~/.config/zsh/zinit-plugins.zsh
source ~/.config/zsh/zinit-snippets.zsh
source ~/.config/zsh/completion.zsh
source ~/.config/zsh/fzf-tab.zsh
source ~/.config/zsh/history.zsh
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/functions.zsh

# Initialize oh-my-posh
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/zen.yaml)"

# Bun completions
[ -s "/Users/michael/.bun/_bun" ] && source "/Users/michael/.bun/_bun"

# Ghostty prompt
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  ghostcolors=( "brightred" "brightgreen" "brightyellow" "brightblue" "brightmagenta" "brightcyan" "brightwhite")
  ghosttime --color ${ghostcolors[$(($RANDOM % ${#ghostcolors[@]} + 1))]}
fi

