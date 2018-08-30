#!/bin/bash

# ls colours
alias ls='ls --color=auto'
source ~/.bashrc.d/sections/colours.bashrc

# If ~/.agent exists and we're in an SSH session, source it
#if [[ ! -z ${SSH_TTY} ]] || [[ ! -z ${DISPLAY} ]]; then
#  if [[ -f ~/.agent ]]; then
#    source ~/.agent
#  fi
#fi

# Set vim as the default editor
export EDITOR=vim
alias vi="vim"

# If the terminal is screen, set it to screen-256color
if [[ ${TERM} = "screen" ]]; then
  export TERM="screen-256color"
fi

function _log_prefix() {
  PREFIX_TYPE=$1

  case ${PREFIX_TYPE} in
    debug)
      PREFIX_COLOUR=${F_PURPLE}
      PREFIX="==="
      ;;
    info)
      PREFIX_COLOUR=${F_GREEN}
      PREFIX="+++"
      ;;
    notice)
      PREFIX_COLOUR=${F_YELLOW}
      PREFIX="ooo"
      ;;
    warning)
      PREFIX_COLOUR=${F_ORANGE}
      PREFIX="!!!"
      ;;
    error)
      PREFIX_COLOUR=${F_RED}
      PREFIX="xxx"
      ;;
  esac

  echo -e "${F_MIDGREY}[${PREFIX_COLOUR}${PREFIX}${F_MIDGREY}]${CLR} "
}

function log_debug() {
  MSG="$1"
  echo -e "$(_log_prefix debug)${MSG}"
}

function log_info() {
  MSG="$1"
  echo -e "$(_log_prefix info)${MSG}"
}

function log_notice() {
  MSG="$1"
  echo -e "$(_log_prefix notice)${MSG}"
}

function log_warning() {
  MSG="$1"
  echo -e "$(_log_prefix warning)${MSG}"
}

function log_error() {
  MSG="$1"
  echo -e "$(_log_prefix error)${MSG}"
}

function add_to_path_if_exists() {
  TEST_PATH="$1"

  if [[ -d ${TEST_PATH} ]]; then
    log_info "Adding ${F_YELLOW}${TEST_PATH}${CLR} to path..."
    export PATH="${TEST_PATH}:${PATH}"
  fi
}

log_info "${F_GREEN}TERM${CLR} is set to ${F_YELLOW}${TERM}${CLR}"

if [[ ! -z ${LD_LIBRARY_PATH} ]]; then
  log_info "${F_GREEN}LD_LIBRARY_PATH${CLR} is set to ${F_YELLOW}${LD_LIBRARY_PATH}${CLR}"
fi

PATH="${HOME}/bin:${PATH}"

function r() {
  log_notice "Reloading .bashrc..."
  . ~/.bashrc
}

function show-path() {
  for P in $(echo ${PATH} | sed -e 's/:/ /g'); do
    log_info ${P}
  done
}
