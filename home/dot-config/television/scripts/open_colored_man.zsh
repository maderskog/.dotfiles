#!/usr/bin/env zsh

setopt local_options no_nomatch

autoload -U colors
colors

source $HOME/.local/share/zinit/snippets/OMZP::colored-man-pages/OMZP::colored-man-pages

colored man "$1" "$2"
