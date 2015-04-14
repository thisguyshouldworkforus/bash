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

# Make sure we are the root user
if [[ $UID ! -eq 0 ]]
	then
		exit 1;
	else
		echo "You must be the root user to run this script";
fi

# Make sure we're in the proper directory
if [[ -d /root/parts ]]
	then
		cd /root/parts
	else
		mkdir /root/parts && cd /root/parts
fi

# Get the file containing our functions
curl -O /root/parts/functions 