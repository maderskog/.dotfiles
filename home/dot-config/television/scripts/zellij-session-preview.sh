#!/usr/bin/env bash
session="$1"

layout=$(zellij --session "$session" action dump-layout 2>/dev/null)

if [[ -z "$layout" ]]; then
    zellij list-sessions --no-formatting | grep "^$session "
    echo ""
    echo "  (no layout available — session may be exited)"
    exit 0
fi

zellij list-sessions --no-formatting | grep "^$session "
echo ""

in_tab=false
while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*cwd\ \"([^\"]+)\" ]] && [[ "$in_tab" == false ]]; then
        echo "📂 ${BASH_REMATCH[1]}"
        echo ""
    elif [[ "$line" =~ tab\ name=\"([^\"]+)\" ]]; then
        in_tab=true
        echo "━━ ${BASH_REMATCH[1]}"
    elif [[ "$line" =~ pane\ command=\"([^\"]+)\" ]]; then
        cmd="${BASH_REMATCH[1]}"
        echo "    ▸ ${cmd##*/}"
    fi
done <<< "$layout"
