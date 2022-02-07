#!/usr/bin/env bash

# --------------------------------------------------------------
# Copyright (C) 2021: Snyder Business And Technology Consulting, LLC. - All Rights Reserved
#
# Date:
# May 14, 2021
#
# Author:
# Alexander Snyder
#
# Email:
# alexander@sba.tc
#
# Repository:
# https://github.com/thisguyshouldworkforus/bash.git
#
# Dependency:
# Access to root
#
# Description:
# A small script to nuke log files older than 90 days.
# --------------------------------------------------------------

# Root/Sudo privelage is required
if [[ "$UID" -ne '0' ]]
    then
        echo -en "Only root may run this script, please elevate to root."
        exit 1
fi

# Generate a Unix timestamp of today
TODAY=$(date +"%s")
PRETTY_DATE=$(date +"%b %d, %Y")

# Initiate (or append) our Log File
if [[ ! -f '/var/log/delete_old_files.log' ]]
    then
        echo -en "\n\n============\n$PRETTY_DATE\n============\n" > '/var/log/delete_old_files.log'
    else
        echo -en "\n\n============\n$PRETTY_DATE\n============\n" >> '/var/log/delete_old_files.log'
fi

# Find Old Log Files
{
while IFS= read -r FILE
    do
        if [[ $((TODAY - $(stat -c %Y "$FILE") / 86400 )) -ge '90' ]]
            then
                echo "\"$FILE\" is greater than 90 days old (mtime: \"$(date +"%b %d, %Y" -d @"$(stat -c %Y "$FILE")")\")"
                if rm -f "$FILE"
                    then
                        echo -en "Deleted: \"$FILE\"\n\n"
                    else
                        echo -en "\n\nERROR: Could not delete \"$FILE\"\n\n"
                fi
            else
                echo -en "No files older than 90 days have been found, exiting ..."
        fi
    done < <(find /var/log -type f -mtime +90)
} >> '/var/log/delete_old_files.log'
