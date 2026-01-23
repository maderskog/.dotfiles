# Enhanced FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --multi
  --bind="ctrl-y:execute-silent(echo {} | pbcopy)"
  --bind="ctrl-o:execute(open {})"
  --bind="ctrl-e:execute(nvim {})"'

export FZF_CTRL_R_OPTS='--sort --exact'
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:500 {}"'
