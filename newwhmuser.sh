#!/bin/bash

# --------------------------------------------------------------
# Author: Alexander Snyder
# Email: info@ThisGuyShouldWorkFor.Us
# Copyright (C) 2015 Alexander Snyder
# 
# Description: Automatically create a WHM "root" user
#
# Licensing: 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Repository: 
# https://github.com/misteralexander/bash
#
# Dependency: none
# --------------------------------------------------------------

# Make sure we are the root user
if [[ $UID != 0 ]]
	then
		clear
		echo "Please elevate to the root user, and try again"
		sleep 1
		exit 1;
	else
		echo "Welcome root, lets get started"
fi

# Ask the user for the desired username
echo -n "Please enter your Jomax ID (no JOMAX\): "
read input

# Make sure our upcoming user does not already exist
exist=$(grep "99999" "/etc/passwd")
if [[ -z $exist ]]
	then
		# Add the user to the system
		useradd -u 99999 "$input"
		sleep 1
		# Change the password for the new user
		passwd "$input"
		# Give the new user full WHM "Root" perms
		echo "$input:all" >> /var/cpanel/resellers
		clear
		sleep 2
		# Remove the user
		echo "Press any key to remove the user you just made"
		read end
		while true; do
			case $end in
				*)
					clear
					echo "Removing user now"
					user=$(grep "99999" "/etc/passwd" | cut -d":" -f1)
					sed "/$user:all/d" -i /var/cpanel/resellers
					userdel -rf "$user"
					echo "Deleting myself ..."
					kill=$(find / -type f -name "newwhmuser.sh" | -exec rm -f)
					echo "$kill"
					echo "Exiting ..."
					sleep 0.5
					break
					;;
			esac
		done
	else
		echo "A conflicting UID was found, exiting ..."
		kill=$(find / -type f -name "newwhmuser.sh" | -exec rm -f)
		echo "Removing myself ..."
		echo "$kill"
		exit 1
fi

