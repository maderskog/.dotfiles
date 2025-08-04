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

