# Zsh-native PATH management
# -U ensures unique elements, keeping the PATH clean.
# The order of assignment determines precedence (first is highest).

typeset -U path
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/Library/pnpm"
  "$HOME/.bun/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  "/Applications/Postgres.app/Contents/Versions/latest/bin"
  "/Users/michael/Library/Application Support/JetBrains/Toolbox/scripts"
  # Homebrew path is typically added by 'brew shellenv'
  # asdf shims are added by its own script
  $path
)

export PATH
