#!/bin/bash

function install-pyenv() {
  if [[ ! -d ~/.pyenv ]]; then
    log_info "Downloading pyenv..."
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    r
  else
    log_warning "~/.pyenv already exists!"
  fi
}

if [[ -d ~/.pyenv ]]; then
  log_info "~/.pyenv found, initialising pyenv..."
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"

  eval "$(pyenv init -)"
fi
