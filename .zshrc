# Zinit plugins
zinit ice wait lucid
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
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

# Source Completions BEFORE fzf-tab
source <(kubectl completion zsh)
source <(op completion zsh)
source <(supabase completion zsh)
source <(docker completion zsh)

# Carapace BEFORE fzf-tab
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
source <(carapace _carapace)

compinit -C

# Need to load fzf-tab AFTER completions and carapace
zinit light Aloxaf/fzf-tab

zinit cdreplay -q

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# Smart preview: show file content for files, directory content for directories
local smart_preview='[[ -f $realpath ]] && bat --color=always --style=numbers --line-range=:500 $realpath || lsd --color=always --classify --group-directories-first $realpath'

# preview directory's content when completing these commands
zstyle ':fzf-tab:complete:z:*' fzf-preview $smart_preview
zstyle ':fzf-tab:complete:nvim:*' fzf-preview $smart_preview
zstyle ':fzf-tab:complete:bat:*' fzf-preview $smart_preview
zstyle ':fzf-tab:complete:lsd:*' fzf-preview $smart_preview
zstyle ':fzf-tab:complete:rm:*' fzf-preview $smart_preview

# custom fzf flags
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# Other zstyles AFTER fzf-tab
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

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

# Bun completions
[ -s "/Users/michael/.bun/_bun" ] && source "/Users/michael/.bun/_bun"

# Ghostty prompt
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  ghostcolors=( "brightred" "brightgreen" "brightyellow" "brightblue" "brightmagenta" "brightcyan" "brightwhite")
  ghosttime --color ${ghostcolors[$(($RANDOM % ${#ghostcolors[@]} + 1))]}
fi

