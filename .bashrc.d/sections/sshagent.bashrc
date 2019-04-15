#!/bin/bash
# Handle ssh-agent

function is_ssh_agent_alive() {
  # Check that the agent is running
  IS_RUNNING=$(pgrep ssh-agent | grep ${SSH_AGENT_PID})

  if [[ ! -z ${IS_RUNNING} ]]; then
    log_info "Found SSH agent running with PID ${F_GREEN}${SSH_AGENT_PID}${CLR}"
    return 0
  else
    log_warning "SSH agent with PID ${F_GREEN}${SSH_AGENT_PID}${CLR} was dead, removing .agent"
    rm ~/.agent
    unset SSH_AUTH_SOCK
    unset SSH_AGENT_PID
    return 1
  fi
}

function has_ssh_agent() {
  # If SSH_AUTH_SOCK is set already, then do nothing
  if [[ ! -z ${SSH_AUTH_SOCK} && -z ${SSH_AGENT_PID} ]]; then
    log_info "Forwarded SSH agent detected"
  else
    if [[ -f ~/.agent ]]; then
      # Source it
      source ~/.agent >/dev/null

      is_ssh_agent_alive
      return $?

    else
      log_info "No SSH agent found"
      return 1
    fi
  fi
}

function start_ssh_agent() {
  has_ssh_agent

  if [[ $? -ne 0 ]]; then
    ssh-agent >~/.agent
    source ~/.agent
    log_info "New SSH agent started"
  else
    log_info "SSH agent already available"
  fi
}

has_ssh_agent
