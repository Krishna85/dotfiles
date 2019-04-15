#!/bin/bash

function install-rbenv() {
  if [[ ! -d ~/.rbenv ]]; then
    log_info "Downloading rbenv..."
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    init-rbenv
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
  else
    log_warning "~/.rbenv already exists!"
  fi
}

function init-rbenv() {
  if [[ -d ~/.rbenv ]]; then
    log_info "~/.rbenv found, initialising rbenv..."
    export PATH="$HOME/.rbenv/bin:$PATH"

    eval "$(rbenv init -)"
  fi
}

init-rbenv
