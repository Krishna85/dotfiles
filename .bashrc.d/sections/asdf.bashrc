#!/bin/bash

function install-asdf() {
  if [[ ! -d ~/.asdf ]]; then
    log_info "Downloading asdf..."
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.6.2
    r
  else
    log_warning "~/.asdf already exists!"
  fi
}

if [[ -d ~/.asdf ]]; then
  log_info "~/.asdf found, initialising asdf..."
  source ${HOME}/.asdf/asdf.sh
  source ${HOME}/.asdf/completions/asdf.bash
fi
