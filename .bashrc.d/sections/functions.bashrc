#!/bin/bash

function set-proxy() {
  ADDRESS=$1
  PORT=$2
  if [[ -z ${ADDRESS} ]]; then
    unset http_proxy
    unset https_proxy
    echo "Unset http_proxy and https_proxy."
  else
    if [[ -z ${PORT} ]]; then
      PORT="3128"
    fi
    export http_proxy="http://${ADDRESS}:${PORT}/"
    export https_proxy="http://${ADDRESS}:${PORT}/"
    echo "Set http_proxy and https_proxy to http://${ADDRESS}:${PORT}/"
  fi
}

function ssh-key-auth() {
  ON_OFF=$1

  if [[ ${ON_OFF} = "off" ]]; then
    if [[ -z ${SSH_AUTH_SOCK} ]]; then
      echo "SSH agent authentication not enabled."
      return 1
    else
      DISABLED_SSH_AUTH_SOCK="${SSH_AUTH_SOCK}"
      unset SSH_AUTH_SOCK
      echo "Disabled SSH agent authentication."
    fi
  else
    if [[ ! -z ${SSH_AUTH_SOCK} ]]; then
      echo "SSH agent authentication already enabled (SSH_AUTH_SOCK already set)."
      return 1
    elif [[ -z ${DISABLED_SSH_AUTH_SOCK} ]]; then
      echo "No previous SSH_AUTH_SOCK setting found."
      return 1
    else
      SSH_AUTH_SOCK="${DISABLED_SSH_AUTH_SOCK}"
      export SSH_AUTH_SOCK
      unset DISABLED_SSH_AUTH_SOCK
      echo "Re-enabled SSH agent authentication."
    fi
  fi
}

function agent() {
  log_info "Starting SSH agent..."
  ssh-agent >~/.agent
  source ~/.agent >/dev/null
  log_info "SSH agent started with PID ${F_GREEN}${SSH_AGENT_PID}${CLR}"
}

function b() {
  CMD=$1
  MSG="$2"

  if [[ ${CMD} = "sec" ]]; then
    cd ~/.bashrc.d/sections
    ls
  elif [[ ${CMD} = "diff" ]]; then
    git --work-tree ${HOME} --git-dir ${HOME}/.git diff
  elif [[ ${CMD} = "pull" ]]; then
    git --work-tree ${HOME} --git-dir ${HOME}/.git pull
  elif [[ ${CMD} = "push" ]]; then
    git --work-tree ${HOME} --git-dir ${HOME}/.git push
  elif [[ ${CMD} = "j" ]]; then
    git --work-tree ${HOME} --git-dir ${HOME}/.git add ~/.journal ~/.jrnl_config
    git --work-tree ${HOME} --git-dir ${HOME}/.git commit -m "Commited journal entries"
    git --work-tree ${HOME} --git-dir ${HOME}/.git push
  elif [[ ${CMD} = "b" ]]; then
    if [[ -z ${MSG} ]]; then
      echo "No message given."
      return 1
    fi
    git --work-tree ${HOME} --git-dir ${HOME}/.git add ~/.bashrc.d/sections
    git --work-tree ${HOME} --git-dir ${HOME}/.git commit -m "${MSG}"
    git --work-tree ${HOME} --git-dir ${HOME}/.git push
  else
    echo -e "\n${F_PURPLE}dotfile${CLR} status"
    echo "--------------------------------------------------"
    git --work-tree ${HOME} --git-dir ${HOME}/.git status
    echo "--------------------------------------------------"
    git --work-tree ${HOME} --git-dir ${HOME}/.git log -1
    echo -e ""
  fi
}
