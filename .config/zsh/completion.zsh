# Completion Configuration

# Load completions
autoload -Uz compinit && compinit

# Source Completions BEFORE fzf-tab
source <(kubectl completion zsh)
source <(op completion zsh)
source <(supabase completion zsh)
source <(docker completion zsh)

# Carapace BEFORE fzf-tab
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
source <(carapace _carapace)

compinit -C

# Enable FZF shell integration BEFORE fzf-tab
source <(fzf --zsh)

# Load fzf-tab AFTER completions and carapace
zinit light Aloxaf/fzf-tab

zinit cdreplay -q

