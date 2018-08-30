#!/bin/bash
# Handle ssh-agent

function is_ssh_agent_alive() {
  # Check that the agent is running
  IS_RUNNING=$(pgrep ssh-agent | grep ${SSH_AGENT_PID})

  if [[ ! -z ${IS_RUNNING} ]]; then
    log_info "Found SSH agent running with PID ${F_GREEN}${SSH_AGENT_PID}${CLR}"
  else
    log_warning "SSH agent with PID ${F_GREEN}${SSH_AGENT_PID}${CLR} was dead, removing .agent"
    rm ~/.agent
    unset SSH_AUTH_SOCK
    unset SSH_AGENT_PID
  fi
}

# If SSH_AUTH_SOCK is set already, then do nothing
if [[ ! -z ${SSH_AUTH_SOCK} && -z ${SSH_AGENT_PID} ]]; then
  log_info "Forwarded SSH agent detected"
else
  if [[ -f ~/.agent ]]; then
    # Source it
    source ~/.agent >/dev/null

    is_ssh_agent_alive

  else
    log_info "No SSH agent found"
  fi
fi
