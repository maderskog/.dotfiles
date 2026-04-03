#!/usr/bin/env bash
# tv-windows.sh — tmux window manager powered by television
# Called from tmux popup with CLIENT env var set to parent client tty

set -euo pipefail

CLIENT="${CLIENT:-}"

while true; do
  # Build window list: session:index  name  path
  windows=$(tmux list-windows -a -F '#S:#I  #W  #{pane_current_path}')

  result=$(echo "$windows" | tv \
    --no-preview \
    --expect='ctrl-n,ctrl-x,ctrl-r' \
    --input-header='  enter=switch  ^n=new  ^x=close  ^r=rename' \
    2>/dev/null) || exit 0

  [ -z "$result" ] && exit 0

  # --expect always outputs: line1=key, line2=entry
  # For enter: line1=enter (or empty), line2=entry
  key=$(echo "$result" | head -1)
  entry=$(echo "$result" | tail -1)

  # If key equals entry, enter was pressed (single-line output)
  if [ "$key" = "$entry" ]; then
    key=""
  fi

  target=$(echo "$entry" | awk '{print $1}')
  session="${target%%:*}"

  case "$key" in
    ctrl-n)
      tmux new-window -t "$session:"
      # Loop back to show updated list
      continue
      ;;
    ctrl-x)
      tmux kill-window -t "$target" 2>/dev/null
      # Loop back to show updated list
      continue
      ;;
    ctrl-r)
      printf "New name: "
      read -r newname
      [ -n "$newname" ] && tmux rename-window -t "$target" "$newname"
      # Loop back to show updated list
      continue
      ;;
    *)
      # Switch to selected window
      if [ -n "$CLIENT" ]; then
        tmux switch-client -c "$CLIENT" -t "$target" 2>/dev/null
      else
        tmux switch-client -t "$target" 2>/dev/null
      fi
      exit 0
      ;;
  esac
done
