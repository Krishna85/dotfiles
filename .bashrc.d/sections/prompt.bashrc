#!/bin/bash

# Do git-prompt stuff
if [[ ${GIT_PROMPT} == 1 ]]; then
  source ~/.bin/git-prompt.sh
  
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUNTRACKEDFILES=1
  GIT_PS1_SHOWSTASHSTATE=1
  GIT_PS1_SHOWUPSTREAM=verbose

  PS1_GIT=" \$(__git_ps1 \"${PF_MIDGREY}(${PF_TEAL}► ${PF_SEA}%s${PF_MIDGREY})\" | sed -e 's/*/${PF_RED}▼/' -e 's/+/${PF_GREEN}▲/g' -e 's/%/${PF_YELLOW}●/g' -e 's/ u\S/${PF_CYAN}&/g' -e 's/\\$/${PF_GOLD}\\$/')"
fi

if [[ ! -z ${SSH_TTY} ]] || [[ ! -z ${DISPLAY} ]] || [[ ! -z ${TMUX_PANE} ]]; then
  # Set the prompt
  PROMPT_COMMAND="RC=\$? && T_PWD=\${PWD/\${HOME}/\~} && if [[ \${#T_PWD} -gt 35 ]]; then CUR_DIR=...\${T_PWD: -32}; else CUR_DIR=\${T_PWD}; fi"
  
  #PS1="${PF_MIDGREY}[${PFBLU}\D{%F %T}${PF_MIDGREY}][${PFYLW}pts/$(basename `tty`)${PF_MIDGREY}][\$(if [[ \$RC -eq 0 ]]; then echo \"${PFGRN}\$RC\"; else echo \"${PFRED}\$RC\"; fi)${PF_MIDGREY}][\033[38;5;208m\${AWS_ENVIRONMENT}\033[0m${PF_MIDGREY}][${PFCYN}\${CUR_DIR} \$(__git_ps1 \"${PF_MIDGREY}(${PF_TEAL}► ${PF_SEA}%s${PF_MIDGREY})\" | sed -e 's/*/${PF_RED}▼/' -e 's/+/${PF_GREEN}▲/g' -e 's/%/${PF_YELLOW}●/g' -e 's/ u\S/${PF_CYAN}&/g' -e 's/\\$/${PF_GOLD}\\$/')${PF_MIDGREY}]+\n${PF_MIDGREY}[${PF_TEAL}\u@\h${PF_MIDGREY}]${PFGRN}\$ ${PCLR}"
  #PS1="${PF_MIDGREY}[${PFBLU}\D{%F %T}${PF_MIDGREY}][${PFYLW}pts/$(basename `tty`)${PF_MIDGREY}][\$(if [[ \$RC -eq 0 ]]; then echo \"${PFGRN}\$RC\"; else echo \"${PFRED}\$RC\"; fi)${PF_MIDGREY}][\033[38;5;208m\${AWS_ENVIRONMENT}\033[0m${PF_MIDGREY}][${PFCYN}\${CUR_DIR} $PS1_GIT${PF_MIDGREY}]+\n${PF_MIDGREY}[${PF_TEAL}\u@\h${PF_MIDGREY}]${PFGRN}\$ ${PCLR}"
  PS1="${PF_MIDGREY}[${PFBLU}\D{%F %T}${PF_MIDGREY}][${PFYLW}pts/$(basename `tty`)${PF_MIDGREY}][\$(if [[ \$RC -eq 0 ]]; then echo \"${PFGRN}\$RC\"; else echo \"${PFRED}\$RC\"; fi)${PF_MIDGREY}]"

  PS1="${PS1}\$(if [[ ! -z \$AWS_ENVIRONMENT ]]; then echo \"[\033[38;5;208m\${AWS_ENVIRONMENT}\033[0m${PF_MIDGREY}]\"; fi)"

  PS1="${PS1}[${PFCYN}\${CUR_DIR} $PS1_GIT${PF_MIDGREY}]+\n${PF_MIDGREY}[\$(if [[ \$USER = "root" ]]; then echo \"${PF_RED}\"; else echo \"${PF_TEAL}\"; fi )\u@\h${PF_MIDGREY}]\$(if [[ \$USER = "root" ]]; then echo \"${PFRED}#\"; else echo \"${PFGRN}\$\"; fi) ${PCLR}"
  
  export PS1
fi
