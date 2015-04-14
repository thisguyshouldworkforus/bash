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



# Make sure we are the root user, if we are
# continue, if we are not, kill the script
# as we only want root running this script.
if [[ $UID ! -eq 0 ]]
	then
		exit 1;
	else
		echo "You must be the root user to run this script";
fi

# Make sure our working directory exists
# if it does, then switch to it, if not,
# then make the directory and change to it.
if [[ -d /root/att ]]
	then
		cd /root/att
	else
		mkdir /root/att && cd /root/att
fi

# Get the file containing our functions
# Kept it as a separate file strictly for
# future readability and my own sanity
wget -O /root/att/functions.sh --no-cache https://www.dropbox.com/s/4yzr1jahvg5l13n/functions.sh

source /root/att/functions.sh

