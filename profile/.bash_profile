#!/usr/bin/env bash
#.bash_profile

# Export GIT Settings
export GIT_SSH_COMMAND="ssh -o 'CheckHostIP=no' -o 'StrictHostKeyChecking=no' -o 'ConnectTimeout=5' -i ~/.ssh/sbatc.priv"

# Update the repository
cd /c/Users/alexa/GitHubCode/bash/profile || echo -en "\n\nCOULD NOT CHANGE TO THE REPO DIRECTORY\n\n"
if git pull >/dev/null 2>&1
    then
        UPDATES=$(git log .bashrc | awk 'NR==3{print $0}' | tr '[:lower:]' '[:upper:]')
        clear
        echo -en "\n\n\n\t\tLast UP${UPDATES}\n\n\n"
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
        if [[ -f /c/Users/alexa/GitHubCode/bash/profile/.bash_profile ]]
            then
                if [[ -f /c/Users/alexa/.bash_profile ]] && [[ ! -L /c/Users/alexa/.bash_profile ]]
                    then
                        rm -f /c/Users/alexa/.bash_profile
                        ln -s /c/Users/alexa/GitHubCode/bash/profile/.bash_profile /c/Users/alexa/.bash_profile
                fi
                if [[ ! -f /c/Users/alexa/.bash_profile ]]
                    then
                        ln -s /c/Users/alexa/GitHubCode/bash/profile/.bash_profile /c/Users/alexa/.bash_profile
                fi
        fi
        cd /c/Users/alexa || echo -en "\n\nCOULD NOT CHANGE TO HOME DIRECTORY\n\n"
        # shellcheck disable=SC1091
        source /c/Users/alexa/.bashrc

        # Make sure some services are running
        for SERVICE in 'cron' 'network-manager' 'rsyslog'; do sudo service "$SERVICE" start > /dev/null 2>&1; done;
    else
        echo -en "\n\nCOULD NOT UPDATE THE REPOSITORY\n\n"
fi
