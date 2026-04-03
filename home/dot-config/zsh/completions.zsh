autoload -Uz compinit && compinit

# Source completions — these use compdef, must come after compinit
source <(kubectl completion zsh)
source <(op completion zsh)
source <(docker completion zsh)

# Bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# Carapace — must come before fzf-tab
export CARAPACE_BRIDGES='zsh,bash'
source <(carapace _carapace zsh)

# FZF shell integration — must come before fzf-tab
source <(fzf --zsh)

# fzf-tab — must come after compinit and fzf
zinit light Aloxaf/fzf-tab

zinit cdreplay -q
