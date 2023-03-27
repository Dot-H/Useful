export SHELL=/bin/zsh
export TERMINAL=urxvt
export PATH=$PATH:/usr/local/go/bin:/home/doth/.local/bin
export PATH=~/.npm-global/bin:$PATH

[[ -f ~/.zshrc ]] && . ~/.zshrc
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    exec startx
fi
# Add .NET Core SDK tools
export PATH="$PATH:/Users/alexandrebernard/.dotnet/tools"
