#!/bin/bash

function init-vim() {
  # Install all submodules recursively
  cd ~/.vim
  git submodule update --init --recursive
  cd -
}
