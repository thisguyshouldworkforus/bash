#! /bin/bash
#
# Date: March 2015
# Author: Alexander S. (info@misteralexander.com)
#
# https://github.com/misteralexander/cPanelFixAll
#
# Creating a heads-up server "At-A-Glance" look
# Will (eventually) be merged with ataglance.sh (main script)

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
