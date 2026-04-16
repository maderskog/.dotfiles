# Aliases Configuration

# Basic aliases
alias c='clear'
alias cd='z'
alias cdt='cd "$(tv dirs)"'
alias grep='grep --color="always"'
alias cat="bat"
alias ls="lsd --classify"
alias l="lsd --long --classify --group-directories-first"
alias la="lsd --long --almost-all --classify --group-directories-first"
alias tree="eza --tree --long --icons --git"
alias vi='nvim'
alias k9s='~/bin/k9s-patched'

# Suffix aliases
alias -s json='jless'
alias -s yaml='jless'
alias -s md='glow -t'

# Global aliases

alias -g NE='2>/dev/null' # No Errors
alias -g NO='>/dev/null' # No Output
alias -g NUL='>/dev/null 2>&1' # Redirect both stdout and stderr to /dev/null
alias -g J='| jq' # Pipe to jq
alias -g F='| fx' # Pipe to fx
alias -g C='| pbcopy' # Copy output to clipboard (macOS)
