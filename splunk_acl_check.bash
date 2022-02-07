#!/usr/bin/env bash

# ShellCheck is complaining about the usage of 'which'
# shellcheck disable=SC2230

# --------------------------------------------------------------
# Date:
# March 10, 2020
# --------------------------------------------------------------

function EnableACLs(){
# Make sure the test file has a random name. Append it with a Unix Time-Stamp
TESTFILE=${1}/facltest."$(date +"%s")"

# Determine the Operating System version
OS=$(uname -r | grep -Eio 'el6|el7|el8')

# Testing for ACL Support
touch "$TESTFILE"
if ! setfacl -m u:splunk:r "${TESTFILE}" >/dev/null 2>&1
    then
        rm -f "$TESTFILE"
        $(which logger) "SPLUNK_ACL --- ACLs are not supported on $(hostname), adjusting..."
        cp /etc/fstab /etc/fstab."$(date +"%m-%d-%Y_%H.%M.%S")"
        if [[ "$FILEPARTITION" =~ ^/dev/sd.*$ ]] && [[ "$OS" == "el6" ]]
            then
                if grep -Ei '^LABEL=.*' /etc/fstab
                    then
                        GETDISK=$(echo "$FILEPARTITION" | awk -F '/' '{print $(NF)}')
                        GETLABEL=$(grep "$GETDISK" < <(ls -alh /dev/disk/by-label/) | awk '{print "LABEL="$9}')
                        sed -ri "s/^($GETLABEL)(.*)(defaults)(.*)/\1\2acl\4/g" /etc/fstab
                        mount -t ext4 -o remount,acl "$FILEPARTITION" "$FILEMOUNT"
                    else
                        sed -ri "s/^($SEDPARTITION)(.*)(defaults)(.*)/\1\2acl\4/g" /etc/fstab
                        mount -t ext4 -o remount,acl "$FILEPARTITION" "$FILEMOUNT"
                fi     
        elif [[ "$FILEPARTITION" =~ ^/dev/mapper.*$ ]]
            then
                sed -ri "s/^($SEDPARTITION)(.*)(defaults)(.*)/\1\2acl\4/g" /etc/fstab
                mount -t ext4 -o remount,acl "$FILEPARTITION" "$FILEMOUNT"
        fi
fi

}
function TestACL(){
    # Can splunk read this file?
    if sudo -u splunk test -r "$1"
        then
            return 0
        else
            return 1
    fi
}

# Make sure the log we're using as our source of truth actually exists
if [[ ! -f '/opt/splunkforwarder/var/log/splunk/splunkd.log' ]]
    then
        # General error, exit
        $(which logger) "SPLUNK_ACL --- Unable to generate file list, exiting for safety"
        exit 1
fi

# Generate a list of files that splunk cannot read
while IFS= read -r FILE_ERROR
    do
        unset FILEPARTITION SEDPARTITION FILEMOUNT FILEPATH
        # Check to make sure the line we're operating on matches an expected pattern
        if [[ "$FILE_ERROR" =~ (Insufficient permissions to read file=\')(.*)(\') ]]
            then
                # Since the line matches our expected pattern (regex) pull out the field we want
                ACL_FILE="${BASH_REMATCH[2]}"
                # Make sure the file we're referencing actually exists
                if [[ -f "$ACL_FILE" ]]
                    then
                        if [[ ! "$ACL_FILE" =~ ^/opt/splunkforwarder/.*$ ]]
                            then
                                # This is a path that is not owned by Splunk, but splunk still needs to read
                                if ! TestACL "$ACL_FILE"
                                    then
                                        # Splunk cannot read this file, ACLs are not set, lets fix that!
                                        FILEPARTITION=$(df -Ph "$ACL_FILE" | awk 'NR==2{print $1}')
                                        if [[ -z "$FILEPARTITION" ]]
                                            then
                                                $(which logger) "SPLUNK_ACL --- Failed to find FILEPARTITION for \"$ACL_FILE\""
                                                exit 1
                                        fi
                                        SEDPARTITION=$(df -Ph "$ACL_FILE" | awk 'NR==2{print $1}' | sed 's/\//\\\//g')
                                        if [[ -z "$SEDPARTITION" ]]
                                            then
                                                $(which logger) "SPLUNK_ACL --- Failed to find SEDPARTITION for \"$ACL_FILE\""
                                                exit 1
                                        fi
                                        FILEMOUNT=$(df -Ph "$ACL_FILE" | awk NR==2'{print $6}')
                                        if [[ -z "$FILEMOUNT" ]]
                                            then
                                                $(which logger) "SPLUNK_ACL --- Failed to find FILEMOUNT for \"$ACL_FILE\""
                                                exit 1
                                        fi
                                        FILEPATH=$(dirname "$ACL_FILE")
                                        if [[ -z "$FILEPATH" ]]
                                            then
                                                $(which logger) "SPLUNK_ACL --- Failed to find FILEPATH for \"$ACL_FILE\""
                                                exit 1
                                        fi
                                        if ! EnableACLs "$FILEMOUNT"
                                            then
                                                $(which logger) "SPLUNK_ACL --- Failed to enable ACLs for filesystem \"$FILEMOUNT\"."
                                            else
                                                setfacl -m m:r "$ACL_FILE"
			                                    setfacl -m u:splunk:r "$ACL_FILE"
			                                    # Because this may still be blocked due to directory permissions, we need to check again
			                                    # and fix directory structure until ACLs allow for Splunk to browse and see file
                                                if ! TestACL "$ACL_FILE"
                                                    then
                                                        setfacl -m m::rx "$FILEPATH"
				                                        setfacl -m u:splunk:rx "$FILEPATH"
				                                        if ! TestACL "$ACL_FILE"
                                                            then
				                                        	    $(which logger) "SPLUNK_ACL --- Failed to set permissible ACLs on \"$ACL_FILE\""
                                                            else
                                                                $(which logger) "SPLUNK_ACL --- After updating ACLs on \"$FILEPATH\", splunk was able to read \"$ACL_FILE\""
                                                        fi
                                                    else
                                                        $(which logger) "SPLUNK_ACL --- Set permissible ACLs on \"$ACL_FILE\" successfully"
                                                fi
                                                $(which logger) "SPLUNK_ACL --- Set permissible ACLs on \"$ACL_FILE\" successfully"
                                        fi
                                    else
                                        $(which logger) "SPLUNK_ACL --- ACL is already set on \"$ACL_FILE\", no action required."
                                fi
                            else
                                # The line matches an '/opt/splunkforwarder' pattern, meaning this is already a splunk file, that splunk should rightfully own.
                                chown splunk:splunk "$ACL_FILE"
                                $(which logger) "SPLUNK_ACL --- Set \"$ACL_FILE\" ownership to splunk:splunk"
                                chmod 755 "$ACL_FILE"
                                $(which logger) "SPLUNK_ACL --- Set \"$ACL_FILE\" permissions to 755"
                        fi
                    else
                        # General error, exit
                        $(which logger) "SPLUNK_ACL --- Unexpected result in file list, exiting for safety"
                        exit 1
                fi
            else
                # The file we're referencing does not exist
                # Continue on to the next file in our loop
                continue
        fi
    done < <(grep -Eo "Insufficient permissions to read file='.*'" /opt/splunkforwarder/var/log/splunk/splunkd.log | sort -u)