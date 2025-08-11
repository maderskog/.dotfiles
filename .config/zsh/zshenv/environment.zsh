# Environment Variables
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export ERL_AFLAGS="-kernel shell_history enabled"
export LDFLAGS="-L$(brew --prefix zbar)/lib ${LDFLAGS}"
export CFLAGS="-I$(brew --prefix zbar)/include ${CFLAGS}"
export POETRY_VIRTUALENVS_IN_PROJECT=true
export VISUAL=nvim
export EDITOR="$VISUAL"

