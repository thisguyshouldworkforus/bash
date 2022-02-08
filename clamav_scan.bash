#!/bin/bash

# --------------------------------------------------------------
# Date:
# November 10, 2020
# --------------------------------------------------------------

# Script Variables
CLAMSCAN="/usr/bin/ionice -c '3' nice -n '19' /usr/bin/clamscan -ri"
FRESHCLAM="/usr/bin/ionice -c '3' nice -n '19' /usr/bin/freshclam -v"
LOGFILE="/var/log/clamav/clam.log"
NOW=$(date --date="$(date +"%Y-%m-%d")" +"%s" 2>/dev/null)
INTERVAL="86400" #Unix-Timestamp//86400//1-day

# Declare the argument array
declare -a CLAMARG

# Script Logic
if [[ ! -f "${LOGFILE}" ]]
    then
        echo -en "Scan Started\n$(date)\n============\n" > "${LOGFILE}"
        if [[ "$#" -gt '0' ]]
            then
                for ARG in "$@"
                    do
                        CLAMARG+=("$ARG")
                    done
                "$FRESHCLAM"
                "$CLAMSCAN" "${CLAMARG[@]}" >> "${LOGFILE}"
            else
                "$FRESHCLAM"
                "$CLAMSCAN /usr/bin /bin" >> "${LOGFILE}"
        fi
        echo -en "\nScan Ended\n$(date)\n============\n\n" >> "${LOGFILE}"
    else
        LOGDATE=$(date --date="$(date -r ${LOGFILE} +"%Y-%m-%d")" +"%s" 2>/dev/null)
        DELTA=$((NOW-LOGDATE))
        if [[ "$DELTA" -ge "$INTERVAL" ]]
            then
                echo -en "Scan Started\n$(date)\n============\n" >> "${LOGFILE}"
                if [[ "$#" -gt '0' ]]
                    then
                        for ARG in "$@"
                            do
                                CLAMARG+=("$ARG")
                            done
                        "$FRESHCLAM"
                        "$CLAMSCAN" "${CLAMARG[@]}" >> "${LOGFILE}"
                    else
                        "$FRESHCLAM"
                        "$CLAMSCAN /usr/bin /bin" >> "${LOGFILE}"
                fi
                echo -en "\nScan Ended\n$(date)\n============\n\n" >> "${LOGFILE}"
        fi
fi