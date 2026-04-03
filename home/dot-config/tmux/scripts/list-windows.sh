#!/usr/bin/env zsh
# List tmux windows in natural order, mark current with ●
# Usage: list-windows.sh [-a]  (-a = all sessions)
flag="${1:-}"

caller=$(tmux show-option -gv @caller_pane 2>/dev/null)
if [[ -n "$caller" ]]; then
  current=$(tmux display-message -t "$caller" -p '#{session_name}:#{window_index}')
else
  current=$(tmux display-message -p '#{session_name}:#{window_index}')
fi

tmux list-windows $flag -F $'#{session_name}:#{window_index}\t#{window_name}\t#{pane_current_command}\t#{pane_current_path}' | while IFS=$'\t' read -r id name cmd path; do
  if [[ "$id" == "$current" ]]; then
    printf '●\t%s\t%s\t%s\t%s\n' "$id" "$name" "$cmd" "$path"
  else
    printf ' \t%s\t%s\t%s\t%s\n' "$id" "$name" "$cmd" "$path"
  fi
done
