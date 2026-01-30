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

export ICON_CHEVRON_RIGHT="\uf054"
export ICON_CHEVRON_LEFT="\uf053"
export ICON_VIM="\ue7c5"
export ICON_CLOCK="\uf43a"
export ICON_CROSS="\uf467"
export ICON_GIT_BRANCH="\uf418"
export ICON_GIT_STASH="\uf51e"
export ICON_GIT_CONFLICT="\ue727"
export ICON_ELIXIR="\ue62d"
export ICON_PYTHON="\ue73c"
export ICON_NODE="\ue718"
export ICON_PACKAGE="\uf487"
export ICON_AWS_LOGO="\ue7ad"
export ICON_K8S Wheel="\udc7e"
