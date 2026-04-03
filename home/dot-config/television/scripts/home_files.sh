#!/usr/bin/env bash
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/television/home-files.txt"
IGNORE="${XDG_CONFIG_HOME:-$HOME/.config}/television/home.fdignore"
TMP=$(mktemp)

cleanup() {
    rm -f "$TMP" 2>/dev/null
}
trap cleanup EXIT

mkdir -p "$(dirname "$CACHE")"

FD_ARGS=(-H -t f . "$HOME")
[ -f "$IGNORE" ] && FD_ARGS+=(--ignore-file "$IGNORE")

# Serve cache immediately
cat "$CACHE" 2>/dev/null || true

# Rebuild, streaming only new entries to stdout as fd finds them
if [ -f "$CACHE" ]; then
    fd "${FD_ARGS[@]}" 2>/dev/null \
        | tee "$TMP" \
        | grep -vxFf "$CACHE" 2>/dev/null
else
    fd "${FD_ARGS[@]}" 2>/dev/null \
        | tee "$TMP"
fi
FD_STATUS="${PIPESTATUS[0]}"

# Only replace cache if fd ran to completion
if [ "$FD_STATUS" -eq 0 ]; then
    mv "$TMP" "$CACHE" 2>/dev/null || true
fi
