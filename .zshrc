if [[ -f "/opt/homebrew/bin/brew" ]] then
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

# Path
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin"
export PATH="$HOME/.local/bin:$PATH"

# asdf
source "$(brew --prefix asdf)/libexec/asdf.sh"

# Environment Variables
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export ERL_AFLAGS="-kernel shell_history enabled"
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac --with-ssl=$(brew --prefix openssl@3)"
export CFLAGS="-O2 -g"
export LDFLAGS="-L$(brew --prefix zbar)/lib"
export CFLAGS="-I$(brew --prefix zbar)/include"
export POETRY_VIRTUALENVS_IN_PROJECT=true

launchctl setenv PATH ${PATH}

# GO
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PATH:$PNPM_HOME" ;;
esac

export BUN_INSTALL="$HOME/.bun"
export PATH="$PATH:$BUN_INSTALL/bin"


# INTERACTIVE-ONLY SETUP (runs ONLY for interactive terminals)
if [[ -o interactive ]]; then

  zinit ice wait lucid
  # Add in zsh plugins
  zinit light zdharma-continuum/fast-syntax-highlighting
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
  alias grep='grep --color="always"'
  alias cat="bat"
  alias ls="lsd --classify"
  alias l="lsd --long --classify --group-directories-first"
  alias la="lsd --long --almost-all --classify --group-directories-first"
  alias tree="tree -C -a -I .git"
  alias vi='nvim'
  alias json='fx'
  
  # Functions
  function path() {
    echo $PATH | tr ':' '\n'
  }

  # Completions
  source <(kubectl completion zsh)
  source <(op completion zsh)
  source <(fzf --zsh)
  source <(supabase completion zsh)
  source <(docker completion zsh)

  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
  source <(carapace _carapace)
  zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

  [ -s "/Users/michael/.bun/_bun" ] && source "/Users/michael/.bun/_bun"
  
  if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
    ghostcolors=( "brightred" "brightgreen" "brightyellow" "brightblue" "brightmagenta" "brightcyan" "brightwhite")
    ghosttime --color ${ghostcolors[$(($RANDOM % ${#ghostcolors[@]} + 1))]}
  fi

fi

