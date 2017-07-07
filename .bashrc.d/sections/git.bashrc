#!/bin/bash

# Git aliases
alias rgitstatus="find . -type d -name .git -exec dirname {} \; -execdir git status \;"
alias rgitpull="find . -type d -name .git -exec dirname {} \; -execdir git pull \;"
gitpushall() {
  git push --all $1
  git push --tags $1
}

alias gs="git status"
alias gl="git log"
alias ga="git a"
alias gc="git c"
alias gco="git co"
