export ZSH="$HOME/.oh-my-zsh"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

DISABLE_AUTO_TITLE="true"
plugins=(
    git
    urltools
    zsh-autosuggestions
    zsh-syntax-highlighting
    dir-history
    rust
    safe-paste
    sudo
)

source $ZSH/oh-my-zsh.sh
source `npm root -g`/zsh-history-enquirer/scripts/zsh-history-enquirer.plugin.zsh

alias vim="lvim"
alias ls="exa"
alias grep="rg"
eval "$(starship init zsh)"
. ~/.config/z.sh
