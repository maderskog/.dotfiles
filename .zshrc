# Zinit plugins
zinit ice wait lucid
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light MichaelAquilina/zsh-autoswitch-virtualenv

# Zinit snippets
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
alias cd='z'
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
function y() {
    local tmp="$(mktemp -t "yazi-cd.XXX")"
    yazi --cwd-file="$tmp"
    if [ -f "$tmp" ]; then
        if [ "$(cat -- "$tmp")" != "$(pwd)" ]; then
            z "$(cat -- "$tmp")"
        fi
        rm -f -- "$tmp"
    fi
}

# Source Completions
source <(kubectl completion zsh)
source <(op completion zsh)
source <(fzf --zsh)
source <(supabase completion zsh)
source <(docker completion zsh)

# Carapace
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)
zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

# Bun completions
[ -s "/Users/michael/.bun/_bun" ] && source "/Users/michael/.bun/_bun"

# Ghostty prompt
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  ghostcolors=( "brightred" "brightgreen" "brightyellow" "brightblue" "brightmagenta" "brightcyan" "brightwhite")
  ghosttime --color ${ghostcolors[$(($RANDOM % ${#ghostcolors[@]} + 1))]}
fi

