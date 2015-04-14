#!/bin/bash

# Date: April 2015
# Author: Alexander S. (info@ThisGuyShouldWorkFor.Us)
#
# https://github.com/misteralexander/bash
#
# Query running services, ask the system a few good questions and provide that information in a quick "At-A-Glance" heads-up
#
# Written for use on GoDaddy VPH2/VPH3 Linux servers
while true; do
	clear
	echo -en "\nWhat type of server is this? [DIGIT ONLY]\n\n1. cPanel\n2. Plesk\n3. Ubuntu\n4. No Panel / Simple Control Panel\n5.) Exit\n\nEnter Selection: "
	read type
	case $type in
		"1")
			while true; do
				clear
				echo -en "Here is the stuff we can do for a cPanel server\n\n1. do this\n2. do that\n3. Go Back\n4. Exit\n\nEnter Selection: ";
				read cpopt
					case $cpopt in
						"1")
							echo "Did This!"
							sleep 1
							clear
							continue
							;;
						"2")
							echo "Did That!"
							sleep 1
							clear
							continue
						;;
						"3" )
							echo "Going Back!"
							sleep 1
							clear
							break
						;;
						"4" )
							echo "Exiting..."
							sleep 1
							break 2
						;;
						*)
							echo "Invalid Input";
							sleep 1
							clear
							continue
						;;
					esac
			done
			;;
		"2")
			echo "Plesk Stuff";
			sleep 1
			clear
			continue
		;;
		"3")
			echo "Ubuntu Stuff";
			sleep 1
			clear
			continue
		;;
		"4")
			echo "No Panel / Simple Control Panel";
			sleep 1
			clear
			continue
		;;
		"5")
			echo "Exiting..."
			sleep 1
			clear
			break
		;;
		*)
			echo "Invalid Input";
			sleep 1
			clear
			continue
		;;
	esac
done
