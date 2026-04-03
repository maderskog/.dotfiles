#!/usr/bin/env zsh
# Interactive cheat sheet — tv picks the action, this script executes it
PANE=$(tmux show-option -gv @caller_pane)
PANE_PATH=$(tmux display-message -t "$PANE" -p '#{pane_current_path}' 2>/dev/null)

action=$(tv tmux-cheatsheet)
[[ -z "$action" ]] && exit 0

case "$action" in
  # ── Popup pickers (chain: close this popup, open new one) ──
  sessions)
    tmux run-shell -b "sleep 0.1 && tmux display-popup -E -w 80% -h 80% 'tv sesh'"
    ;;
  windows)
    tmux run-shell -b "sleep 0.1 && tmux display-popup -E -w 80% -h 80% 'tv tmux-windows'"
    ;;
  files)
    tmux set-option -g @caller_pane "$PANE"
    tmux run-shell -b "sleep 0.1 && tmux display-popup -E -w 80% -h 80% -d '$PANE_PATH' 'zsh ~/.config/tmux/scripts/tv-files.sh'"
    ;;
  grep)
    tmux set-option -g @caller_pane "$PANE"
    tmux run-shell -b "sleep 0.1 && tmux display-popup -E -w 80% -h 80% -d '$PANE_PATH' 'zsh ~/.config/tmux/scripts/tv-grep.sh'"
    ;;
  git)
    tmux run-shell -b "sleep 0.1 && tmux display-popup -E -w 80% -h 80% -d '$PANE_PATH' 'tv git-log'"
    ;;
  cheatsheet)
    tmux set-option -g @caller_pane "$PANE"
    tmux run-shell -b "sleep 0.1 && tmux display-popup -E -w 60% -h 60% 'zsh ~/.config/tmux/scripts/cheatsheet.sh'"
    ;;
  urls)
    tmux set-option -g @caller_pane "$PANE"
    tmux run-shell -b "sleep 0.1 && tmux display-popup -E -w 60% -h 40% 'zsh ~/.config/tmux/scripts/tv-urls.sh'"
    ;;
  float)
    tmux run-shell -b "sleep 0.1 && tmux display-popup -E -w 80% -h 80% -d '$PANE_PATH'"
    ;;

  # ── Panes ──
  vsplit)          tmux split-window -h  -t "$PANE" -c "$PANE_PATH" ;;
  hsplit)          tmux split-window -v  -t "$PANE" -c "$PANE_PATH" ;;
  pane-left)       tmux select-pane  -t "$PANE" -L ;;
  pane-down)       tmux select-pane  -t "$PANE" -D ;;
  pane-up)         tmux select-pane  -t "$PANE" -U ;;
  pane-right)      tmux select-pane  -t "$PANE" -R ;;
  resize-left)     tmux resize-pane  -t "$PANE" -L 5 ;;
  resize-down)     tmux resize-pane  -t "$PANE" -D 5 ;;
  resize-up)       tmux resize-pane  -t "$PANE" -U 5 ;;
  resize-right)    tmux resize-pane  -t "$PANE" -R 5 ;;
  zoom)            tmux resize-pane  -t "$PANE" -Z ;;
  kill-pane)       tmux kill-pane    -t "$PANE" ;;

  # ── Windows ──
  new-window)      tmux new-window       -c "$PANE_PATH" ;;
  next-window)     tmux next-window ;;
  prev-window)     tmux previous-window ;;
  window-[1-9])    tmux select-window -t ":${action##window-}" ;;
  move-window-left)  tmux swap-window -d -t -1 ;;
  move-window-right) tmux swap-window -d -t +1 ;;
  rename-window)   tmux command-prompt -I "#W" "rename-window -- '%%'" ;;
  kill-window)     tmux kill-window ;;

  # ── Sessions ──
  last)            tmux switch-client -l ;;
  rename-session)  tmux command-prompt -I "#S" "rename-session -- '%%'" ;;
  detach)          tmux detach-client ;;

  # ── Copy & utility ──
  copy-mode)       tmux copy-mode -t "$PANE" ;;
  clear)           tmux send-keys -t "$PANE" C-l ;;
  reload)          tmux source-file ~/.config/tmux/tmux.conf \; display-message " Config reloaded" ;;
esac
