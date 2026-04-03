#!/usr/bin/env zsh
# Extract URLs from pane, auto-open if only one, otherwise pick with tv
PANE=$(tmux show-option -gv @caller_pane)
urls=(${(f)"$(tmux capture-pane -t "$PANE" -p -S -200 | grep -oE 'https?://[^ )>\"'"'"']+' | sort -u)"})

if [[ ${#urls[@]} -eq 0 ]]; then
  echo "No URLs found" && sleep 1 && exit 0
elif [[ ${#urls[@]} -eq 1 ]]; then
  open "$urls[1]"
else
  selected=$(printf '%s\n' "${urls[@]}" | tv --no-preview --no-remote)
  [[ -n "$selected" ]] && open "$selected"
fi
