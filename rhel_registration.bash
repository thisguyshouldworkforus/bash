#!/usr/bin/env bash

# shellcheck disable=SC2230,SC2034

# --------------------------------------------------------------
# Date:
# September 03, 2020
# --------------------------------------------------------------

# Ensure only root/sudo run this script
if [[ "$UID" -ne '0' ]]
    then
        clear
        echo -en '\n\nPlease elevate to root privelages and try again!\n\n'
        sleep 2
        clear
        exit 1
fi

if [[ ! $(pwd) = '/root' ]]
    then
        cd '/root' || exit 1
fi

# Shell Colors
NORMAL_TEXT="\e[39m"
RED_TEXT="\e[31m"
NORMAL_BACKGROUND="\e[49m"
WHITE_BACKGROUND="\e[107m"

function GetPython(){
# Ensure we have python installed
echo -en "\n\nEnsuring we have Python2 and Python3 installed ... \n"
PYTHON2=$(rpm -qa | grep -Ei '^python-2\.*')
PYTHON3=$(rpm -qa | grep -Ei '^python3-3\.*')
if [[ -z "$PYTHON2" ]]
    then
        if ! yum -y -q install python2 >/dev/null 2>&1
            then
                echo -en "ERROR! (could not install python2)\n\n"
                exit 1
            else
                echo -en "\tPython2 Installed ($(rpm -qa | grep -Ei '^python-2\.*'))\n"
        fi
    else
        echo -en "\tPython2 Installed ($PYTHON2)\n"
fi
if [[ -z "$PYTHON3" ]]
    then
        if ! yum -y -q install python3 >/dev/null 2>&1
            then
                echo -en "ERROR! (could not install python3)\n\n"
                exit 1
            else
                echo -en "\tPython3 Installed ($(rpm -qa | grep -Ei '^python3-3\.*'))\n"
        fi
    else
        echo -en "\tPython3 Installed ($PYTHON3)\n"
fi
}

function MakePIP(){
# Create PIP Working Directory
echo -en "Creating the PIP config directory ... "
if [[ ! -d '/root/.pip' ]]
    then
        if ! mkdir -p /root/.pip
            then
                echo -en 'COULD NOT CREATE PIP WORKING DIRECTORY\n\n'
                exit 1
            else
                echo -en "done!\n"
        fi
    else
        echo -en "done!\n"
fi

# Create PIP configuration file
echo -en "Creating the PIP config file ... "
if [[ ! -f '/root/.pip/pip.conf' ]]
    then
        if echo -en "[global]\nindex-url = https://artifactory.sba.tc/artifactory/api/pypi/Pypi/simple\ntrusted-host = artifactory.sba.tc\n" > /root/.pip/pip.conf
            then
                echo -en "done!\n"
            else
                echo -en "ERROR! (quitting for safety)\n\n"
        fi
    else
        if [[ $(awk '{print $1}' < <(md5sum /root/.pip/pip.conf)) != '9e287afc915c77e4989943c0f9aa071a' ]]
            then
                if echo -en "[global]\nindex-url = https://artifactory.sba.tc/artifactory/api/pypi/Pypi/simple\ntrusted-host = artifactory.sba.tc\n" > /root/.pip/pip.conf
                    then
                        echo -en "done!\n"
                    else
                        echo -en "ERROR! (quitting for safety)\n\n"
                fi
        fi
fi

# Update PIP
echo -en "Updating PIP ... "
if [[ $($(which python3) -m pip -V | awk '{print $2}') != '21.0.1' ]]
    then
        if ! $(which python3) -m pip install -U pip >/dev/null 2>&1
            then
                echo -en 'COULD NOT UPDATE PIP\n\n'
                exit 1
            else
                echo -en "done!\n"
        fi
fi

# Install PIP Modules
echo -en "Installing required PIP Modules ... "
if ! $(which python3) -m pip list --format=columns | awk 'NR>=3{print $1}' | grep -qi request
    then
        if ! $(which python3) -m pip install request >/dev/null 2>&1
            then
                echo -en "COULD NOT INSTALL PIP MODULE \"REQUEST\"\n\n"
                exit 1
            else
                echo -en "done!\n"
        fi
    else
        echo -en "done!\n"
fi
}

function GetCapsule(){
# Determine the proper capsule server to use
echo -en "Determining the Capsule Server to use ... "
HOST=$(hostname -f | awk -F '.' '{print $1}')
if [[ "$HOST" =~ ([sc]{1})([0-9]{4,})([kdqc]{1})(al[vp]{1}) ]]
    then
        CAPSULE="west-corp-satellite-capsule"
        echo -en "${CAPSULE}\n"
elif [[ "$HOST" =~ ([sc]{1})([0-9]{4,})([dqc]{1})(pl[vp]{1}) ]]
    then
        CAPSULE="north-corp-satellite-capsule"
        echo -en "${CAPSULE}\n"
elif [[ "$HOST" =~ ([sc]{1})([0-9]{4,})([pst]{1})(al[vp]{1}) ]]
    then
        CAPSULE="west-prod-satellite-capsule"
        echo -en "${CAPSULE}\n"
elif [[ "$HOST" =~ ([sc]{1})([0-9]{4,})([pst]{1})(pl[vp]{1}) ]]
    then
        CAPSULE="north-prod-satellite-capsule"
        echo -en "${CAPSULE}\n"
    else
        echo -en "Hostname not formatted properly ... ERROR! (quitting for safety)\n\n"
        exit 1
fi
}

function GetKey(){
# Determine the activation key to use, valid only for RHEL6:
echo -en "Determining the Capsule Server to use ... "
HOST=$(hostname -f | awk -F '.' '{print $1}')
if [[ "$HOST" =~ ([sc]{1})([0-9]{4,})(d[ap]{1}lv) ]]
    then
        ACTIVATIONKEY="RHEL6_DEV_AK,6_DEV-AK,ELS-REPO-6_DEV-AK"
elif [[ "$HOST" =~ ([sc]{1})([0-9]{4,})(d[ap]{1}lp) ]]
    then
        ACTIVATIONKEY="RHEL6_DEV_PHYSICAL_AK,6_DEV-AK,ELS-REPO-6_DEV-AK"
elif [[ "$HOST" =~ ([sc]{1})([0-9]{4,})(q[ap]{1}lv) ]]
    then
        ACTIVATIONKEY="RHEL6_QA_AK,6_QA-AK,ELS-REPO-6_QA-AK"
elif [[ "$HOST" =~ ([sc]{1})([0-9]{4,})(q[ap]{1}lp) ]]
    then
        ACTIVATIONKEY="RHEL6_QA_PHYSICAL_AK,6_QA-AK,ELS-REPO-6_QA-AK"
elif [[ "$HOST" =~ ([sc]{1})([0-9]{4,})(c[ap]{1}lv) ]]
    then
        ACTIVATIONKEY="RHEL6_CORP_AK,6_CORP-AK,ELS-REPO-6_CORP-AK"
elif [[ "$HOST" =~ ([sc]{1})([0-9]{4,})(c[ap]{1}lp) ]]
    then
        ACTIVATIONKEY="RHEL6_CORP_PHYSICAL_AK,6_CORP-AK,ELS-REPO-6_CORP-AK"
elif [[ "$HOST" =~ ([sc]{1})([0-9]{4,})(p[ap]{1}lv) ]]
    then
        ACTIVATIONKEY="RHEL6_PROD_AK,6_PROD-AK,ELS-REPO-6_PROD-AK"
elif [[ "$HOST" =~ ([sc]{1})([0-9]{4,})(p[ap]{1}lp) ]]
    then
        ACTIVATIONKEY="RHEL6_PROD_PHYSICAL_AK,6_PROD-AK,ELS-REPO-6_PROD-AK"
elif [[ "$HOST" =~ ([sc]{1})([0-9]{4,})(s[ap]{1}lv) ]]
    then
        ACTIVATIONKEY="RHEL6_DR_AK,6_DR-AK,ELS-REPO-6_DR-AK"
elif [[ "$HOST" =~ ([sc]{1})([0-9]{4,})(s[ap]{1}lp) ]]
    then
        ACTIVATIONKEY="RHEL6_DR_PHYSICAL_AK,6_DR-AK,ELS-REPO-6_DR-AK"
elif [[ "$HOST" =~ ([sc]{1})([0-9]{4,})(t[ap]{1}lv) ]]
    then
        ACTIVATIONKEY="RHEL6_CAT-UAT_AK,6_CAT-UAT-AK,ELS-REPO-6_CAT-UAT-AK"
elif [[ "$HOST" =~ ([sc]{1})([0-9]{4,})(t[ap]{1}lp) ]]
    then
        ACTIVATIONKEY="RHEL6_CAT-UAT_PHYSICAL_AK,6_CAT-UAT-AK,ELS-REPO-6_CAT-UAT-AK"
    else
        echo -en "Hostname not formatted properly ... ERROR! (quitting for safety)\n\n"
        exit 1
fi
}

function CleanOld(){
# Cleanup Old Installs
echo -en "Cleaning up old information ... "
RPM=$(rpm -qa | grep -qi 'katello-ca-consumer')
if [[ ! "$RPM" =~ (.*)(capsule)(.*) ]]
    then
        if rpm -e "$RPM" >/dev/null 2>&1
            then
                subscription-manager clean >/dev/null 2>&1
                echo -en "done!\n"
        fi
    else
        echo -en "done!\n"
fi
}

function GetCertificate(){
# Get the certificate
echo -en "Getting the capsule certificate ... "
if curl -k -o '/root/katello-ca-consumer-latest.noarch.rpm' "https://${CAPSULE}:443/pub/katello-ca-consumer-latest.noarch.rpm"
    then
        echo -en "done!\n"
        echo -en "Installing the capsule certificate ... "
        if ! rpm -ivh /root/katello-ca-consumer-latest.noarch.rpm
            then
                echo -en "done!\n"
            else
                echo -en "ERROR! (quitting for safety)\n\n"
                exit 1
        fi
    else
        echo -en "ERROR! (quitting for safety)\n\n"
        exit 1
fi
}

function GetScripts(){
# Get the script and run it
echo -en "Get the bootstrap script and run it ... "
if curl -k -o '/root/bootstrap_wrapper.py' "https://${CAPSULE}:443/pub/bootstrap_wrapper.py"
    then
        chown root:root /root/bootstrap_wrapper.py
        chmod 755 /root/bootstrap_wrapper.py
        $(which python3) /root/bootstrap_wrapper.py
        sleep 2
        subscription-manager auto-attach --enable
        sleep 2
        subscription-manager attach --auto
        sleep 2
        subscription-manager refresh
    else
        echo -en "Could not obtain the bootstrap wrapper script!\n\n"
        exit 1
fi
}

function GetRegistered(){
# Get registered to Satellite, applies only to RHEL 6
if subscription-manager register --org="SBA-TC_LLC" --activationkey="$ACTIVATIONKEY" --force
    then
        subscription-manager auto-attach --enable
        sleep 2
        subscription-manager attach --auto
        sleep 2
        subscription-manager refresh
fi
}

function GetInsightsAndKatello(){
# Install the InSights Client and Katello Tools
if [[ -f '/root/katello-ca-consumer-latest.noarch.rpm' ]]
    then
        rm -f '/root/katello-ca-consumer-latest.noarch.rpm'
fi

echo -en "Install the Katello tools and InSights Client ... "
if yum -y -q install insights-client openscap openscap-scanner scap-security-guide katello*
    then
        echo -en "done!\n"
        if [[ ! "$HOST" =~ (.*)(kalv) ]]
            then
                if ! insights-client --status >/dev/null
                    then
                        echo -en "Registering system to the Insights Engine in Satellite ... "
                        if insights-client --register
                            then
                                echo -en "done!\n"
                            else
                                echo -en "\n\n\nThere was an error registering with Insights\n\n\n"
                        fi
                    else
                        echo -en "This system is already registered with Insights\n"
                        echo -en "Checking in with Insights ..."
                        if insights-client --checkin >/dev/null
                            then
                                echo -en " done!\n"
                            else
                                echo -en "\n\n\nThere was an error checking in with Insights\n\n\n"
                        fi
                fi
        fi
fi
}

# Determine the OS Version and run steps specific to that.
if uname -r | grep -qi 'el6'
    then
        GetCapsule
        GetKey
        CleanOld
        GetCertificate
        GetRegistered
        GetInsightsAndKatello
    else
        GetPython
        MakePIP
        GetCapsule
        CleanOld
        GetCertificate
        GetScripts
        GetInsightsAndKatello
fi
