# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH=/home/doth/.oh-my-zsh

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
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

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

# Ok it should not be here soz
setxkbmap gb

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Environment variables
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR=vim
export PGDATA="$HOME/postgres_data"

# Double tab customization
autoload -Uz compinit
compinit
setopt COMPLETE_ALIASES
zstyle ':completion:*' menu select

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
alias del='trash-put'
alias rm="1>&2 echo 'plz use del in order to have use the trashcli interface'"

# Silence gdb
alias gdb='gdb -q'

# Typos solver
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias sl='ls'

# From source commands
alias rider='/home/doth/Rider/bin/rider.sh'
alias idea='/home/doth/Intellij/idea-IU-181.4203.550/bin/idea.sh'
alias dcmake='cmake -DCMAKE_BUILD_TYPE=Debug'
alias ida32='wine ~/.wine/drive_c/Program\ Files\ \(x86\)/IDA\ 6.8/idaq.exe'
alias ida64='wine ~/.wine/drive_c/Program\ Files\ \(x86\)/IDA\ 6.8/idaq64.exe'
alias ropgadget='python /usr/src/ROPgadget/ROPgadget.py'
alias verilator='~/verilator/bin/verilator'

# Custom commands
alias cMakefile='$HOME/Usefull/cMakefile.sh'
alias cppMakefile='$HOME/Usefull/cppMakefile.sh'
