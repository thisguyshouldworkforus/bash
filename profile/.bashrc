#!/bin/bash

# shellcheck disable=SC1091,SC2230,SC2139

if [ -f /etc/bashrc ]
    then
        source /etc/bashrc
fi

function GetIP(){
    ip a | grep eth0 -A3 | grep inet | awk 'NR==1{print $2}' | sed -r 's/\/[0-9]{2}//g' | tr -d '[:space:]'
}

function DiskAlert(){
    LOOP=0
    while IFS= read -r LINE
        do
            if [[ "$LINE" =~ ^Filesystem ]]
                then
                    continue
            fi
            FILESYSTEM=$(echo "$LINE" | awk -F ',' '{print $1}')
            SIZE=$(echo "$LINE" | awk -F ',' '{print $2}')
            USED=$(echo "$LINE" | awk -F ',' '{print $3}')
            AVAIL=$(echo "$LINE" | awk -F ',' '{print $4}')
            USAGE=$(echo "$LINE" | awk -F ',' '{print $5}' | tr -d '%')
            MOUNT=$(echo "$LINE" | awk -F ',' '{print $6}')
            if [[ "$USAGE" -ge '90' ]]
                then
                    if [[ "$LOOP" -eq '0' ]]
                        then
                            echo -en "\n\nDISK ALERTS:"
                            ((LOOP++))
                    fi
                    echo -en "\n\t${FILESYSTEM} ${SIZE} ${USED} ${AVAIL} ${USAGE}% ${MOUNT}"
            fi
        done < <(df -hP /c /d /e | sed -r 's/\ |\t/,/g' | sed -r 's/\,{2,}/\,/g')
}

# Determine the hostname
THISBOX=$(hostname -f | awk -F '.' '{print $1}')

# User specific functions

# User specific variables
# Shell Colors
# shellcheck disable=SC2034  # Unused variables left for readability
{
NORMAL_TEXT="\e[39m"
BLACK_TEXT="\e[30m"
RED_TEXT="\e[31m"
GREEN_TEXT="\e[32m"
YELLOW_TEXT="\e[33m"
BLUE_TEXT="\e[34m"
MAGENTA_TEXT="\e[35m"
CYAN_TEXT="\e[36m"
LIGHT_GRAY_TEXT="\e[37m"
DARK_GRAY_TEXT="\e[90m"
LIGHT_RED_TEXT="\e[91m"
LIGHT_GREEN_TEXT="\e[92m"
LIGHT_YELLOW_TEXT="\e[93m"
LIGHT_BLUE_TEXT="\e[94m"
LIGHT_MAGENTA_TEXT="\e[95m"
LIGHT_CYAN_TEXT="\e[96m"
WHITE_TEXT="\e[97m"
NORMAL_BACKGROUND="\e[49m"
BLACK_BACKGROUND="\e[40m"
RED_BACKGROUND="\e[41m"
GREEN_BACKGROUND="\e[42m"
YELLOW_BACKGROUND="\e[43m"
BLUE_BACKGROUND="\e[44m"
MAGENTA_BACKGROUND="\e[45m"
CYAN_BACKGROUND="\e[46m"
LIGHT_GRAY_BACKGROUND="\e[47m"
DARK_GRAY_BACKGROUND="\e[100m"
LIGHT_RED_BACKGROUND="\e[101m"
LIGHT_GREEN_BACKGROUND="\e[102m"
LIGHT_YELLOW_BACKGROUND="\e[103m"
LIGHT_BLUE_BACKGROUND="\e[104m"
LIGHT_MAGENTA_BACKGROUND="\e[105m"
LIGHT_CYAN_BACKGROUND="\e[106m"
WHITE_BACKGROUND="\e[107m"
}

# User specific logic
if [[ "$THISBOX" =~ 'awesomesauce' ]]
    then
        export GIT_SSH_COMMAND="ssh -o 'CheckHostIP=no' -o 'StrictHostKeyChecking=no' -o 'ConnectTimeout=5' -i ~/.ssh/sbatc.priv"
	    export PS1="\n[ ${WHITE_BACKGROUND}${RED_TEXT}WINDOWS SUBSHELL LINUX (WSL) ${BLUE_TEXT}($(grep 'PRETTY_NAME' /etc/os-release | awk -F '=' '{print $2}' | tr -d '"'))${NORMAL_TEXT}${NORMAL_BACKGROUND} ]\n[ USER: \u ]\n[ HOST: $THISBOX ($(GetIP)) ]\n[ You're in (( \w )) ]\n$(DiskAlert)\n\n--> "
fi

# User specific aliases

alias ll="ls -alh"


if which python3 >/dev/null 2>&1
    then
        PYTHON3=$(which python3)
        alias python="$PYTHON3"
        alias pip="$PYTHON3 -m pip"
fi
##
