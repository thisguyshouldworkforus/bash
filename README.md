
# ![logo](https://camo.githubusercontent.com/a7de91b915d8b286dda762e3683d9a1c961692d43f8349d020ecd54634a823cf/68747470733a2f2f63646e2e7261776769742e636f6d2f6f64622f6f6666696369616c2d626173682d6c6f676f2f6d61737465722f6173736574732f4c6f676f732f4964656e746974792f504e472f424153485f6c6f676f2d7472616e73706172656e742d62672d636f6c6f722e706e67)

A simple repo to hold scripts that I have written over the years for a variety of purposes


## License

[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)


## Delete Old Log Files
[![ ](https://img.shields.io/badge/DEPENDENCY-Requires%20Root%20Access-orange)](https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/root-account.html)

[delete_old_logs.bash](delete_old_logs.bash) is a small script to nuke log files older than 90 days.

- In this script it will:
  - Require sudo/root access to run
  - Generate a UNIX timestamp of today
  - Initiate (or append) our Log File
  - Find Old Log Files
    - Use `stat` to get the timestamp of the file, divide that by days and check to see if it is over 90 days old.  If it is, it deletes the file without prejudice `rm -f`
  - Logs the actions it has taken per file, in a `while loop`.

## Fix Splunk Forwarder
[![ ](https://img.shields.io/badge/DEPENDENCY-Requires%20Root%20Access-orange)](https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/root-account.html)

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
        - Attempts to re-register to RedHat Satellite [![ ](https://img.shields.io/badge/ALERT-Deprecated%20in%20Satellite%20v6.9-red)](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.9/html-single/release_notes/index#deprecated_functionality)
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
[![ ](https://img.shields.io/badge/DEPENDENCY-Requires%20Root%20Access-orange)](https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/root-account.html)

[lamp.sh](lamp.sh)

This is my first shell script of any real consequence.  It was written around 2012/2013 and doesn't contain any logic. Its fun to go back and see where we've been!

## Monitor Sudoers
[![ ](https://img.shields.io/badge/DEPENDENCY-Requires%20Root%20Access-orange)](https://tldp.org/LDP/lame/LAME/linux-admin-made-easy/root-account.html)

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

##