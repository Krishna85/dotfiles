#!/bin/bash

# Do git-prompt stuff
if [[ ${GIT_PROMPT} == 1 ]]; then
  source ~/.bin/git-prompt.sh
  
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUNTRACKEDFILES=1
  GIT_PS1_SHOWSTASHSTATE=1
  GIT_PS1_SHOWUPSTREAM=verbose

  PS1_GIT=" \$(__git_ps1 \"${F_MIDGREY}(${F_TEAL}► ${F_SEA}%s${F_MIDGREY})\" | sed -e 's/*/${F_RED}▼/' -e 's/+/${F_GREEN}▲/g' -e 's/%/${F_YELLOW}●/g' -e 's/ u\S/${F_CYAN}&/g' -e 's/\\$/${F_GOLD}\\$/')"
fi

if [[ ! -z ${SSH_TTY} ]] || [[ ! -z ${DISPLAY} ]] || [[ ! -z ${TMUX_PANE} ]]; then
  # Set the prompt
  PROMPT_COMMAND="RC=\$? && T_PWD=\${PWD/\${HOME}/\~} && if [[ \${#T_PWD} -gt 35 ]]; then CUR_DIR=...\${T_PWD: -32}; else CUR_DIR=\${T_PWD}; fi"
  
  #PS1="${F_MIDGREY}[${FBLU}\D{%F %T}${F_MIDGREY}][${FYLW}pts/$(basename `tty`)${F_MIDGREY}][\$(if [[ \$RC -eq 0 ]]; then echo \"${FGRN}\$RC\"; else echo \"${FRED}\$RC\"; fi)${F_MIDGREY}][\033[38;5;208m\${AWS_ENVIRONMENT}\033[0m${F_MIDGREY}][${FCYN}\${CUR_DIR} \$(__git_ps1 \"${F_MIDGREY}(${F_TEAL}► ${F_SEA}%s${F_MIDGREY})\" | sed -e 's/*/${F_RED}▼/' -e 's/+/${F_GREEN}▲/g' -e 's/%/${F_YELLOW}●/g' -e 's/ u\S/${F_CYAN}&/g' -e 's/\\$/${F_GOLD}\\$/')${F_MIDGREY}]+\n${F_MIDGREY}[${F_TEAL}\u@\h${F_MIDGREY}]${FGRN}\$ ${CLR}"
  #PS1="${F_MIDGREY}[${FBLU}\D{%F %T}${F_MIDGREY}][${FYLW}pts/$(basename `tty`)${F_MIDGREY}][\$(if [[ \$RC -eq 0 ]]; then echo \"${FGRN}\$RC\"; else echo \"${FRED}\$RC\"; fi)${F_MIDGREY}][\033[38;5;208m\${AWS_ENVIRONMENT}\033[0m${F_MIDGREY}][${FCYN}\${CUR_DIR} $PS1_GIT${F_MIDGREY}]+\n${F_MIDGREY}[${F_TEAL}\u@\h${F_MIDGREY}]${FGRN}\$ ${CLR}"
  PS1="${F_MIDGREY}[${FBLU}\D{%F %T}${F_MIDGREY}][${FYLW}pts/$(basename `tty`)${F_MIDGREY}][\$(if [[ \$RC -eq 0 ]]; then echo \"${FGRN}\$RC\"; else echo \"${FRED}\$RC\"; fi)${F_MIDGREY}]"

  PS1="${PS1}\$(if [[ ! -z \$AWS_ENVIRONMENT ]]; then echo \"[\033[38;5;208m\${AWS_ENVIRONMENT}\033[0m${F_MIDGREY}]\"; fi)"

  PS1="${PS1}[${FCYN}\${CUR_DIR} $PS1_GIT${F_MIDGREY}]+\n${F_MIDGREY}[${F_TEAL}\u@\h${F_MIDGREY}]${FGRN}\$ ${CLR}"
  
  export PS1
fi
