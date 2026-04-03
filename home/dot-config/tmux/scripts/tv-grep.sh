#!/usr/bin/env zsh
# Read the caller pane ID (set by run-shell before popup opened)
PANE=$(tmux show-option -gv @caller_pane)
rm -f /tmp/tv-selected
tv text
result=$(cat /tmp/tv-selected 2>/dev/null)
rm -f /tmp/tv-selected
[[ -z "$result" ]] && exit 0
file=$(echo "$result" | head -1)
line=$(echo "$result" | tail -1)
[[ -n "$file" ]] && [[ -n "$PANE" ]] && \
  tmux send-keys -t "$PANE" "nvim +$line -- '$file'" Enter
