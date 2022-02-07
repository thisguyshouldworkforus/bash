
# ![logo](https://camo.githubusercontent.com/a7de91b915d8b286dda762e3683d9a1c961692d43f8349d020ecd54634a823cf/68747470733a2f2f63646e2e7261776769742e636f6d2f6f64622f6f6666696369616c2d626173682d6c6f676f2f6d61737465722f6173736574732f4c6f676f732f4964656e746974792f504e472f424153485f6c6f676f2d7472616e73706172656e742d62672d636f6c6f722e706e67)

A simple repo to hold scripts that I have written over the years for a variety of purposes


## License

[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)


## Delete Old Log Files
[delete_old_logs.bash](delete_old_logs.bash) is a small script to nuke log files older than 90 days.

- In this script it will:
  - Require sudo/root access to run
  - Generate a UNIX timestamp of today
  - Initiate (or append) our Log File
  - Find Old Log Files
    - Use `stat` to get the timestamp of the file, divide that by days and check to see if it is over 90 days old.  If it is, it deletes the file without prejudice `rm -f`
  - Logs the actions it has taken per file, in a `while loop`.

## Fix Splunk Forwarder
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
        - Attempts to re-register to RedHat Satellite (this workflow was deprecated in v6.9)
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

