# Initialize oh-my-posh
if [[ -o interactive ]] && [[ -t 1 ]]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/zen.yaml)"
fi
