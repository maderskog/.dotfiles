# My dotfiles

> These are my dotfiles. There are many like them, but these are mine.


## Contents
-   **`Brewfile`**: Declares all system-level utilities and GUI applications. Managed by **`brew`**.
-   **`.tool-versions`**: Declares all language runtimes and development CLIs. Managed by **`asdf`**.
-   **`.config`** Config files for `ghostty`, `oh-my-posh`, `zed` and `zsh`
-   **`.zshrc`, `.zshenv` and `.zprofile`** All things zsh
-   **`.iex.exs`** For all the Elixir lovers out there!
-   **`.gitconfig` and `.gitignore.global`** Git stuff :) 


## Setup


1.  **Install prerequisites**:
    ```bash
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Install Stow
    brew install stow
    ```

2.  **Clone this repo**:
    ```bash
    cd ~
    git clone https://github.com/maderskog/.dotfiles.git
    ```

3.  **Link the configuration files**:
    ```bash
    cd ~/.dotfiles
    stow home
    ```

4.  **Install All Declared Tools**:
    ```bash
    cd ~
    # Install all applications and tools from the Brewfile
    brew bundle install
    
    ```

Your machine should now match the state declared in this repository.



### Add a new brew package

1.  **Install the new package**:
    ```bash
    brew install <new-package>
    ```

2.  **Update the `Brewfile`**:
    ```bash
    cd ~/.dotfiles
    brew bundle dump --force
    ```

3.  **Commit the change**:
    ```bash
    git add Brewfile
    git commit -m "feat: Add <new-package>"
    ```

### Remove a brew package

1.  **Edit the `Brewfile`**:
    Open `~/.dotfiles/Brewfile` and delete the line for the package you want to remove.

2.  **Apply the change**:
    ```bash
    cd ~/.dotfiles
    brew bundle cleanup --force
    ```

3.  **Commit the change**:
    ```bash
    git add Brewfile
    git commit -m "refactor: Remove unused-tool"
    ```
