#!/bin/bash

# Make sure we are the root user
if [ $UID ! -eq 0 ]
	then
		exit 1;
	else
		echo "You must be the root user to run this script";
fi

# Make sure we're in the proper directory

# Get the file containing our functions
curl -O function https://www.dropbox.com/s/hqsek1bhbs2uk4s/ataglance.sh

if [[  ]]