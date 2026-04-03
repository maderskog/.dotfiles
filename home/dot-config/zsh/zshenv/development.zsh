# Go
export GOPATH=$HOME/go

# Node / pnpm
export PNPM_HOME="$HOME/Library/pnpm"

# Bun
export BUN_INSTALL="$HOME/.bun"

# Rust/Cargo
[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Elixir/Erlang
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac --with-ssl=$(brew --prefix openssl@3)"
export ERL_AFLAGS="-kernel shell_history enabled"

# Python
export POETRY_VIRTUALENVS_IN_PROJECT=true

# zbar (QR/barcode native extension) — only if installed
if brew --prefix zbar &>/dev/null; then
    export LDFLAGS="-L$(brew --prefix zbar)/lib ${LDFLAGS}"
    export CFLAGS="-I$(brew --prefix zbar)/include ${CFLAGS}"
fi

# Kubernetes
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export K9S_CONFIG_DIR="${HOME}/.config/k9s"
