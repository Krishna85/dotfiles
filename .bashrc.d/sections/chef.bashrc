#!/bin/bash

source ~/.bashrc.d/sections/colours.bashrc

CHEF_DEFAULT_ENV="prod"
export CHEF_REPO=~/chef/chef-repo
export CHEF_COOKBOOKS=~/chef/cookbooks

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
        #echo -e "\033[48;5;033;37;1mChef\033[0m environment set to \033[38;5;028m${CHEF_ENV_NAME}\033[0m."
        echo -e "${F_LIGHTBLUE}Chef${CLR} environment set to ${F_YELLOW}${CHEF_ENV_NAME}${CLR}."
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

chef_get_environment_from_server() {
  ENVIRONMENT=$1

  knife environment show ${ENVIRONMENT} -F json
}

chef_get_environment_from_repo() {
  ENVIRONMENT=$1

  cat ${CHEF_REPO}/environments/${ENVIRONMENT}.json
}

chef_get_cookbook_version() {
  COOKBOOK=$1
  METADATA_FILE="${CHEF_COOKBOOKS}/${COOKBOOK}/metadata.rb"

  if [[ ! -f ${METADATA_FILE} ]]; then
    return 1
  fi

  VERSION=$(cat ${METADATA_FILE} | grep ^version | awk '{ print $2 }' | cut -f2 -d"'")

  echo ${VERSION}
}

chef_get_cookbook_version_from_server() {
  ENVIRONMENT=$1
  COOKBOOK=$2

  ENVIRONMENT_DATA="$(chef_get_environment_from_server ${ENVIRONMENT})"
  echo ${ENVIRONMENT_DATA} | jq -r '.cookbook_versions["'${COOKBOOK}'"]' | awk '{ print $2 }'
}

chef_get_cookbook_version_from_repo() {
  ENVIRONMENT=$1
  COOKBOOK=$2

  ENVIRONMENT_DATA="$(chef_get_environment_from_server ${ENVIRONMENT})"
  echo ${ENVIRONMENT_DATA} | jq -r '.cookbook_versions["'${COOKBOOK}'"]' | awk '{ print $2 }'
}

chef_sync_environment_to_repo() {
  ENVIRONMENT=$1

  knife environment show ${ENVIRONMENT} -F json >${CHEF_REPO}/environments/${ENVIRONMENT}.json
}

chef_sync_environment_to_server() {
  ENVIRONMENT=$1

  knife environment from file ${CHEF_REPO}/environments/${ENVIRONMENT}.json
}

chef_set_cookbook_version() {
  ENVIRONMENT=$1
  COOKBOOK=$2
  VERSION=$3

  ENVIRONMENT_DATA="$(chef_get_environment_from_server ${ENVIRONMENT})"
  UPDATED_DATA="$(echo ${ENVIRONMENT_DATA} | jq -r '.cookbook_versions["'${COOKBOOK}'"] = "= '${VERSION}'"')"

  echo ${UPDATED_DATA}
}

chef_get_current_cookbook() {
  GIT_ROOT="$(git rev-parse --show-toplevel)"
  COOKBOOK_DIR="$(basename ${GIT_ROOT})"

  echo ${COOKBOOK_DIR}
}

chef_show_current_cookbook() {
  GIT_ROOT="$(git rev-parse --show-toplevel)"
  COOKBOOK_DIR="$(basename ${GIT_ROOT})"
  METADATA_FILE="${GIT_ROOT}/metadata.rb"

  if [[ ! -f ${METADATA_FILE} ]]; then
    echo "This is not a Chef cookbook repo"
    return 1
  fi

  cat ${METADATA_FILE}
}

CHEF_REPO_GIT="git --git-dir ${CHEF_REPO}/.git --work-tree ${CHEF_REPO}"

chef_show_cookbook_status() {
  COOKBOOK=$1
  if [[ -z ${COOKBOOK} ]]; then
    echo "No cookbook specified"
    return 1
  fi

  # Ensure cookbook exists
  if [[ ! -d ${CHEF_COOKBOOKS}/${COOKBOOK} ]]; then
    echo "Couldn't find cookbook ${COOKBOOK}"
    return 1
  fi

  VERSION=$(cat ${CHEF_COOKBOOKS}/${COOKBOOK}/metadata.rb | grep ^version | awk '{ print $2 }' | cut -f2 -d"'")
  echo -e "${F_CYAN}${COOKBOOK}${CLR} has version ${F_YELLOW}${VERSION}${CLR}"

  for ENVIRONMENT in ${PROD_ENVIRONMENTS}; do
    echo -e "\n${F_YELLOW}${ENVIRONMENT}${CLR}"
    echo -ne "${F_GREEN}Server${CLR}: "
    VER=$(chef_get_cookbook_version_from_server ${ENVIRONMENT} ${COOKBOOK})
    if [[ -z ${VER} ]]; then
      echo "Not found"
    else
      echo ${VER}
    fi
    echo -ne "${F_RED}Local ${CLR}: "
    VER=$(chef_get_cookbook_version_from_repo ${ENVIRONMENT} ${COOKBOOK})
    if [[ -z ${VER} ]]; then
      echo "Not found"
    else
      echo ${VER}
    fi
  done
}

c() {
  CMD=$1

  if [[ -f ~/.chef/prod_envs ]]; then
    PROD_ENVIRONMENTS="$(cat ~/.chef/prod_envs)"
  fi

  if [[ ${CMD} = "env" ]]; then
    ls ${CHEF_REPO}/environments
  elif [[ ${CMD} = "dumpenv" ]]; then
    ENVIRONMENT=$2

    if [[ -z ${ENVIRONMENT} ]]; then
      echo "No environment specified"
      return 1
    fi

    knife environment show ${ENVIRONMENT} -F json
  elif [[ ${CMD} = "bump" ]]; then
    COOKBOOK=$2

    if [[ -z ${COOKBOOK} ]]; then
      COOKBOOK=$(chef_get_current_cookbook)

      if [[ -z ${COOKBOOK} ]]; then
        echo "Couldn't get current cookbook."
        return 1
      fi
    fi

    NEW_VERSION=$(chef_get_cookbook_version ${COOKBOOK})
    echo "New version is ${NEW_VERSION}"

    for ENVIRONMENT in ${PROD_ENVIRONMENTS}; do
      CURRENT_VER_SERVER="$(chef_get_cookbook_version_from_server ${ENVIRONMENT} ${COOKBOOK})"
      CURRENT_VER_REPO="$(chef_get_cookbook_version_from_repo ${ENVIRONMENT} ${COOKBOOK})"

      if [[ -z ${CURRENT_VER_SERVER} ]]; then
        echo "Cookbook ${COOKBOOK} not found in ${ENVIRONMENT}, skipping."
      else
        chef_set_cookbook_version ${ENVIRONMENT} ${COOKBOOK} ${NEW_VERSION} >${CHEF_REPO}/environments/${ENVIRONMENT}.json
        chef_sync_environment_to_server ${ENVIRONMENT}
        chef_sync_environment_to_repo ${ENVIRONMENT}
        ${CHEF_REPO_GIT} add ${CHEF_REPO}/environments/${ENVIRONMENT}.json
        ${CHEF_REPO_GIT} commit -m "Changed ${COOKBOOK} to v${NEW_VERSION} for ${ENVIRONMENT}"
      fi
    done

    ${CHEF_REPO_GIT} push
  elif [[ ${CMD} = "ver" ]]; then
    COOKBOOK=$2

    if [[ -z ${COOKBOOK} ]]; then
      COOKBOOK=$(chef_get_current_cookbook)
    fi

    chef_show_cookbook_status ${COOKBOOK}
  elif [[ ${CMD} = "repo" ]]; then
    cd ${CHEF_REPO}
  elif [[ ${CMD} = "root" ]]; then
    cd $(git rev-parse --show-toplevel)
  elif [[ ${CMD} = "up" ]]; then
    knife cookbook upload $(chef_get_current_cookbook)
  fi
}
