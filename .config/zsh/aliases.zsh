# Aliases Configuration

# Basic aliases
alias c='clear'
alias cd='z'
alias grep='grep --color="always"'
alias cat="bat"
alias ls="lsd --classify"
alias l="lsd --long --classify --group-directories-first"
alias la="lsd --long --almost-all --classify --group-directories-first"
alias tree="tree -C -a -I .git"
alias vi='nvim'

# Suffix aliases
alias -s json='jless'
alias -s yaml='jless'
alias -s md='glow -t'

# Global aliases

# No Errors
alias -g NE='2>/dev/null'

# No Output
alias -g NO='>/dev/null'

# Redirect both stdout and stderr to /dev/null
alias -g NUL='>/dev/null 2>&1'

# Pipe to jq
alias -g J='| jq'

# Pipe to fx
alias -g F='| fx'

# Copy output to clipboard (macOS)
alias -g C='| pbcopy'

