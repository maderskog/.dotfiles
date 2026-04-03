# Functions Configuration


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

# tmux + sesh session launcher
#   t        → open sesh picker (tmux + zoxide + configured sessions)
#   t <name> → connect to / create a named session via sesh
function t() {
  if [[ $# -eq 0 ]]; then
    local result
    result=$(sesh list -tczd | tv)
    [[ -n "$result" ]] && sesh connect "$result"
  else
    sesh connect "$1"
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
