if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

zinit ice wait lucid
# Add in zsh plugins
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light MichaelAquilina/zsh-autoswitch-virtualenv

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::brew
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::dotenv
zinit snippet OMZP::node
zinit snippet OMZP::sbt

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Initialize oh-my-posh
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/zen.yaml)"

# Keybindings
# bindkey -e
# bindkey '^p' history-search-backward
# bindkey '^n' history-search-forward
# bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias c='clear'
# alias cd="z"
alias grep='grep --color="always"'
alias cat="bat"
alias ls="lsd --classify"
alias l="lsd -l --classify --group-directories-first"
alias la="lsd -l -a --classify --group-directories-first"
alias tree="tree -C -a -I .git"
alias vi='nvim'

# Path
export PATH="/opt/homebrew/opt/node@20/bin:$PATH"
export PATH="$PATH:/Users/michael/bin"
export PATH="$PATH:/Applications/Sublime Text.app/Contents/SharedSupport/bin"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin"
export PATH="$PATH:/Users/michael/Library/Application Support/edgedb/bin"
export PATH="$HOME/.local/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"


# Environment Variables
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export ERL_AFLAGS="-kernel shell_history enabled"
export LDFLAGS="-L$(brew --prefix zbar)/lib"
export CFLAGS="-I$(brew --prefix zbar)/include"
export POETRY_VIRTUALENVS_IN_PROJECT=true

launchctl setenv PATH ${PATH}

# Functions

function path() {
  echo $PATH | tr ':' '\n'
}

function json() {
  cat $1 | jq | bat --language json
}

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Completions
source <(kubectl completion zsh)
source <(op completion zsh)
source <(fzf --zsh)

source /Users/michael/.config/broot/launcher/bash/br
