if [[ -o interactive ]] && [[ -t 1 ]] && [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  ghostcolors=( "brightred" "brightgreen" "brightyellow" "brightblue" "brightmagenta" "brightcyan" "brightwhite")
  ghosttime --no-focus-pause -t 4 --color ${ghostcolors[$(($RANDOM % ${#ghostcolors[@]} + 1))]}
fi
# if [[ -n "$(command -v fastfetch)" ]]; then
#   if [[ -n "$(command -v lolcat)" ]]; then
#     fastfetch | lolcat
#   else
#     fastfetch
#   fi
# fi
