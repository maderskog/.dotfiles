# My dotfiles

> These are my dotfiles. There are many like them, but these are mine.

## Contents

| File / Directory | What it is |
|---|---|
| `dot-config/ghostty/` | Terminal emulator config |
sources files from `dot-config/zsh/` |
| `dot-config/k9s/` | Kubernetes TUI config and skins |
| `dot-config/mise/` | Runtime version manager config (replaces asdf) |
| `dot-config/nushell/` | Nushell config |
| `dot-config/nvim/` | Neovim config (LazyVim) |
| `dot-config/oh-my-posh/` | Prompt theme |
| `dot-config/television/` | `tv` config, custom cable channels, and helper scripts |
| `dot-config/tmux/` | Tmux config and popup scripts (plugins managed by TPM at runtime) |
| `dot-config/yazi/` | File manager config and plugins |
| `dot-config/zed/` | Zed editor settings and custom theme |
| `dot-config/zellij/` | Zellij layout and theme |
| `dot-config/zsh/` | Zsh config split by concern: aliases, functions, keybindings, plugins, etc. |
| `Brewfile` | All system tools and GUI apps, managed by `brew bundle` |
| `dot-gitconfig` | Git config — identity lives in `~/.gitconfig.local` (not tracked) |
| `dot-gitignore.global` | Global gitignore |
| `dot-iex.exs` | IEx (Elixir REPL) config |
| `dot-zshrc` / `dot-zshenv` / `dot-zprofile` | Zsh entrypoints — each just 

## Setup

### 1. Install prerequisites

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow
```

### 2. Clone and link

```bash
git clone https://github.com/maderskog/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow home
```

### 3. Install tools

```bash
brew bundle install
```

### 4. Install language runtimes

```bash
mise install
```

### 5. Restore your personal agent files list

Create `~/.config/television/agent-files.toml` with your own project entries (see the script for the format). This file is intentionally not tracked.

### 6. Install Neovim plugins

Open `nvim` — LazyVim will bootstrap itself on first launch.

### 7. Install tmux plugins

Start tmux and press `<prefix> I` to install plugins via TPM.

---

## Machine-local config

Git identity and any machine-specific settings go in `~/.gitconfig.local` (not tracked):

```ini
[user]
    name = Your Name
    email = you@example.com
    signingkey = <your-key>

[commit]
    gpgsign = true
```

---

## Managing packages

### Add a brew package

```bash
brew install <package>
cd ~/.dotfiles
brew bundle dump --force
git add home/Brewfile
git commit -m "feat: add <package>"
```

### Remove a brew package

```bash
# Remove the line from home/Brewfile, then:
brew bundle cleanup --force
```
