#!/bin/bash

# --------------------------------------------------------------
# Author: Alexander Snyder
# Email: info@ThisGuyShouldWorkFor.Us
#
# Description: 
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
# Dependency: 
# --------------------------------------------------------------



# OS Type:
ver=$(cat /etc/centos-release | awk '{print $1}');
vt=$(cat /etc/centos-release | awk '{print $3}');
echo -en "\nOperating System:\n"$ver $vt"\n";

# Uptime:

# Load Average:

# Disk Usage:

# Inode Usage:

# Memory Usage:
free=$(free -m | awk 'NR==3{print $4}')
math=$(( $free / 1024 ))
if [[ $math -eq 0 ]]
	then
		echo -en "\nFree Memory:\n"$free" Megabytes\n"
	else
		echo -en "\nFree Memory:\n"$math" Gigabytes\n"

# Current Server Connections:
80=$(netstat -ntpa | grep -i established | grep ":80" | wc -l)
443=$(netstat -ntpa | grep -i established | grep ":443" | wc -l)
echo -en "\nCurrent Server Connections:\nPort 80: "$80"\nPort 443: "$443

# MySQL Processlist
