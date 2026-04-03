#!/usr/bin/env zsh
# Read the caller pane ID (set by run-shell before popup opened)
PANE=$(tmux show-option -gv @caller_pane)
rm -f /tmp/tv-selected
tv files
file=$(cat /tmp/tv-selected 2>/dev/null)
rm -f /tmp/tv-selected
[[ -n "$file" ]] && [[ -n "$PANE" ]] && \
  tmux send-keys -t "$PANE" "nvim -- '$file'" Enter
