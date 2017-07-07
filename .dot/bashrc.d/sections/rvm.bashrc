#!/bin/bash

if [[ -d ~/.rvm/bin ]]; then
  export PATH="${PATH}:${HOME}/.rvm/bin"
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
