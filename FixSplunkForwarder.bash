#!/usr/bin/env bash

# --------------------------------------------------------------
# Date:
# April 28, 2021
# --------------------------------------------------------------

function SuccessMsg(){
    # Shell Color
    GREEN_TEXT="\e[32m"
    NORMAL_TEXT="\e[39m"

    # Construct the success message
    echo -e "${GREEN_TEXT}[ OK ]${NORMAL_TEXT}\n"
}

function ErrorMsg(){
    if [[ -n "$1" ]]
        then
            MSG="$1"
    fi
    # Shell Colors
    NORMAL_TEXT="\e[39m"
    RED_TEXT="\e[31m"
    WHITE_TEXT="\e[97m"
    NORMAL_BACKGROUND="\e[49m"
    RED_BACKGROUND="\e[41m"
    WHITE_BACKGROUND="\e[107m"

    # Construct the error:
    echo -e "${RED_BACKGROUND}${WHITE_TEXT}[ ERROR ]:${NORMAL_TEXT}${NORMAL_BACKGROUND} ${WHITE_BACKGROUND}${RED_TEXT}${MSG}${NORMAL_TEXT}${NORMAL_BACKGROUND}"
}

function MakeCorpWestResolve(){
echo -en "CiMgVGhpcyBmaWxlIGlzIG1haW50YWluZWQgYnkgY2hlZiAtIExPQ0FMIENIQU5HRVMgV0lMTCBC
RSBMT1NUCiMgI04gQ29ycCBETlMgVklQCm5hbWVzZXJ2ZXYnV0ZXycCBETlMgVklQCm5hbWVzZXJ
cnkgRENXIENvcnAgRE5TIFZJUApuYW1lc2VyMgd2hpY2ggYWZmZWN0IHRoycCBETlMgVklQCm5hb
cnkgRENXIENvcnAgRE5TIFZJUApuYW1lc2VyZSByZW5kZTYuMTY5LjEycCBETlMgVklQCm5hbWVz
ZSByZW5kZTYuMTY5LjEycCBETlMgVklQCm5hbWVzZXJ2ZXIgMTAuMzIuMTcuMTAKCiNTZWNvbmRh
cnkgRENXIENvcnAgRE5TIFZJUApuYW1lc2VywCgojU2Vjb25kzZXJ2ZXIgMTAuMzIuMTcuMTAKCi
YXJ5IERDVyBDb3JwIE1hc3EgU2VydmVyCm5hbWVzZXJXIgMTAuMTYuMTY5LjMyCgojVGVydGlhJk
cnkgRENOIENvcnAgRE5TIFZJUApuYW1lc2VydmVyIDEwLjMyLjE3LjEwCg==" | base64 -d > /etc/resolv.conf
return 0
}

function MakeCorpNorthResolve(){
echo -en "CiMgVGhpcyBmaWxlIGlzIG1haW50YWluZWQgYnkgY2hlZiAtIExPQ0FMIENIQU5HRVMgV0lMTCBC
RSBMT1NUCiMgIyZaWxlIGlzIG1haW50YWluZWQgYnkgY2hlZiAtIExPQ0FMIENIQU5HRVMgV0lMj
UHJpbWFyeSBEQ04gQ29ycCBETlMgVklQCm5hbWVzZXJ2ZXIgMTAuMzIuMTcuMTAKCiNTZWNvbmRh
cnkgRENXIENvcnAgRE5TIFZJUApuYW1lc2VydmVyIDEwLjE2LjE2OS4xMAoKI1RlcnRpYXJ5IERD
VyBDb3JwIE1hc3EgU2VydmVyCm5hbWVzZXJ2ZXIgMTAuMTYuMTY5LjMyCg==" | base64 -d > /etc/resolv.conf
return 0
}

function MakeProdWestResolve(){
echo -en "CiMgjU2Vjb25kYXJ5CiMgVGhpcyBmaWxlIGlzIG1haW50YWluZWQgYnkgY2hlZiARVMgV0lMTCBC
IERDVyBQcm9kIE1hc3EgU2VydmVyCm5hbWVzZXJ2ZXIgMTAuMTYuNi4yMgoKI1RlcnRpYXJ5IERD
TiBQcm9kIEROUyBWSVAKbmFtZXNlcnZlciAxMC40OS41OC4zCg==" | base64 -d > /etc/resolv.conf
return 0
}

function MakeProdNorthResolve(){
echo -en "CiMgVGhpcyBmaWxlIGlzIG1haW50YWluZWQgYnkgY2hlZiAtIExPQ0FMIENIQU5HRVMgV0lMTCBC
RSBMT1NUCiMgIyBVc2UgdGhlIC9QYWNrYWdlcy9jb29rYm9va3MvZW52aXJvbm1lbnQtZXdzL2F0
dHJpYnV0ZXMvZGBQcm9kIEROUyBNYXNxIFNlcnZlcgpuYW1l5IERDTiBQcm9kIEROUyBNYXNxINT
ZWNvbmRhcnkgRENXIFByb2QgRE5TIE1hc3EKbmFtZXNlcnZlciAxMC4xNi42LjIyCgojVGVydGlh
cnkgRENOIFByb2QgRE5TIE1hc3EgU2VydmVyCm5hbWVzZXJ2ZXIgMTAuNDkuNTguNAo=" | base64 -d > /etc/resolv.conf
return 0
}

# Capture Local Hostname
echo -en "Capturing Local Hostname ... "
THISBOX=$(uname -n | awk -F '.' '{print $1}')
SuccessMsg

# Get Proper (short) Hostname
echo -en "Getting Proper (short) Hostname ... "
SHORTBOX=$(echo "${THISBOX}" | sed -r "s/....$//g")
SuccessMsg

# Declare an array to hold our hosts values
declare -a HOSTLINE

# Ensure the integrity of the /etc/resolv.conf file
echo -en "Ensure the integrity of the /etc/resolv.conf file ... "
if [[ "$THISBOX" =~ ([sc]{1})([0-9]{4,})([dqc]{1})(al[vp]{1}) ]]
    then
        if [[ ! $(sha256sum /etc/resolv.conf | awk '{print $1}') = 'a879426e372674dfcb4b813b0e1dc874330410dfe5a9f8c82472ce035a1a0e0d' ]]
            then
                echo -en "\n\n/etc/resolv.conf is not in the expected format, restoring ... "
                if MakeCorpWestResolve
                    then
                        SuccessMsg
                    else
                        ErrorMsg "FAILED, please inspect!"
                        exit 1
                fi
            else
                SuccessMsg
        fi
elif [[ "$THISBOX" =~ ([sc]{1})([0-9]{4,})([dqc]{1})(pl[vp]{1}) ]]
    then
        if [[ ! $(sha256sum /etc/resolv.conf | awk '{print $1}') = 'ef2f5d42ee33c35a2c074e76d12eaa438023cd13aa21d968bfcd2853c8ce1f26' ]]
            then
                echo -en "\n\n/etc/resolv.conf is not in the expected format, restoring ... "
                if MakeCorpNorthResolve
                    then
                        SuccessMsg
                    else
                        ErrorMsg "FAILED, please inspect!"
                        exit 1
                fi
            else
                SuccessMsg
        fi
elif [[ "$THISBOX" =~ ([sc]{1})([0-9]{4,})([pst]{1})(al[vp]{1}) ]]
    then
        if [[ ! $(sha256sum /etc/resolv.conf | awk '{print $1}') = '808f5d941bc19f4cf90bf58c131d3aae8dbd4e7d2fe4000319be40433c7c9b66' ]]
            then
                echo -en "\n\n/etc/resolv.conf is not in the expected format, restoring ... "
                if MakeProdWestResolve
                    then
                        SuccessMsg
                    else
                        ErrorMsg "FAILED, please inspect!"
                        exit 1
                fi
            else
                SuccessMsg
        fi
elif [[ "$THISBOX" =~ ([sc]{1})([0-9]{4,})([pst]{1})(pl[vp]{1}) ]]
    then
        if [[ ! $(sha256sum /etc/resolv.conf | awk '{print $1}') = '1a6f513ce4ca97720d86609f063be17fd5bfd7f667a63d7a8351865c5f0629d0' ]]
            then
                echo -en "\n\n/etc/resolv.conf is not in the expected format, restoring ... "
                if MakeProdNorthResolve
                    then
                        SuccessMsg
                    else
                        ErrorMsg "FAILED, please inspect!"
                        exit 1
                fi
            else
                SuccessMsg
        fi
    else
        ErrorMsg "Hostname not formatted properly ... ERROR! (quitting for safety)\n\n"
        exit 1
fi

# Gather name values we want
DNSNAME=$(nslookup "$THISBOX" | grep 'Name' | awk 'NR==1' | awk -F ':' '{print $2}' | sed -r 's/\s+//g')
DOMAIN=$(nslookup "$THISBOX" | grep 'Name' | awk 'NR==1' | awk -F ':' '{print $2}' | sed -r 's/\s+//g' | awk -F '.' '{$1 = ""; print $0}' | sed -r 's/^\s+//g' | tr ' ' '.')
IPADDR=$(nslookup "$THISBOX" | grep 'Name' -A1 | awk 'NR==2' | awk -F ':' '{print $2}' | sed -r 's/\s+//g')

# Stop Splunk (with fire, if required)
echo -en "Stop Splunk (with fire, if required) ... "
{
if ! su - splunk -c "/opt/splunkforwarder/bin/splunk stop"
    then
        while (pgrep splunk)
            do
                for PID in $(pgrep splunk)
                    do
                        kill -9 "$PID"
                    done
            done
fi
} > /dev/null 2>&1
SuccessMsg

# Remove Splunkforwarder
echo -en "Checking for Splunkforwarder ... "
if rpm -q splunkforwarder >/dev/null 2>&1
    then
        SuccessMsg
        echo -en "Trying to uninstall Splunk Forwarder ... "
        if yum -y -q erase splunkforwarder >/dev/null 2>&1
            then
                SuccessMsg
                rm -rf /opt/splunkforwarder
        fi
    else
        ErrorMsg "Splunk Forwarder is not installed!"
        if [[ -d '/opt/splunkforwarder' ]]
            then
                rm -rf '/opt/splunkforwarder'
        fi
fi

# Fix '/etc/hosts' file
echo -en "Fixing the '/etc/hosts' file ... "
if grep -qi "$THISBOX" /etc/hosts
    then
        while IFS= read -r LINE
            do
                if [[ "$LINE" =~ ^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})(.*)$ ]]
                    then
                        IP="${BASH_REMATCH[1]}"
                        if [[ "${IP}" = "${IPADDR}" ]]
                            then
                                PROTECTED_HOSTS=$(echo "${BASH_REMATCH[2]}" | sed -r 's/\s+/,/g' | sed 's/^,//g' | sed 's/,$//g')
                                while IFS= read -r HOSTLIST
                                    do
                                        if [[ -n "$HOSTLIST" ]] && [[ ! "$HOSTLIST" =~ (${THISBOX})(\.corp)?(\.prod)?(\.hal)?$|${SHORTBOX}|localhost ]]
                                            then
                                                HOSTLINE+=("$HOSTLIST")
                                        fi
                                    done < <(echo "$PROTECTED_HOSTS" | tr ',' '\n' | sort -u)
                        fi
                fi
            done < <(cat /etc/hosts)
    else
        echo "${IPADDR} ${DNSNAME} ${THISBOX} ${SHORTBOX}" >> /etc/hosts
fi
SuccessMsg

# Remove entries in '/etc/hosts' with the local IP
echo -en "Remove entries in '/etc/hosts' with the local IP ... "
if sed -i "/${IPADDR}/d" /etc/hosts
    then
        SuccessMsg
    else
        ErrorMsg "Something went wrong, please inspect!"
        exit 1
fi

# Remove entries in '/etc/hosts' defined for IPv4 'localhost'
echo -en "Remove entries in '/etc/hosts' defined for IPv4 'localhost' ... "
if sed -i "/127\.0\.0\.1/d" /etc/hosts
    then
        SuccessMsg
    else
        ErrorMsg "Something went wrong, please inspect!"
        exit 1
fi

# Remove entries in '/etc/hosts' defined for IPv6 Localhost
echo -en "Remove entries in '/etc/hosts' defined for IPv6 Localhost ... "
if sed -i "/\:\:1/d" /etc/hosts
    then
        SuccessMsg
    else
        ErrorMsg "Something went wrong, please inspect!"
        exit 1
fi

# c
echo -en "Remove entries in '/etc/hosts' that do not start with an IP, and are also not comments ... "
while IFS= read -r LINE
    do
        if [[ ! "$LINE" =~ ^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})(.*)$ ]]
            then
                sed -i "/${LINE}/d" /etc/hosts
        fi
    done < <(grep -Ev '^#' /etc/hosts)
    SuccessMsg

if [[ "${#HOSTLINE[@]}" -ge '1' ]]
    then
        # Insert the information we want, in the format we want (suppress new-line)
        echo -en "Insert the information we want, in the format we want (suppress new-line) ... "
        echo -en "127.0.0.1 localhost\n${IPADDR} ${DNSNAME} ${THISBOX} ${SHORTBOX} " >> /etc/hosts
        SuccessMsg

        # Sanatize our hostline array
        UNIQUE_HOSTS=$(printf "%s\n" "${HOSTLINE[@]}" | sort -u | tr '\n' ' ' | sed 's/\s+$//g')

        # Output our sanatized array
        echo "${UNIQUE_HOSTS}" >> /etc/hosts
    else
        # Insert the information we want, in the format we want
        echo -en "Insert the information we want, in the format we want ... "
        echo -e "127.0.0.1 localhost\n${IPADDR} ${DNSNAME} ${THISBOX} ${SHORTBOX}" >> /etc/hosts
        SuccessMsg
fi

# Properly set the hostname
echo -en "Properly set the (short)hostname ... "
if [[ $(uname -r | grep -Eio 'el6|el7|el8') = 'el6' ]]
    then
        if hostname "${THISBOX}"
            then
                SuccessMsg
            else
                ErrorMsg "Something went wrong while setting the hostname, please inspect!"
        fi
    else
        if hostnamectl set-hostname "${THISBOX}"
            then
                SuccessMsg
            else
                ErrorMsg "Something went wrong while setting the hostname, please inspect!"
        fi
fi

# Properly format the network config
echo -en "Properly format the network config ... "
echo -en "# Created by your friendly nieghborhood Linux Admin\nHOSTNAME=\"${THISBOX}\"\nNETWORKING=\"yes\"\nNETWORKING_IPV6=\"no\"\nDOMAIN=\"${DOMAIN}\"\n" > /etc/sysconfig/network
SuccessMsg

# Update NetworkManager Configs
echo -en "Check for NetworkManager ... "
if rpm -q NetworkManager >/dev/null 2>&1
    then
        SuccessMsg
        if [[ ! -d '/etc/NetworkManager/conf.d/' ]]
            then
                mkdir -p '/etc/NetworkManager/conf.d/'
        fi
        # Tell NetworkManager to not manage the DNS Records.
        echo -en "Tell NetworkManager to not manage the DNS Records ... "
        echo -en "# Created by your friendly nieghborhood Linux Admin\n\n[main]\ndns=none\n" > /etc/NetworkManager/conf.d/dns.conf
        SuccessMsg
    else
        ErrorMsg "Network Manager is not installed, you should fix that!"
fi

# Check to make sure we have a good connection to Satellite
echo -en "Check to make sure we have a good connection to Satellite ... "
if subscription-manager identity > /dev/null 2>&1
    then
        SuccessMsg
        echo -en "Checking splunk UID/GID ... "
        if [[ $(id -u 'splunk') = '152' ]] && [[ $(id -g 'splunk') = '152' ]]
            then
                SuccessMsg
                echo -en "Installing Splunk Forwarder ... "
                if yum -y -q install splunkforwarder > /dev/null 2>&1
                    then
                        SuccessMsg
                        if [[ -d '/opt/splunkforwarder/etc/system/local' ]]
                            then
                                echo -en "Writing Deployment.conf config file ... "
                                echo -en "# Use the /Packages/cookbooks/ews_splunk/attributes/default.rb to\n# # set attributes which affect the rendering of this template.\n# # This template is from the prod chef repo,\n# # in the directory cookbooks/ews_splunk/templates/default/\n\n[deployment-client]\nphoneHomeIntervalInSecs = 300\n\n[target-broker:deploymentServer]\ntargetUri = splunk-deploy.int:8089\n\n" > '/opt/splunkforwarder/etc/system/local/deploymentclient.conf'
                                chown splunk:splunk '/opt/splunkforwarder/etc/system/local/deploymentclient.conf'
                                chmod 644 '/opt/splunkforwarder/etc/system/local/deploymentclient.conf'
                                SuccessMsg
                            else
                                if mkdir -p '/opt/splunkforwarder/etc/system/local'
                                    then
                                        echo -en "Writing Deployment.conf config file ... "
                                        echo -en "# Use the /Packages/cookbooks/ews_splunk/attributes/default.rb to\n# # set attributes which affect the rendering of this template.\n# # This template is from the prod chef repo,\n# # in the directory cookbooks/ews_splunk/templates/default/\n\n[deployment-client]\nphoneHomeIntervalInSecs = 300\n\n[target-broker:deploymentServer]\ntargetUri = splunk-deploy.int:8089\n\n" > '/opt/splunkforwarder/etc/system/local/deploymentclient.conf'
                                        chown splunk:splunk '/opt/splunkforwarder/etc/system/local/deploymentclient.conf'
                                        chmod 644 '/opt/splunkforwarder/etc/system/local/deploymentclient.conf'
                                        SuccessMsg
                                    else
                                        ErrorMsg "\n\nCould not create required Deployment directory, please inspect!\n\n"
                                fi
                        fi                                                        
                    else
                        ErrorMsg "\n\nDid not successfully re-install Splunk Forwarder, please inspect!\n\n"
                        exit 1
                fi
            else
                ErrorMsg "There was a problem with the expected UID/GID of the splunk user, please inspect!"
                exit 1
        fi
    else
        ErrorMsg "Satellite Registration could not be confirmed\n\n"
        # Determine the Capsule server to use:
        HOST=$(hostname -f | awk -F '.' '{print $1}')
        if [[ "$HOST" =~ [sc]{1}[0-9]{4,}[dqc]{1}[cia]{1}l[vp]{1} ]]
            then
                CAPSULE="west-corp-satellite-capsule"
                echo -en "${CAPSULE}\n"
                sleep 1
        elif [[ "$HOST" =~ [sc]{1}[0-9]{4,}[dqc]{1}pl[vp]{1} ]]
            then
                CAPSULE="north-corp-satellite-capsule"
                echo -en "${CAPSULE}\n"
                sleep 1
        elif [[ "$HOST" =~ [sc]{1}[0-9]{4,}[pst]{1}al[vp]{1} ]]
            then
                CAPSULE="west-prod-satellite-capsule"
                echo -en "${CAPSULE}\n"
                sleep 1
        elif [[ "$HOST" =~ [sc]{1}[0-9]{4,}[pst]{1}pl[vp]{1} ]]
            then
                CAPSULE="north-prod-satellite-capsule"
                echo -en "${CAPSULE}\n"
                sleep 1
            else
                ErrorMsg "Hostname not formatted properly"
                exit 1
        fi
        curl --silent --insecure --output /root/rhel_registration.bash https://"${CAPSULE}"/pub/rhel_registration.bash
        if [[ -f '/root/rhel_registration.bash' ]]
            then
                echo -en "Trying to get registered to Satellite ... "
                if bash /root/rhel_registration.bash >/dev/null 2>&1
                    then
                        SuccessMsg
                        echo -en "Checking splunk UID/GID ... "
                        if [[ $(id -u 'splunk') = '152' ]] && [[ $(id -g 'splunk') = '152' ]]
                            then
                                SuccessMsg
                                echo -en "Installing Splunk Forwarder ... "
                                if yum -y -q install splunkforwarder > /dev/null 2>&1
                                    then
                                        SuccessMsg
                                        if [[ -d '/opt/splunkforwarder/etc/system/local' ]]
                                            then
                                                echo -en "Writing Deployment.conf config file ... "
                                                echo -en "# Use the /Packages/cookbooks/ews_splunk/attributes/default.rb to\n# # set attributes which affect the rendering of this template.\n# # This template is from the prod chef repo,\n# # in the directory cookbooks/ews_splunk/templates/default/\n\n[deployment-client]\nphoneHomeIntervalInSecs = 300\n\n[target-broker:deploymentServer]\ntargetUri = splunk-deploy.int:8089\n\n" > '/opt/splunkforwarder/etc/system/local/deploymentclient.conf'
                                                chown splunk:splunk '/opt/splunkforwarder/etc/system/local/deploymentclient.conf'
                                                chmod 644 '/opt/splunkforwarder/etc/system/local/deploymentclient.conf'
                                                SuccessMsg
                                            else
                                                if mkdir -p '/opt/splunkforwarder/etc/system/local'
                                                    then
                                                        echo -en "Writing Deployment.conf config file ... "
                                                        echo -en "# Use the /Packages/cookbooks/ews_splunk/attributes/default.rb to\n# # set attributes which affect the rendering of this template.\n# # This template is from the prod chef repo,\n# # in the directory cookbooks/ews_splunk/templates/default/\n\n[deployment-client]\nphoneHomeIntervalInSecs = 300\n\n[target-broker:deploymentServer]\ntargetUri = splunk-deploy.int:8089\n\n" > '/opt/splunkforwarder/etc/system/local/deploymentclient.conf'
                                                        chown splunk:splunk '/opt/splunkforwarder/etc/system/local/deploymentclient.conf'
                                                        chmod 644 '/opt/splunkforwarder/etc/system/local/deploymentclient.conf'
                                                        SuccessMsg
                                                    else
                                                        ErrorMsg "\n\nCould not create required Deployment directory, please inspect!\n\n"
                                                fi
                                        fi                                                        
                                    else
                                        ErrorMsg "\n\nDid not successfully re-install Splunk Forwarder, please inspect!\n\n"
                                        exit 1
                                fi
                            else
                                ErrorMsg "There was a problem with the expected UID/GID of the splunk user, please inspect!"
                                exit 1
                        fi
                fi
        fi
fi

# Stop Splunk (with fire, if required)
echo -en "Stop Splunk (with fire, if required) ... "
{
if ! su - splunk -c "/opt/splunkforwarder/bin/splunk stop"
    then
        while (pgrep splunk)
            do
                for PID in $(pgrep splunk)
                    do
                        kill -9 "$PID"
                    done
            done
fi
} > /dev/null 2>&1
SuccessMsg

# Restart splunk (ensure process is running as Splunk user)
echo -en "Restart splunk (ensure process is running as Splunk user) ... "
{
if ! su - splunk -c '/opt/splunkforwarder/bin/splunk restart --accept-license --answer-yes --no-prompt'
    then
        exit 1
fi
} >/dev/null 2>&1
SuccessMsg

# Output information, to further confirm success
echo -en "Output information, to further confirm success ... \n"
cat /etc/hosts
echo -en "\n"
echo "FQDN: $(hostname -f)"
echo "Hostname: $(hostname)"
echo "Host Aliases: $(hostname -a)"
echo -en "\n\n"
SuccessMsg

# Validate Splunk and System hostnames match!
echo -en "Validate Splunk and System hostnames match ... "
if [[ -f '/opt/splunkforwarder/etc/system/local/server.conf' ]]
    then
        if [[ $(uname -n) = $(grep -Ei '^(serverName)(\s+)?(=)(\s+)?(.*)$' /opt/splunkforwarder/etc/system/local/server.conf | awk -F '=' '{print $2}' | tr -d '[:space:]') ]]
            then
                SuccessMsg
                echo "Hostname: $(hostname)"
                echo "Splunk Hostname: $(grep -Ei '^(serverName)(\s+)?(=)(\s+)?(.*)$' /opt/splunkforwarder/etc/system/local/server.conf | awk -F '=' '{print $2}' | tr -d ' ')"
        fi
    else
        ErrorMsg "Primary Splunk config file is missing!"
        exit 1
fi
