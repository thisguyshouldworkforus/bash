
# ![logo](https://camo.githubusercontent.com/a7de91b915d8b286dda762e3683d9a1c961692d43f8349d020ecd54634a823cf/68747470733a2f2f63646e2e7261776769742e636f6d2f6f64622f6f6666696369616c2d626173682d6c6f676f2f6d61737465722f6173736574732f4c6f676f732f4964656e746974792f504e472f424153485f6c6f676f2d7472616e73706172656e742d62672d636f6c6f722e706e67)

A simple repo to hold scripts that I have written over the years for a variety of purposes


## License

[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)


## Delete Old Log Files
[![ ](https://img.shields.io/badge/DEPENDENCY-Requires%20Root%20Access-red)](https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/root-account.html)

[delete_old_logs.bash](delete_old_logs.bash) is a small script to nuke log files older than 90 days.

- In this script it will:
  - Require sudo/root access to run
  - Generate a UNIX timestamp of today
  - Initiate (or append) our Log File
  - Find Old Log Files
    - Use `stat` to get the timestamp of the file, divide that by days and check to see if it is over 90 days old.  If it is, it deletes the file without prejudice `rm -f`
  - Logs the actions it has taken per file, in a `while loop`.

## Fix Splunk Forwarder
[![ ](https://img.shields.io/badge/DEPENDENCY-Requires%20Root%20Access-red)](https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/root-account.html)

[FixSplunkForwarder.bash](FixSplunkForwarder.bash) is a shell script to "fix" hostname and network configurations so Splunkfowarder stops complaining.

- In this script it will:
    - Contruct a success message (by creating a function with special formatting)
    - Construct an error message (by creating a function with special formatting)
    - Decode a `BASE64` encoded version of a "known good" `/etc/resolv.conf` file.
    - Capture the local hostname, and print a `SuccessMsg`
    - Declare's an indexed array called `HOSTLINE`
    - Compares the `md5sum` of the local `/etc/resolv.conf` file to that of the known good copy, if they do not match, then the file is replaced by the `BASE64` version stored earlier.
    - Gathers DNS information it needs to continue
    - Stop Splunk (with fire, if required)
    - Remove Splunkforwarder
    - Reads the `/etc/hosts` line by line
      - `/etc/hosts` files are in the format of `[IP][whitespace character][hostname]`
      - It uses `regex` and `BASH_REMATCH`ing to fill our previously defined `HOSTLINE` array
      - If the `IP` matches the local box IP it assumes that entry is a `PROTECTED_HOST` and saves that hostname for the future in the HOSTLINE array
    - Blow out everything in the `/etc/hosts` file
      - Remove entries in `/etc/hosts` with the local IP
      - Remove entries in `/etc/hosts` defined for IPv4 `localhost`
      - Remove entries in `/etc/hosts` defined for IPv6 `localhost`
      - Remove entries in `/etc/hosts` that do not start with an IP, and are also not comments
    - If our `HOSTLINE` array contains 1 or more entries, then we 
      - add the information we want
        - `127.0.0.1 localhost\n${IPADDR} ${DNSNAME} ${THISBOX} ${SHORTBOX} " >> /etc/hosts`
        - Sanatize our array (sort it for unique entries only)
        - Output our sanatized array
    - If our `HOSTLINE` array contains no entriews, then we
      - `127.0.0.1 localhost\n${IPADDR} ${DNSNAME} ${THISBOX} ${SHORTBOX} " >> /etc/hosts`
    - Properly set the hostname
    - Properly format the network config
    - Update NetworkManager Configs (tell NetworkManager to NOT manage DNS)
    - Check to make sure we have a good connection to RedHat Satellite
      - If Yes:
        - Checking splunk UID/GID
        - Installing Splunk Forwarder
        - Checks for the Splunk `/opt/splunkforwarder/etc/system/local` directory, if not found, it creates it.
        - Writes the proper Splunk `deployment.conf` file.
      - If No:
        - Attempts to re-register to RedHat Satellite [![ ](https://img.shields.io/badge/ALERT-Deprecated%20in%20Satellite%20v6.9-blue)](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.9/html-single/release_notes/index#deprecated_functionality)
          - If successful:
            - Checking splunk UID/GID
            - Installing Splunk Forwarder
            - Checks for the Splunk `/opt/splunkforwarder/etc/system/local` directory, if not found, it creates it.
            - Writes the proper Splunk `deployment.conf` file.
          - If unsuccessful:
            - Print error
    - Stop Splunk (with fire, if required)
    - Restart splunk (ensure process is running as Splunk user)
    - Output information, to further confirm success
    - Validate Splunk and System hostnames match!

## LAMP
[![ ](https://img.shields.io/badge/DEPENDENCY-Requires%20Root%20Access-red)](https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/root-account.html)

[lamp.sh](lamp.sh)

This is my first shell script of any real consequence.  It was written around 2012/2013 and doesn't contain any logic. Its fun to go back and see where we've been!

## Monitor Sudoers
[![ ](https://img.shields.io/badge/DEPENDENCY-Requires%20Root%20Access-red)](https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/root-account.html)

[MonitorSudoers.bash]([MonitorSudoers.bash) is a script to output an MD5Sum of the `/etc/sudoers` file and the contents of the `/etc/sudoers.d` directory and report on changes

- In this script it will:
  - Check to see if the checksum file **DOES NOT** exist (`/root/sudoers.md5`) (_inverted logic_)
    - If `true` (_true, it does not exist_)
      - Write a checksum to a file (`/root/sudoers.md5`)
    - If `false` (_false, it does exist_)
      - Write a checksum to a variable `CHECK`
      - Compare existing checksum to `"$CHECK"`
        - If they don't match
          - send an alert to `/var/log/messages`
          - Remove our known good checksum, so it can be repopulated.
  - Create a `while read` loop to go through all the files in `/etc/sudoers.d/` (_`find /etc/sudoers.d -type f`_)
  - Shorten the filename (`SHORT=$(echo "$FILE" | awk -F/ '{print $NF}' | tr '[:upper:]' '[:lower:]')`)
  - Check to see if the checksum file **DOES NOT** exist (`/root/sudoers_"$SHORT".md5`) (_inverted logic_)
    - If `true` (_true, it does not exist_)
      - Write a checksum to a file (`/root/sudoers_"$SHORT".md5`)
    - If `false` (_false, it does exist_)
      - Write a checksum to a variable `CHECK`
      - Compare existing checksum to `"$CHECK"`
        - If they don't match
          - send an alert to `/var/log/messages`
          - Remove our known good checksum, so it can be repopulated.


## Publish And Promote (RedHat Satellite)
[![ ](https://img.shields.io/badge/DEPENDENCY-RedHat%20Satellite-green)](https://www.redhat.com/en/technologies/management/satellite)  
[![ ](https://img.shields.io/badge/DEPENDENCY-Requires%20Admin%20%28root%29%20Access-red)](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.10/html/hammer_cli_guide/index)  
[![ ](https://img.shields.io/badge/DEPENDENCY-Requires%20Hammer%20Access-orange)](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.10/html/hammer_cheat_sheet/index)  

[PublishAndPromote_Satellite.bash](PublishAndPromote_Satellite.bash) is a script to automate the publishing/promotion of content views each month.

- In this script it will:
  - When we publish the content views, we set a file `touch /tmp/.dev-qa-promoted`, we look for that file, if we find it, that tells us that we have already published, we get the time of the last publish and issue a **WARNING**, allowing the user to quit here, if they want.
  - Gather the next month (`NEXT_MONTH=$(date +"%B" -d "next month")`)
  - Publish non-composite content-views (`hammer content-view list --organization-id="1" --noncomposite="1" --fields="Content View ID,Name"`)
  - Publish composite content-views (`hammer content-view list --organization-id="1" --composite="1" --fields="Content View ID,Name"`)
  - Promoting composite content-views to DEV/QA (`hammer content-view version promote`)
    - Set a hidden file so we know we have promoted this (`touch /tmp/.dev-qa-promoted."$(date +'%s')"`)
  - Promoting Satellite content-view to CORP/PROD (_content view specifically for Satellite Capsule servers_) (`hammer content-view version promote`)

## RedHat Satellite Registration
[![ ](https://img.shields.io/badge/DEPENDENCY-RedHat%20Satellite-green)](https://www.redhat.com/en/technologies/management/satellite)  
[![ ](https://img.shields.io/badge/DEPENDENCY-Requires%20Root%20Access-red)](https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/root-account.html)  
[![ ](https://img.shields.io/badge/ALERT-Deprecated%20in%20Satellite%20v6.9-blue)](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.9/html-single/release_notes/index#deprecated_functionality)  

[rhel_registration.bash](rhel_registration.bash) is a wrapper Shell Script to prepare an environment for RedHat Satellite registration.

- In this script it will:
  - If system is `RHEL 6` then:
    - Determine the proper capsule server to use
    - Get registered to Satellite, applies only to RHEL 6 (`function GetRegistered` is only applicable on RHEL 6 systems)
    - Install the InSights Client and Katello Tools
  - If system is `RHEL 7|8` then:
    - Ensure we have python installed
    - Create PIP Working Directory
    - Create PIP configuration file
    - Update PIP
    - Install PIP Modules
    - Determine the proper capsule server to use
    - Cleanup Old Installs
    - Get the Satellite certificate for authorization
    - Get the [system-bootstrap.py](https://github.com/thisguyshouldworkforus/python/blob/main/system_bootstrap.py) script and run it.
    - Install the InSights Client and Katello Tools

## Seven 2 Seven
[![ ](https://img.shields.io/badge/DEPENDENCY-RedHat%20Satellite-green)](https://www.redhat.com/en/technologies/management/satellite)  
[![ ](https://img.shields.io/badge/DEPENDENCY-Requires%20Root%20Access-red)](https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/root-account.html)  

[seven2seven.bash](seven2seven.bash) is a script to automate the conversion of CentOS 7 --> RHEL 7.

- In this script it will:
    - Contruct a success message (by creating a function with special formatting)
    - Construct an error message (by creating a function with special formatting)
    - Make sure we're in the expected path (expecting to be in `/root`)
    - Stop Chef from running (_we're chaning a ton about the system, we don't want Chef trying to revert things mid-change_)
    - Disable Chef auto-start (_there will be at least one reboot, so we want to make sure Chef doesn't get started after reboot_)
    - RedHat Satellite in CentOS 5 was free and called `Spacewalk`. We need to remove that, if it exists.
    - Remove unsupported architecture apps (the conversion process fails when there are **both** `x86` and `x86_64` binary architectures, so we are removing the 32-bit `x86` programs/libraries. They can be re-added later.)
    - In case there was a previously failed conversion attempt, we need to remove the `subscription-manager` if there is one
    - Tell YUM to always skip-broken (_a bit of housekeeping that isn't a bad idea_)
    - Collect the hostname, as the system understands it to be
    - Install the convert2rhel Package (from EPEL)
    - Determine the RedHat Satellite Capsule server to use
    - Create the RHSM Working Directory (`mkdir -p /usr/share/convert2rhel/{subscription-manager,redhat-release/Server}`)
    - Get the content we need, from PKGRepo
    - Quietly install Python dependencies
    - Get the satellite certificate, for later authorization
    - Flush YUM cache
    - Install the Satellite Certificate (_so we can talk to RedHat Satellite_)
    - Generate a proper YUM Cache
    - Determine the proper activation key to use
    - Use `convert2rhel` and actually Convert CentOS 7 --> RHEL 7
    - Install the Katello tools and InSights Client
    - Performing a FULL SYSTEM UPDATE

## Splunk ACL Check
[![ ](https://img.shields.io/badge/DEPENDENCY-Requires%20Root%20Access-red)](https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/root-account.html)  

[splunk_acl_check.bash](splunk_acl_check.bash) is a script that will attempt to test files that splunk is unable to read, and then set an ACL for splunk to read it.

- In this script it will:
  - Make sure the log we're using as our source of truth actually exists
  - Generate a list of files that splunk cannot read (`grep -Eo "Insufficient permissions to read file='.*'" /opt/splunkforwarder/var/log/splunk/splunkd.log | sort -u`)
  - Check to make sure the line we're operating on matches an expected pattern (`(Insufficient permissions to read file=\')(.*)(\')`)
  - Since the line matches our expected pattern (regex) pull out the second matching group
  - Make sure the file we're referencing actually exists
  - This is a path that is not owned by Splunk, but splunk still needs to read (`[[ ! "$ACL_FILE" =~ ^/opt/splunkforwarder/.*$ ]]`)
    - `function TestACL` is just a simple function to return if splunk has read permission on the `"$ACL_FILE"`
      - `return 0`: Log a success message, `$(which logger) "SPLUNK_ACL --- ACL is already set on \"$ACL_FILE\", no action required."`
      - `return 1`:
        - Splunk cannot read this file, ACLs are not set, lets fix that!
        - Gather information about the file such as the `File Partition` it resides on, where that partition is mounted, the full file path, etc, etc ...
    - `function EnableACLs`
      - Define a `TESTFILE` (`TESTFILE=${1}/facltest."$(date +"%s")"`)
      - Determine the Operating System version (`el6|el7|el8`)
      - Testing for ACL Support
        - If `setfacl` fails (_on TESTFILE_), remove `TESTFILE` and log a message:
          - `$(which logger) "SPLUNK_ACL --- ACLs are not supported on $(hostname), adjusting..."`
      - Backup the `/etc/fstab` file
      - Take the information that was passed to the function (Partition, Mount) and rewrite that entry in the `/etc/fstab` file to properly support ACLs
      -  If `function EnableACLs` failed, log a message: `$(which logger) "SPLUNK_ACL --- Failed to enable ACLs for filesystem \"$FILEMOUNT\"."`
      -  If `function EnableACLs` succeeds, set FACL on that previously failed file
         -  Test that ACLs now work

## Sudo 2 Root
[![ ](https://img.shields.io/badge/DEPENDENCY-Requires%20Root%20%28sudo%29%20Access-red)](https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/root-account.html)  

[sudo2root.bash](sudo2root.bash) is a script that will gather a list of users with sudo-to-root privelages

- In this script it will:
  - Gather a `DATE` variable defined as `date +"%m-%d-%Y %T %Z"`
  - Gather the `hostname`
  - Start a `while read` loop with the results from `find /etc/sudoers.d/ /etc/sudoers -type f -print` as `FILE`
    - Start a nested `while read` loop with the results from `grep -Ei '.*ALL=\(ALL\).*NOPASSWD: ALL' "$FILE" | grep -Eiv '#|wheel' | grep -Ev '^%' | awk '{print $1}'` as `USERS`
    - Using the ADINT tool, list user privlages, log that information: `$(sudo which logger) "SUDO2ROOT --- DATE=\"$DATE\" HOST=\"$HOST\" FILE=\"$FILE\" USERS=\"$MEMBERS\""`
  - Start a `while read` loop with the results from `find /etc/sudoers.d/ /etc/sudoers -type f -print` as `FILE`
    - Start a nested `while read` loop with the results from `grep -Ei '.*ALL=\(ALL\).*NOPASSWD: ALL' "$FILE" | grep -Eiv '#|wheel' | sed 's/%//' | awk '{print $1}'` as `USERGROUP`
    - Using the ADINT tool, list user group privlages, log that information: `$(sudo which logger) "SUDO2ROOT --- DATE=\"$DATE\" HOST=\"$HOST\" FILE=\"$FILE\" GROUP=\"$USERGROUP\" MEMBERS=\"$MEMBERS\""`

## 