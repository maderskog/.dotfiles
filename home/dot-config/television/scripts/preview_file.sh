#!/usr/bin/env bash
set -euo pipefail

path="$1"
lower_path="$(printf '%s' "$path" | tr '[:upper:]' '[:lower:]')"

if [[ "$lower_path" == *.md || "$lower_path" == *.markdown || "$lower_path" == *.mdx ]]; then
    if command -v glow >/dev/null 2>&1; then
        glow -s dark -w 120 "$path"
        exit 0
    fi
fi

BAT_THEME=ansi bat -n --color=always "$path"
