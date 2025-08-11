# asdf Version Manager
source "$(brew --prefix asdf)/libexec/asdf.sh"

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PATH:$PNPM_HOME" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$PATH:$BUN_INSTALL/bin"

# Rust/Cargo
[ -s "$HOME/.cargo/env" ] && \. "$HOME/.cargo/env"

# Elixir/Erlang
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac --with-ssl=$(brew --prefix openssl@3)"

