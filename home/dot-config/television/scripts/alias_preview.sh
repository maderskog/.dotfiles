#!/usr/bin/env zsh
emulate -R zsh
readonly L=$'\033[36m'
readonly R=$'\033[0m'
readonly D=$'\033[2m'
readonly ARROW=$'\u2192'

line=$1
IFS=$'\t' read -r kind name exp <<<"$line"

case $kind in
    global) kind_label="global" ;;
    suffix) kind_label="suffix" ;;
    *) kind_label="regular" ;;
esac

print -r -- "${L}Alias:${R} ${name} (${kind_label})"
print
print -r -- "${L}Expansion:${R}"
print -r -- "  ${ARROW} ${exp}"
print
print -r -- "${L}Defined in:${R}"

case $kind in
    global) needle="alias -g ${name}=" ;;
    suffix) needle="alias -s ${name}=" ;;
    *) needle="alias ${name}=" ;;
esac

paths=()
[[ -f ${ZDOTDIR:-$HOME}/.zshrc ]] && paths+=("${ZDOTDIR:-$HOME}/.zshrc")
[[ -d $HOME/.config/zsh ]] && paths+=("$HOME/.config/zsh")
zinit_root="${XDG_DATA_HOME:-$HOME/.local/share}/zinit"
[[ -d $zinit_root ]] && paths+=("$zinit_root")

if (( ${#paths} == 0 )); then
    print -r -- "${D}  (no search paths)${R}"
    exit 0
fi

if command -v rg >/dev/null 2>&1; then
    out=$(rg -n -F -- "$needle" "${paths[@]}" 2>/dev/null | head -8)
else
    out=$(grep -R -n -F -- "$needle" "${paths[@]}" 2>/dev/null | head -8)
fi

if [[ -n $out ]]; then
    print -r -- "${out//$HOME/~}"
else
    print -r -- "${D}  Not found under ~/.zshrc, ~/.config/zsh, or ~/.local/share/zinit.${R}"
    print -r -- "${D}  (May be from eval, a zinit ice, or another loader.)${R}"
fi
