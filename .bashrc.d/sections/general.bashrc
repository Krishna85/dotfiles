#!/bin/bash

# ls colours
alias ls='ls --color=auto'

# If ~/.agent exists and we're in an SSH session, source it
if [[ ! -z ${SSH_TTY} ]] || [[ ! -z ${DISPLAY} ]]; then
  if [[ -f ~/.agent ]]; then
    source ~/.agent
  fi
fi

# Set vim as the default editor
export EDITOR=vim
alias vi="vim"

PATH="${HOME}/bin:${PATH}"
