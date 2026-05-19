# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/alexandrebernard/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="aphrodite"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# This prevents oh-my-zsh from checking git status for untracked files
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Speed up oh-my-zsh loading
# Skips security checks that slow down startup
ZSH_DISABLE_COMPFIX=true
# Disables URL quoting magic which adds overhead
DISABLE_MAGIC_FUNCTIONS=true

# Cache completion - only rebuild once per day for massive speedup
# This overrides oh-my-zsh's default compinit behavior
autoload -Uz compinit
_comp_files=(${ZDOTDIR:-$HOME}/.zcompdump(Nm-20))
if (( $#_comp_files )); then
    # Cache is less than 20 hours old, use it without checking (-C skips security check)
    compinit -C -d "${ZDOTDIR:-$HOME}/.zcompdump"
else
    # Cache is old or doesn't exist, rebuild it (-u skips security check for speed)
    compinit -C -u -d "${ZDOTDIR:-$HOME}/.zcompdump"
fi
unset _comp_files

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  safe-paste
  colored-man-pages
  history-substring-search
)

# Disable oh-my-zsh's compinit since we already ran it above
skip_global_compinit=1

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

############################
############ Own ###########
############################

# history-substring-search bindings
# Key bindings have been found by doing `cat -v` before hitting search keys
# Binds UP arrow key to search up
bindkey '^[[A' history-substring-search-up
# Binds DOWN arrow key to search down
bindkey '^[[B' history-substring-search-down

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Environment variables
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR=vim
export PGDATA="$HOME/postgres_data"
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=~/.npm-global/bin:$PATH
export PATH=:~/pigment_code/opensource/monorepo/bin:~/pigment_code/opensource/monorepo/tools/pig:$PATH


# Add go PATH
export PATH=$PATH:/usr/local/go/bin

# Double tab customization
# Note: compinit is already called by oh-my-zsh, no need to call it again
setopt COMPLETE_ALIASES
zstyle ':completion:*' menu select

# Kubectl completion
## Allows lazy loading to avoid spending too much time starting a shell
function k() {
    if ! type __start_kubectl >/dev/null 2>&1; then
        source <(command kubectl completion zsh)
        # Autocomplete for the alias
        source <(command kubectl completion zsh | sed s/kubectl/k/g)
    fi

    command kubectl "$@"
}

# Github completion
## Allows lazy loading to avoid spending too much time starting a shell
function gh() {
    if ! type _gh >/dev/null 2>&1; then
        source <(command gh completion -s zsh)
        compdef _gh gh
    fi

    command gh "$@"
}

# Font size setter
termsize() {
    [ $# -eq 0 ] && echo "termsize SIZE" && return 1

    # defaults
    printf '\33]50;%s\007' "xft:Hack:antialias=true:hinting=true:pixelsize=$1"
    printf '\033]711;%s\007' "xft:Hack:bold:antialias=true:hinting=true:pixelsize=$1"
    printf '\033]712;%s\007' "xft:Hack:bold:antialias=true:hinting=true:pixelsize=$1"
    printf '\033]713;%s\007' "xft:Hack:bold:antialias=true:hinting=true:pixelsize=$1"
}

# Listing with colors
alias tree='tree -C'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Forbid rm command
#alias del='trash-put'
#alias rm="1>&2 echo 'plz use del in order to have use the trashcli interface'"

# Silence gdb
alias gdb='gdb -q'

# Typos solver
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias sl='ls'

# Making life easier
alias dcmake='cmake -DCMAKE_BUILD_TYPE=Debug'
alias rcmake='cmake -DCMAKE_BUILD_TYPE=Release'
alias makej='make -j `nproc`'
alias copy='xclip -sel clip'
alias install='sudo apt-get install'

# From source commands
alias rider='/home/doth/Rider/bin/rider.sh'
alias idea='/home/doth/Intellij/idea-IU-181.4203.550/bin/idea.sh'
alias ida32='wine ~/.wine/drive_c/Program\ Files\ \(x86\)/IDA\ 6.8/idaq.exe'
alias ida64='wine ~/.wine/drive_c/Program\ Files\ \(x86\)/IDA\ 6.8/idaq64.exe'
alias ropgadget='python /usr/src/ROPgadget/ROPgadget.py'
alias verilator='~/verilator/bin/verilator'

# Custom commands
alias cMakefile='$HOME/Usefull/cMakefile.sh'
alias cppMakefile='$HOME/Usefull/cppMakefile.sh'
alias gimp='flatpak run org.gimp.GIMP//stable'

export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"

# Pigment
alias pstack="docker compose -f /Users/alexandrebernard/pigment_code/opensource/monorepo/apps/docker-compose.generated.yml"
alias pstack-up="pstack up -d --remove-orphans"
alias pstack-down="pstack down --remove-orphans"

# Path setup
export PATH=/usr/local/share/python:$PATH

# Google Cloud SDK - lazy loaded for performance
# Add to PATH immediately, but defer completion loading
if [ -f '/Users/alexandrebernard/Downloads/google-cloud-sdk/path.zsh.inc' ]; then
    . '/Users/alexandrebernard/Downloads/google-cloud-sdk/path.zsh.inc'
fi

# Lazy-load gcloud completions - only load when gcloud is first used
gcloud() {
    if [ -f '/Users/alexandrebernard/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then
        source '/Users/alexandrebernard/Downloads/google-cloud-sdk/completion.zsh.inc'
    fi
    # Remove this function wrapper after first use
    unfunction gcloud
    command gcloud "$@"
}

function loginAs() {
    local userEmail="$1"
    local port="${2:-8000}"

	password="B7f9HGSXsD@2f6iC8f!"
	token=`curl -X POST -H "Content-Type: application/json" -d "{\"UserEmail\": \"$userEmail\", \"UserPassword\": \"$password\" }" "http://localhost:8000/api/users/Login/PasswordCheck" 2> /dev/null`
	url="http://localhost:$port/login-with-token?token=$token"
	open "$url"
}

# Lazy load toner completion to speed up shell startup
if command -v toner &> /dev/null; then
    source <(toner completion zsh)
fi

# peon-ping quick controls
alias peon="bash ~/.claude/hooks/peon-ping/peon.sh"
[ -f ~/.claude/hooks/peon-ping/completions.bash ] && source ~/.claude/hooks/peon-ping/completions.bash
export PATH="$HOME/.local/bin:$PATH"
