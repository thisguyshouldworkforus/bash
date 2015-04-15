#!/bin/bash

# --------------------------------------------------------------
# Author: Alexander Snyder
# Email: info@ThisGuyShouldWorkFor.Us
#
# Description: Server "At A Glance" for cPanel systems
#
# Licensing: 
# The work contained herein, and those works referenced
# are free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the
# Free Software Foundation either version 3 of the License, or
# (at your option) any later version.
#
# Repository: 
# https://github.com/misteralexander/bash
#
# Dependency: None
# --------------------------------------------------------------

function cpanel.ataglance() {

# OS Type:
ver=$(cat /etc/centos-release | awk '{print $1}');
vt=$(cat /etc/centos-release | awk '{print $3}');
echo -en "\nOperating System:\n"$ver $vt"\n\n";

# Uptime:
up=$(uptime | awk '{print $3}')
echo -en "Uptime:\n"$up" days\n\n"

# Load Average:
load=$(uptime | awk '{print $10 $11 $12}')
echo -en "Load Average (1, 5, 15):\n"$load"\n\n"

# Disk Usage:
disk=$(df -h | awk 'NR==2{print $2}')
avail=$(df -h | awk 'NR==2{print $4}')
echo -en "Disk Size:\n"$disk"\n\n"
echo -en "Available Disk:\n"$avail"\n\n"

# Inode Usage:
inode=$(df -ih | awk 'NR==2{print $5}')
echo -en "Inode Usage:\n"$inode"\n\n"

# Memory Usage:
free=$(free -m | awk 'NR==3{print $4}')
math=$(( $free / 1024 ))
if [[ $math -eq 0 ]]
	then
		echo -en "Free Memory:\n"$free" Megabytes\n"
	else
		echo -en "Free Memory:\n"$math" Gigabyte(s)\n\n"
fi

# Current Server Connections:
http=$(netstat -ntpa | grep -i established | grep ":80" | wc -l)
https=$(netstat -ntpa | grep -i established | grep ":443" | wc -l)
echo -en "Current Server Connections:\nPort 80: "$http"\nPort 443: "$https"\n\n"

# MySQL Processlist
db=$(mysql -uroot -Bse "SELECT * FROM information_schema.processlist;" | grep -v SELECT | grep -v Sleep | awk '{print $1}' | uniq | wc -l)
echo -e "ACTIVE MySQL Processes (not counting our query or sleeping):\n"$db"\n\n"
}