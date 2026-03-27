# Functions Configuration

# k9s wrapper: automatically applies the red prod-danger skin to any
# cluster config whose path contains "prod" (case-insensitive).
# This covers both the initial launch context AND switching contexts
# inside k9s, since k9s reads per-cluster configs on context switch.
function k9s() {
    local k9s_dir="$HOME/.config/k9s"
    local k9s_config="$k9s_dir/config.yaml"

    # Set global skin based on current kubectl context
    local ctx
    ctx="$(command kubectl config current-context 2>/dev/null)"
    if [[ "${ctx:l}" == *prod* ]]; then
        sed -i '' 's/skin: .*/skin: prod-danger/' "$k9s_config"
    else
        sed -i '' 's/skin: .*/skin: transparant/' "$k9s_config"
    fi

    # Inject skin overrides into every per-cluster config so that
    # switching contexts inside k9s also triggers the right skin.
    local cluster_cfg
    for cluster_cfg in "$k9s_dir"/clusters/*/*/config.yaml(N); do
        local lower_path="${cluster_cfg:l}"
        if [[ "$lower_path" == *prod* ]]; then
            # Add skin if missing, or update if present
            if grep -q '^\s*skin:' "$cluster_cfg" 2>/dev/null; then
                sed -i '' 's/^\(\s*\)skin: .*/\1skin: prod-danger/' "$cluster_cfg"
            else
                sed -i '' '/^k9s:$/a\
\  skin: prod-danger' "$cluster_cfg"
            fi
        else
            # Explicitly set default skin so switching from prod resets the theme
            if grep -q '^\s*skin:' "$cluster_cfg" 2>/dev/null; then
                sed -i '' 's/^\(\s*\)skin: .*/\1skin: transparant/' "$cluster_cfg"
            else
                sed -i '' '/^k9s:$/a\
\  skin: transparant' "$cluster_cfg"
            fi
        fi
    done

    command k9s "$@"
}

function path() {
  echo $PATH | tr ':' '\n'
}

function f() {
    local tmp="$(mktemp -t "yazi-cd.XXX")"
    yazi --cwd-file="$tmp"
    if [ -f "$tmp" ]; then
        if [ "$(cat -- "$tmp")" != "$(pwd)" ]; then
            z "$(cat -- "$tmp")"
        fi
        rm -f -- "$tmp"
    fi
}

function zj() {
    local active_sessions=$(zellij list-sessions -n 2>/dev/null)

    local count=$(echo "$active_sessions" | grep -v "^$" | wc -l)

    if [[ $count -eq 0 ]]; then
        echo "No active sessions. Starting 'main'..."
        zellij -s main

    elif [[ $count -eq 1 ]]; then
        local session_name=$(echo "$active_sessions" | awk '{print $1}')
        zellij attach "$session_name"

    else
        local choice=$(echo "$active_sessions" | fzf --prompt="Select Session: " --header="Multiple sessions found")

        if [[ -n "$choice" ]]; then
            local session_name=$(echo "$choice" | awk '{print $1}')
            zellij attach "$session_name"
        fi
    fi
}

# Directory bookmarks
function mark() {
  echo "export DIR_$1='$(pwd)'" >> ~/.dir_marks
  source ~/.dir_marks
}

function jump() {
  local mark_name="DIR_$1"
  cd "${(P)mark_name}" 2>/dev/null || echo "Mark '$1' not found"
}

function marks() {
  env | grep "^DIR_" | sed 's/^DIR_//' | sed 's/=/ -> /' | sort
}

# Utility functions
function extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

function mkcd() {
  mkdir -p "$1" && cd "$1"
}

function fkill() {
  ps aux | fzf | awk '{print $2}' | xargs kill -9
}

function secrets() {
  source ~/.config/zsh/zshenv/secrets.zsh
}

function brew-history() {
    local LOG_DIR="$HOME/brew/logs"

    if [[ -z "$1" ]]; then
        echo "Usage: brew-history <search_term>"
        return 1
    fi

    rg -i "$1" "$LOG_DIR" --sort path
}

function ghost() {
    ghosttime --no-focus-pause --color ${ghostcolors[$(($RANDOM % ${#ghostcolors[@]} + 1))]}
}
function check-url() {
    local url=""
    local wait=5

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --wait)
                wait="$2"
                shift 2
                ;;
            *)
                url="$1"
                shift
                ;;
        esac
    done

    if [[ -z "$url" ]]; then
        echo "Usage: check_url <url> [--wait <seconds>]" >&2
        return 1
    fi

    while true; do
        local ts="$(date '+%F %T')"
        if curl -sSfk -o /dev/null "$url"; then
            echo "$ts SUCCESS: $url"
        else
            echo "$ts FAIL:    $url"
        fi
        sleep "$wait"
    done
}
