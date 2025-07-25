# FZF-Tab Configuration

# Basic fzf-tab settings
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no

# Smart preview function
local smart_preview='[[ -f $realpath ]] && bat --color=always --style=numbers --line-range=:500 $realpath || lsd --color=always --classify --group-directories-first $realpath'

# Basic command previews
zstyle ':fzf-tab:complete:z:*' fzf-preview $smart_preview
zstyle ':fzf-tab:complete:nvim:*' fzf-preview $smart_preview
zstyle ':fzf-tab:complete:bat:*' fzf-preview $smart_preview
zstyle ':fzf-tab:complete:lsd:*' fzf-preview $smart_preview
zstyle ':fzf-tab:complete:rm:*' fzf-preview $smart_preview

# Enhanced fzf-tab previews (macOS optimized)
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps -p $word -o command 2>/dev/null'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $realpath 2>/dev/null || bat --color=always $realpath'
zstyle ':fzf-tab:complete:ssh:*' fzf-preview '[[ -f ~/.ssh/config ]] && grep -A 5 -B 1 "^Host $word" ~/.ssh/config'
zstyle ':fzf-tab:complete:(export|unset):*' fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:brew-(install|info|uninstall):*' fzf-preview 'brew info $word 2>/dev/null'
zstyle ':fzf-tab:complete:brew-services-(start|stop|restart):*' fzf-preview 'brew services info $word 2>/dev/null'
zstyle ':fzf-tab:complete:man:*' fzf-preview 'man $word 2>/dev/null | head -50'
zstyle ':fzf-tab:complete:launchctl-(load|unload|start|stop):*' fzf-preview 'launchctl print $word 2>/dev/null || launchctl list | grep $word'
zstyle ':fzf-tab:complete:docker-(start|stop|rm):*' fzf-preview 'docker inspect --format="{{.State.Status}}: {{.Config.Image}}" $word 2>/dev/null'
zstyle ':fzf-tab:complete:open:*' fzf-preview '[[ -f $realpath ]] && file $realpath || [[ -d $realpath ]] && ls -la $realpath'

# Custom fzf flags
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept --preview-window=right:50%:wrap --height=50% --min-height=20
zstyle ':fzf-tab:*' switch-group '<' '>'

# Other completion styles
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'

