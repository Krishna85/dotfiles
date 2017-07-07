#!/bin/bash

CHEF_DEFAULT_ENV="prod"
chef() {
  CHEF_ENV_NAME=$1
  if [[ -z ${CHEF_ENV_NAME} ]]; then
    echo -e "Current environment is \033[38;5;028m${CHEF_ENV}\033[0m."
    return 0
  else
    if [[ ! -f ~/.chef.environments ]]; then
      echo "No ~/.chef.environments file found."
      return 1
    fi
    if [[ ${CHEF_ENV_NAME} == "-l" ]]; then
      echo "Available Chef environments:-"
      for CHEF_ENV_AVAIL in $(grep -v "^#" ~/.chef.environments | cut -f1 -d","); do
        echo " * ${CHEF_ENV_AVAIL}"
      done
      return 0
    else
      CHEF_ENV_VALUES=$(grep "^${CHEF_ENV_NAME}," ~/.chef.environments)
      if [[ -z ${CHEF_ENV_VALUES} ]]; then
        echo "No Chef environment named '${CHEF_ENV_NAME}' found."
        echo "Available Chef environments:-"
        for CHEF_ENV_AVAIL in $(grep -v "^#" ~/.chef.environments | cut -f1 -d","); do
          echo " * ${CHEF_ENV_AVAIL}"
        done
        return 1
      else
        KNIFE_CHEF_SERVER=$(echo ${CHEF_ENV_VALUES} | cut -f2 -d",")
        KNIFE_NODE_NAME=$(echo ${CHEF_ENV_VALUES} | cut -f3 -d",")
        KNIFE_CLIENT_KEY=$(echo ${CHEF_ENV_VALUES} | cut -f4 -d",")
        KNIFE_VALIDATION_CLIENT_NAME=$(echo ${CHEF_ENV_VALUES} | cut -f5 -d",")
        KNIFE_VALIDATION_CLIENT_KEY=$(echo ${CHEF_ENV_VALUES} | cut -f6 -d",")
        echo -e "\033[48;5;033;37;1mChef\033[0m environment set to \033[38;5;028m${CHEF_ENV_NAME}\033[0m."
        CHEF_ENV=${CHEF_ENV_NAME}
        export KNIFE_CHEF_SERVER KNIFE_NODE_NAME KNIFE_CLIENT_KEY KNIFE_VALIDATION_CLIENT_NAME KNIFE_VALIDATION_CLIENT_KEY
      fi
    fi
  fi
}

if [[ ! -z ${SSH_TTY} && -f ~/.chef.environments ]]; then
  if [[ -z ${CHEF_ENV} ]]; then
    chef ${CHEF_DEFAULT_ENV}
  else
    chef ${CHEF_ENV}
  fi
fi
