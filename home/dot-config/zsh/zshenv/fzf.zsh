# Enhanced FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --multi
  --color=bg+:#282828,fg:#f2f4f8,fg+:#f2f4f8,hl:#ee5396,hl+:#ee5396
  --color=info:#08bdba,prompt:#be95ff,pointer:#ee5396,marker:#25be6a
  --color=spinner:#be95ff,header:#78a9ff,border:#484848
  --bind="ctrl-y:execute-silent(echo {} | pbcopy)"
  --bind="ctrl-o:execute(open {})"
  --bind="ctrl-e:execute(nvim {})"'

export FZF_CTRL_R_OPTS='--sort --exact'
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:500 {}"'
