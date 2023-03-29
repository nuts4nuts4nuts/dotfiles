#!/bin/bash

# Fix some common wrapping issues
shopt -s checkwinsize

# Putting these here to affect the vim :terminal
set -o vi
bind 'set show-mode-in-prompt on'
stty sane # should normalize backspace issues?

alias conf="git --git-dir=$HOME/dotfiles.git/ --work-tree=$HOME"

alias gpr="git pr"
alias gis="git status"
alias ls="ls --color"
alias la="ls -a --color"
alias ll="ls -l --color"
alias lf="ls -la --color"
alias dirs="dirs -v"
alias sane='stty sane'
alias fix='stty sane; reset; tput rs1; echo -e "\033c"'
alias wich='type -P'
alias witch='type -a'
alias cdr='cd $(dirname $(fzf))'
set -o noclobber
set -o ignoreeof

function catwhich() { which "$@" | xargs cat ;}
function gwhich() { which "$@" | xargs vim ;}
# Open a file in the current vim
function vo() { readlink -f "$@" | xargs printf ']51;["call", "Tapi_Edit", "%s"]\a' ;}
# Open a file in the current nvim with nvr
# Yay!

PROMPT_COMMAND='PS1X=$(p="${PWD#${HOME}}"; [ "${PWD}" != "${p}" ] && printf "~";IFS=/; for q in ${p:1}; do printf /${q:0:1}; done; printf "${q:1}")'
case "$TERM" in
"dumb")
    export PS1="> "
    ;;
xterm*|rxvt*|eterm*|screen*)
    export PS1='\[\033[32m\]\h \[\033[33;1m\]${PS1X} \[\033[m\]\D{%H:%M:%S} $ '
    ;;
*)
    export PS1="> "
    ;;
esac

export LANG=en_US.utf-8
export LC_ALL=en_US.utf-8
export FZF_DEFAULT_COMMAND='rg --files --hidden'
export EDITOR="nvim"
export BAT_THEME="zenburn"
export HISTSIZE=10000
export HISTFILESIZE=10000

pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1${PATH:+"$PATH:"}"
    fi
}

pathadd "/Applications/Racket v8.7/bin/"
pathadd "/Applications/love.app/Contents/MacOS"
pathadd "/opt/homebrew/opt/openjdk/bin"
pathadd "/Users/davidjohnston/Library/Python/3.8/bin"

# load brew stuff
eval "$(/opt/homebrew/bin/brew shellenv)"
