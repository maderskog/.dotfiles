#!/usr/bin/env bash
set -euo pipefail

path="$1"

if command -v eza >/dev/null 2>&1; then
    eza --all --color=always --tree --level=2 "$path"
    exit 0
fi

if command -v tree >/dev/null 2>&1; then
    tree -a -L 2 -C "$path"
    exit 0
fi

find "$path" -maxdepth 2 -print 2>/dev/null | sed "1d; s#^$path#.#"
