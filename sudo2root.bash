#!/usr/bin/env bash

#shellcheck disable=SC2091,SC2230

# --------------------------------------------------------------
# Date:
# June 23, 2020
# --------------------------------------------------------------

DATE=$(date +"%m-%d-%Y %T %Z")
HOST=$(hostname)

while IFS= read -r FILE
    do
        while IFS= read -r USERS
            do
                MEMBERS=$(/opt/adauth/bin/adint list user "$USERS" | awk -F ':' '{print $1}' | tr -d 'EWS\\')
                if [[ -n "$MEMBERS" ]]
                    then
                        $(sudo which logger) "SUDO2ROOT --- DATE=\"$DATE\" HOST=\"$HOST\" FILE=\"$FILE\" USERS=\"$MEMBERS\""
                fi
            done < <(grep -Ei '.*ALL=\(ALL\).*NOPASSWD: ALL' "$FILE" | grep -Eiv '#|wheel' | grep -Ev '^%' | awk '{print $1}')
    done < <(find /etc/sudoers.d/ /etc/sudoers -type f -print)

while IFS= read -r FILE
    do
        while IFS= read -r USERGROUP
            do
                MEMBERS=$(/opt/adauth/bin/adint list group "$USERGROUP" | awk -F ':' '{print $4}' | tr ',' '\n' | sort -u | tr '\n' ',' | sed 's/,$//g')
                if [[ -n "$MEMBERS" ]]
                    then
                        $(sudo which logger) "SUDO2ROOT --- DATE=\"$DATE\" HOST=\"$HOST\" FILE=\"$FILE\" GROUP=\"$USERGROUP\" MEMBERS=\"$MEMBERS\""
                fi
            done < <(grep -Ei '.*ALL=\(ALL\).*NOPASSWD: ALL' "$FILE" | grep -Eiv '#|wheel' | sed 's/%//' | awk '{print $1}')
    done < <(find /etc/sudoers.d/ /etc/sudoers -type f -print)
