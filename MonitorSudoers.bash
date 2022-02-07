#!/usr/bin/env bash

# --------------------------------------------------------------
# Date:
# January 16, 2020
# --------------------------------------------------------------

# Check to see if the checksum file exists
if [[ ! -f /root/sudoers.md5 ]]
    then
        # Generate a checksum
        SUDOERS=$($(command -v md5sum) '/etc/sudoers' 2>/dev/null | awk '{print $1}')
        if [[ -n "$SUDOERS" ]]
            then
                # If the checksum variable isn't empty, then put that value in a file
                echo "$SUDOERS" > /root/sudoers.md5
        fi
    else
        # Generate a checksum
        CHECK=$($(command -v md5sum) '/etc/sudoers' 2>/dev/null | awk '{print $1}')

        # Compare our checksum to our known good checksum file
        if [[ ! $($(command -v cat) /root/sudoers.md5) == "$CHECK" ]]
            then
                # They don't match, send an alert to '/var/log/messages'
                $(command -v logger) "SUDOERS CHANGE --- CHECKSUM HAS FAILED!!!"

                # Remove our known good checksum, so it can be repopulated.
                rm -f /root/sudoers.md5
        fi
fi

# Create a loop to go through all the files in '/etc/sudoers.d/'
while IFS= read -r FILE
    do
        # Shorten the filename
        SHORT=$(echo "$FILE" | awk -F/ '{print $NF}' | tr '[:upper:]' '[:lower:]')

        # Check to see if the checksum file exists
        if [[ ! -f /root/sudoers_"$SHORT".md5 ]]
            then
                # Generate a checksum
                SUM=$($(command -v md5sum) "$FILE" 2>/dev/null | awk '{print $1}')
                if [[ -n "$SUM" ]]
                    then
                        # If the checksum variable isn't empty, then put that value in a file
                        echo "$SUM" > /root/sudoers_"$SHORT".md5
                fi
            else
                # Generate a checksum
                CHECK=$($(command -v md5sum) "$FILE" 2>/dev/null | awk '{print $1}')

                # Compare our checksum to our known good checksum file
                if [[ ! $($(command -v cat) /root/sudoers_"$SHORT".md5) == "$CHECK" ]]
                    then
                        # They don't match, send an alert to '/var/log/messages'
                        $(command -v logger) "SUDOERS ($FILE) CHANGE --- CHECKSUM HAS FAILED!!!"

                        # Remove our known good checksum, so it can be repopulated.
                        rm -f /root/sudoers_"$SHORT".md5
                fi
        fi
    done < <(find /etc/sudoers.d -type f)