export SHELL=/bin/zsh
export TERMINAL=urxvt
export PATH=$PATH:/usr/local/go/bin:/home/doth/.local/bin
export PATH=~/.npm-global/bin:$PATH
export DOTNET_ROOT=/usr/local/bin

[[ -f ~/.zshrc ]] && . ~/.zshrc
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    exec startx
fi
# Add .NET Core SDK tools
export PATH="$PATH:/Users/alexandrebernard/.dotnet/tools"

eval "$(/opt/homebrew/bin/brew shellenv)"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# add pigment utility
export PATH=/Users/alexandrebernard/pigment_code/opensource/monorepo/tools/pig/pig
