#!/usr/bin/env bash

# shellcheck disable=SC2230,SC2046

# --------------------------------------------------------------
# Date:
# October 21, 2020
# --------------------------------------------------------------

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

function SuccessMsg(){
    # Shell Color
    GREEN_TEXT="\e[32m"
    NORMAL_TEXT="\e[39m"

    # Construct the success message
    echo -e "${GREEN_TEXT}[ OK ]${NORMAL_TEXT}\n"
}

# Ensure only root/sudo run this script
if [[ "$UID" -ne '0' ]]
    then
        clear
        ErrorMsg "Please elevate to root privelages and try again!\n\n"
        sleep 2
        clear
        exit 1
fi

# Make sure we're in the expected path
if [[ $(pwd) != '/root' ]]
    then
        cd /root || ErrorMsg "Could not switch to operating path";exit 1
fi

# Stop Chef
echo -en "Stop Chef ... "
if [[ $(systemctl status chef-client | grep -o 'active (running)') = 'active (running)' ]]
    then
        if systemctl stop chef-client
            then
                SuccessMsg
                sleep 1
            else
                ErrorMsg "Could not stop Chef!"
                exit 1
        fi
    else
        echo -en "Chef is not running!\n"
fi

# Disable Chef auto-start
echo -en "Disable Chef auto-start ... "
if systemctl disable chef-client >/dev/null 2>&1
    then
        SuccessMsg
        sleep 1
    else
        ErrorMsg "Could not disable Chef!"
        exit 1
fi

# Remove Spacewalk
echo -en "Remove Spacewalk ... "
if [[ -f /etc/sysconfig/rhn/systemid ]] || [[ -f /etc/sysconfig/rhn/up2date ]]
    then
        rm -f /etc/sysconfig/rhn/{systemid,up2date}
        if yum -y -q erase osad* >/dev/null 2>&1
            then
                SuccessMsg
            else
                ErrorMsg "Could not remove Spacewalk"
                exit 1
        fi
fi

# Remove unsupported architecture apps
echo -en "Remove unsupported architecture apps ... "
read -r -a PACKAGE <<< $(rpm -qa | grep -Eiv 'x86_64$|noarch$|^gpg')
if [[ "${#PACKAGE[@]}" -ge '1' ]]
    then
        echo -en "\n\n"
        for ITEM in "${PACKAGE[@]}"
            do
                echo -en "\tRemoving: $ITEM ... "
                if yum -y -q erase "${ITEM}" >/dev/null 2>&1
                    then
                        SuccessMsg
                    else
                        ErrorMsg "Could not remove $ITEM"
                        exit 1
                fi
            done
        echo -en "\n"
    else
        SuccessMsg
fi


# Remove any existing subscription manager
echo -en "Remove any existing subscription manager ... "
if yum -y -q erase subscription-manager* >/dev/null 2>&1
    then
        SuccessMsg
        sleep 1
    else
        ErrorMsg "Could not remove the Subscription Manager"
        exit 1
fi

# Tell YUM to always skip-broken
if ! grep -qi 'skip_broken=1' /etc/yum.conf
    then
        echo -en "Tell YUM to always skip broken packages ... "
        if echo 'skip_broken=1' >> /etc/yum.conf
            then
                SuccessMsg
                sleep 1
            else
                ErrorMsg "Could not add directive to yum.conf"
                exit 1
        fi
fi

# System Variables
HOST=$(hostname -f | awk -F '.' '{print $1}')

# Workaround for a known issue outlined here: https://access.redhat.com/solutions/3573891
if rpm -qa | grep -Eqi ^java-1.7.0-openjdk
    then
        mkdir -p /var/lib/rpm-state
fi

# Install the convert2rhel Package (from EPEL)
echo -en "Install the convert2rhel Package (from EPEL) ... "
find /etc/yum.repos.d -type f -exec rm -f '{}' \; >/dev/null 2>&1
echo -en "[centos7-os]\nname=centos7-os\nbaseurl=https://artifactory.sba.tc/artifactory/list/CentOS-Main/7/os/x86_64/\nenabled=1\n\n[centos7-extras]\nname=centos7-extras\nbaseurl=https://artifactory.sba.tc/artifactory/list/CentOS-Main/7/extras/x86_64/\nenabled=1\n\n[centos7-updates]\nname=centos7-updates\nbaseurl=https://artifactory.sba.tc/artifactory/list/CentOS-Main/7/updates/x86_64/\nenabled=1\n\n[centos7-epel]\nname=centos7-epel\nbaseurl=https://artifactory.sba.tc/artifactory/list/CentOS-Main-EPEL/7/x86_64/\nenabled=1" > /etc/yum.repos.d/centos.repo
yum clean all >/dev/null 2>&1
yum repolist >/dev/null 2>&1
if yum -y -q install convert2rhel --nogpgcheck >/dev/null 2>&1
    then
        SuccessMsg
        sleep 1
    else
        ErrorMsg "Could not install convert2rhel"
        exit 1
fi

# Determine the Capsule server to use:
echo -en "Determining the Capsule Server to use ... "
HOST=$(hostname -f | awk -F '.' '{print $1}')
if [[ "$HOST" =~ [sc]{1}[0-9]{4,}[dqc]{1}[cia]{1}l[vp]{1} ]]
    then
        CAPSULE="west-corp-satellite-capsule"
        echo -en "${CAPSULE}\n"
        sleep 1
elif [[ "$HOST" =~ [sc]{1}[0-9]{4,}[dqc]{1}pl[vp]{1} ]]
    then
        CAPSULE="dcn-corp-capsule-satellite.sba.tc"
        echo -en "${CAPSULE}\n"
        sleep 1
elif [[ "$HOST" =~ [sc]{1}[0-9]{4,}[pst]{1}al[vp]{1} ]]
    then
        CAPSULE="west-prod-satellite-capsule"
        echo -en "${CAPSULE}\n"
        sleep 1
elif [[ "$HOST" =~ [sc]{1}[0-9]{4,}[pst]{1}pl[vp]{1} ]]
    then
        CAPSULE="dcn-prod-capsule-satellite.sba.tc"
        echo -en "${CAPSULE}\n"
        sleep 1
    else
        ErrorMsg "Hostname not formatted properly"
        exit 1
fi

# Import the GPG Key
echo -en "Import the GPG Key ... "
if curl --silent --insecure --output /usr/share/convert2rhel/RPM-GPG-KEY-redhat-release http://pkgrepo.int/CentOS-7-Conversion/RPM-GPG-KEY-redhat-release
    then
        if rpm --import /usr/share/convert2rhel/RPM-GPG-KEY-redhat-release >/dev/null 2>&1
            then
                SuccessMsg
                sleep 1
            else
                ErrorMsg "Could not import the RPM GPG Key"
                exit 1
        fi
fi

# Create the RHSM Working Directory
echo -en "Create the RHSM Working Directory ... "
if mkdir -p /usr/share/convert2rhel/{subscription-manager,redhat-release/Server} >/dev/null 2>&1
    then
        SuccessMsg
        sleep 1
    else
        ErrorMsg "Could not create the RHSM Working Directory"
        exit 1
fi

# Get the content we need, from PKGRepo
echo -en "Get the content we need, from PKGRepo ... "
echo -en "\n\tDownloading subscription-manager-1.24.42-1.el7.x86_64.rpm ... "
if curl --silent --insecure --output /usr/share/convert2rhel/subscription-manager/subscription-manager-1.24.42-1.el7.x86_64.rpm http://pkgrepo.int/CentOS-7-Conversion/Packages/subscription-manager-1.24.42-1.el7.x86_64.rpm
    then
        SuccessMsg
        echo -en "\tDownloading subscription-manager-rhsm-1.24.42-1.el7.x86_64.rpm ... "
        if curl --silent --insecure --output /usr/share/convert2rhel/subscription-manager/subscription-manager-rhsm-1.24.42-1.el7.x86_64.rpm http://pkgrepo.int/CentOS-7-Conversion/Packages/subscription-manager-rhsm-1.24.42-1.el7.x86_64.rpm
            then
                SuccessMsg
                echo -en "\tDownloading subscription-manager-rhsm-certificates-1.24.42-1.el7.x86_64.rpm ... "
                if curl --silent --insecure --output /usr/share/convert2rhel/subscription-manager/subscription-manager-rhsm-certificates-1.24.42-1.el7.x86_64.rpm http://pkgrepo.int/CentOS-7-Conversion/Packages/subscription-manager-rhsm-certificates-1.24.42-1.el7.x86_64.rpm
                    then
                        SuccessMsg
                        echo -en "\tDownloading redhat-release-server-7.9-3.el7.x86_64.rpm ... "
                        if curl --silent --insecure --output /usr/share/convert2rhel/redhat-release/Server/redhat-release-server-7.9-3.el7.x86_64.rpm http://pkgrepo.int/CentOS-7-Conversion/Packages/redhat-release-server-7.9-3.el7.x86_64.rpm
                            then
                                SuccessMsg
                            else
                                ErrorMsg "Could not download redhat-release-server-7.9-3.el7.x86_64.rpm from PKGRepo"
                                exit 1
                        fi
                    else
                        ErrorMsg "Could not download subscription-manager-rhsm-certificates-1.24.42-1.el7.x86_64.rpm from PKGRepo"
                        exit 1
                fi
            else
                ErrorMsg "Could not download subscription-manager-rhsm-1.24.42-1.el7.x86_64.rpm from PKGRepo"
                exit 1
        fi
    else
        ErrorMsg "Could not download subscription-manager-1.24.42-1.el7.x86_64.rpm from PKGRepo"
        exit 1
fi

# Download Listed Package Dependencies
PACKAGES=(dbus-python gobject-introspection pygobject3-base python-dateutil python-decorator python-dmidecode python-ethtool python-iniparse python-inotify python-setuptools python-six python-syspurpose)
for ITEM in "${PACKAGES[@]}"
    do
        yum -y -q install "$ITEM"
    done

# Get the satellite certificate
echo -en "Get the satellite certificate ... "
if curl --silent --insecure --output /usr/share/convert2rhel/subscription-manager/katello-ca-consumer-latest.noarch.rpm  https://"${CAPSULE}"/pub/katello-ca-consumer-latest.noarch.rpm
    then
        SuccessMsg
        sleep 1
    else
        ErrorMsg "Could not get the satellite cert"
        exit 1
fi

# Clean the YUM working directories
echo -en "Clean the YUM working directories ... "
if rm -rf /var/cache/yum /var/tmp/yum* /etc/yum.repos.d/centos.repo
    then
        yum clean all >/dev/null 2>&1
        SuccessMsg
        sleep 1
    else
        ErrorMsg "Could not clean YUM"
        exit 1
fi

# Install the Satellite Certificate
echo -en "Install the Satellite Certificate ... "
if yum -q -y localinstall /usr/share/convert2rhel/subscription-manager/katello-ca-consumer-latest.noarch.rpm >/dev/null 2>&1
    then
        SuccessMsg
        sleep 1
    else
        ErrorMsg "Could not install the Satellite Certificate"
        exit 1
fi

# Generate a proper YUM Cache
echo -en "Generate a proper YUM Cache ... "
if yum repolist >/dev/null 2>&1
    then
        SuccessMsg
        sleep 1
    else
        ErrorMsg "YUM Repolist failed"
        exit 1
fi

# Determine the proper activation key to use:
echo -en "Determine the proper activation key to use ... "
if [[ "$HOST" =~ ^[sc]{1}[0-9]{4,}(d[ancip]{1}lv)$ ]]
    then
        ACTIVATIONKEY="RHEL7_DEV_AK,7_DEV-AK"
        echo -en "${ACTIVATIONKEY}\n"
        sleep 1
elif [[ "$HOST" =~ ^[sc]{1}[0-9]{4,}(d[ancip]{1}lp)$ ]]
    then
        ACTIVATIONKEY="RHEL7_DEV_PHYSICAL_AK,7_DEV-AK"
        echo -en "${ACTIVATIONKEY}\n"
        sleep 1
elif [[ "$HOST" =~ ^[sc]{1}[0-9]{4,}(c[ancip]{1}lv)$ ]]
    then
        ACTIVATIONKEY="RHEL7_CORP_AK,7_CORP-AK"
        echo -en "${ACTIVATIONKEY}\n"
        sleep 1
elif [[ "$HOST" =~ ^[sc]{1}[0-9]{4,}(c[ancip]{1}lp)$ ]]
    then
        ACTIVATIONKEY="RHEL7_CORP_PHYSICAL_AK,7_CORP-AK"
        echo -en "${ACTIVATIONKEY}\n"
        sleep 1
elif [[ "$HOST" =~ ^[sc]{1}[0-9]{4,}(q[ancip]{1}lv)$ ]]
    then
        ACTIVATIONKEY="RHEL7_QA_AK,7_QA-AK"
        echo -en "${ACTIVATIONKEY}\n"
        sleep 1
elif [[ "$HOST" =~ ^[sc]{1}[0-9]{4,}(q[ancip]{1}lp)$ ]]
    then
        ACTIVATIONKEY="RHEL7_QA_PHYSICAL_AK,7_QA-AK"
        echo -en "${ACTIVATIONKEY}\n"
        sleep 1
elif [[ "$HOST" =~ ^[sc]{1}[0-9]{4,}(p[ancip]{1}lv)$ ]]
    then
        ACTIVATIONKEY="RHEL7_PROD_AK,7_PROD-AK"
        echo -en "${ACTIVATIONKEY}\n"
        sleep 1
elif [[ "$HOST" =~ ^[sc]{1}[0-9]{4,}(p[ancip]{1}lp)$ ]]
    then
        ACTIVATIONKEY="RHEL7_PROD_PHYSICAL_AK,7_PROD-AK"
        echo -en "${ACTIVATIONKEY}\n"
        sleep 1
elif [[ "$HOST" =~ ^[sc]{1}[0-9]{4,}(s[ancip]{1}lv)$ ]]
    then
        ACTIVATIONKEY="RHEL7_DR_AK,7_DR-AK"
        echo -en "${ACTIVATIONKEY}\n"
        sleep 1
elif [[ "$HOST" =~ ^[sc]{1}[0-9]{4,}(s[ancip]{1}lp)$ ]]
    then
        ACTIVATIONKEY="RHEL7_DR_PHYSICAL_AK,7_DR-AK"
        echo -en "${ACTIVATIONKEY}\n"
        sleep 1
elif [[ "$HOST" =~ ^[sc]{1}[0-9]{4,}(t[ancip]{1}lv)$ ]]
    then
        ACTIVATIONKEY="RHEL7_CAT-UAT_AK,7_CAT-UAT-AK"
        echo -en "${ACTIVATIONKEY}\n"
        sleep 1
elif [[ "$HOST" =~ ^[sc]{1}[0-9]{4,}(t[ancip]{1}lp)$ ]]
    then
        ACTIVATIONKEY="RHEL7_CAT-UAT_PHYSICAL_AK,7_CAT-UAT-AK"
        echo -en "${ACTIVATIONKEY}\n"
        sleep 1
    else
        ErrorMsg "Could not determine proper activation key!"
        exit 1
fi

# Convert CentOS 7 --> RHEL 7
echo -en "Convert CentOS 7 --> RHEL 7 ... "
if convert2rhel --org="SBA-TC_LLC" --activationkey="${ACTIVATIONKEY}" --variant="Server" --no-rpm-va -y --auto-attach --debug
    then
        SuccessMsg
    else
        ErrorMsg "Failed to convert to RHEL"
        exit 1
fi

# Clean up
subscription-manager register --org="SBA-TC_LLC" --activationkey="${ACTIVATIONKEY}" --force

# Clean the YUM working directories
echo -en "Clean the YUM working directories ... "
if rm -rf /var/cache/yum /var/tmp/yum* /tmp/yum*
    then
        yum clean all >/dev/null 2>&1
        SuccessMsg
        sleep 1
    else
        ErrorMsg "Could not clean YUM"
        exit 1
fi

# Generate a proper YUM Cache
echo -en "Generate a proper YUM Cache ... "
if yum repolist >/dev/null 2>&1
    then
        SuccessMsg
        sleep 1
    else
        ErrorMsg "YUM Repolist failed"
        exit 1
fi

# Install the Katello tools and InSights Client
echo -en "Install the Katello tools and InSights Client ... "
if yum -y -q install insights-client katello*
    then
        SuccessMsg
        echo -en "Registering system to the Insights Engine in Satellite ... "
        if insights-client --register
            then
                SuccessMsg
            else
                ErrorMsg "Failed to register Insights"
        fi
    else
        echo -en "\n\n\nSomething went wrong trying to install insights and/or Katello, please review!\n\n\n"
        exit 1
fi

# Performing a FULL SYSTEM UPDATE
echo -en "Performing a FULL SYSTEM UPDATE ... "
if yum -y -q update >/dev/null 2>&1
    then
        if rpm -qa --last | grep -Ei 'vasclnt' | awk '{print $1}'
            then
                while true
                    do
                        read -r -p $'\n\nPLEASE ENTER YOUR ID: \n--> ' USERNAME
                        if [[ ! "$USERNAME" =~ ([a-z]*)([0-9]{4}) ]]
                            then
                                echo -en "ID did not meet regex filter, Please try again"
                                continue
                            else
                                echo -en "\n\n"
                                break
                        fi
                    done
                if /opt/quest/bin/vastool -u "$USERNAME" join -f -c "ou=Linux,ou=Server,dc=SBA,dc=TC" sba.tc
                    then
                        echo -en "\n\n\nREBOOTING\n\n\nLATER TATER!\n\n\n"
                        $(which shutdown) -r now
                    else
                        ErrorMsg "VAS Updated, but failed to re-join the domain!"
                        exit 1
                fi
            else
                echo -en "\n\n\nREBOOTING\n\n\nLATER TATER!\n\n\n"
                $(which shutdown) -r now
        fi
    else
        ErrorMsg "System Update FAILED, please review!"
        exit 1
fi
