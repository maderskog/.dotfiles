#!/usr/bin/env zsh
emulate -R zsh
[[ -f ${ZDOTDIR:-$HOME}/.zshrc ]] && source "${ZDOTDIR:-$HOME}/.zshrc" 2>/dev/null

sanitize() {
    local val=$1
    val=${val//$'\n'/ }
    val=${val//$'\t'/ }
    print -r -- "$val"
}

emit() {
    local kind=$1 name=$2 val=$3
    val=$(sanitize "$val")
    print -r -- "${kind}"$'\t'"${name}"$'\t'"${val}"
}

case ${1:-all} in
    all)
        for k in ${(ok)aliases}; do emit regular "$k" "${aliases[$k]}"; done
        for k in ${(ok)galiases}; do emit global "$k" "${galiases[$k]}"; done
        for k in ${(ok)saliases}; do emit suffix "$k" "${saliases[$k]}"; done
        ;;
    regular)
        for k in ${(ok)aliases}; do emit regular "$k" "${aliases[$k]}"; done
        ;;
    global)
        for k in ${(ok)galiases}; do emit global "$k" "${galiases[$k]}"; done
        ;;
    suffix)
        for k in ${(ok)saliases}; do emit suffix "$k" "${saliases[$k]}"; done
        ;;
    *)
        print -u2 "usage: $0 [all|regular|global|suffix]" >&2
        exit 1
        ;;
esac
