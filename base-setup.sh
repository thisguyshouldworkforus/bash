#!/bin/bash

# --------------------------------------------------------------	#
# Author: Alexander Snyder											#
# Email: info@ThisGuyShouldWorkFor.Us								#
#																	#
# Description: 														#
# 																	#
# Licensing:														#
# The work contained herein, and those works referenced				#
# are free software; you can redistribute it and/or modify it under	#
# the terms of the GNU General Public License as published by the	#
# Free Software Foundation either version 3 of the License, or		#
# (at your option) any later version.								#
#																	#
# Repository: 														#
# https://github.com/misteralexander/bash							#
#																	#
# Dependency: (None)												#
# --------------------------------------------------------------	#

#Intended to take a Minimal Install (CentOS-6.6)
#and configure a fully operational LAMP stack
#running WordPress, all without human interaction

#Step One: Configure Networking
sed 's/ONBOOT=no/ONBOOT=yes' /etc/sysconfig/network-scripts/ifcfg-eth0

#Step Two: Restart Networking
${/etc/init.d/networking restart}


#Step Three: Test Networking
${ping -c4 google.com}
