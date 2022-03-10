#!/usr/bin/env bash
#.bash_profile

# Update the repository
cd /c/Users/alexa/GitHubCode/bash/profile || echo -en "\n\nCOULD NOT CHANGE TO THE REPO DIRECTORY\n\n"
if git pull >/dev/null 2>&1
    then
        UPDATES=$(git log .bashrc | awk 'NR==3{print $0}' | tr '[:lower:]' '[:upper:]')
        clear
        sleep 1
        echo -en "\n\n\n\t\tLast UP${UPDATES}\n\n\n"
        sleep 2
        # Get the aliases and functions
        if [[ -f /c/Users/alexa/GitHubCode/bash/profile/.bashrc ]]
            then
                if [[ -f /c/Users/alexa/.bashrc ]] && [[ ! -L /c/Users/alexa/.bashrc ]]
                    then
                        rm -f /c/Users/alexa/.bashrc
                        ln -s /c/Users/alexa/GitHubCode/bash/profile/.bashrc /c/Users/alexa/.bashrc
                fi
                if [[ ! -f /c/Users/alexa/.bashrc ]]  
                    then
                        ln -s /c/Users/alexa/GitHubCode/bash/profile/.bashrc /c/Users/alexa/.bashrc
                fi
        fi
        if [[ -f /c/Users/alexa/GitHubCode/bash/profile/.bash_logout ]]
            then
                if [[ -f /c/Users/alexa/.bash_logout ]] && [[ ! -L /c/Users/alexa/.bash_logout ]]
                    then
                        rm -f /c/Users/alexa/.bash_logout
                        ln -s /c/Users/alexa/GitHubCode/bash/profile/.bash_logout /c/Users/alexa/.bash_logout
                fi
                if [[ ! -f /c/Users/alexa/.bash_logout ]]  
                    then
                        ln -s /c/Users/alexa/GitHubCode/bash/profile/.bash_logout /c/Users/alexa/.bash_logout
                fi
        fi
        if [[ -f /c/Users/alexa/GitHubCode/bash/profile/.vimrc ]]
            then
                if [[ -f /c/Users/alexa/.vimrc ]] && [[ ! -L /c/Users/alexa/.vimrc ]]
                    then
                        rm -f /c/Users/alexa/.vimrc
                        ln -s /c/Users/alexa/GitHubCode/bash/profile/.vimrc /c/Users/alexa/.vimrc
                fi
                if [[ ! -f /c/Users/alexa/.vimrc ]]  
                    then
                        ln -s /c/Users/alexa/GitHubCode/bash/profile/.vimrc /c/Users/alexa/.vimrc
                fi
        fi
        cd /c/Users/alexa || echo -en "\n\nCOULD NOT CHANGE TO HOME DIRECTORY\n\n"
        # shellcheck disable=SC1091
        source /c/Users/alexa/.bashrc
    else
        echo -en "\n\nCOULD NOT UPDATE THE REPOSITORY\n\n"
fi
