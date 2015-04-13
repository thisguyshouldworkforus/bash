#! /bin/bash
#
# Date: April 2015
# Author: Alexander S. (info@ThisGuyShouldWorkFor.Us)
#
# https://github.com/misteralexander/bash
#
# Query running services, ask the system a few good questions and provide that information in a quick "At-A-Glance" heads-up
#
# Written for use on GoDaddy VPH2/VPH3 Linux servers
while true; do
	echo -en "\nWhat type of server is this? [DIGIT ONLY]\n\n1. cPanel\n2. Plesk\n3. Ubuntu\n4. No Panel / Simple Control Panel\n\nEnter Selection: "
	read type
	case $type in
		"1")
			while true; do
				echo -en "Here is the stuff we can do for a cPanel server\n\n1. do this\n2. do that\n3. Go Back\n\nEnter Selection: ";
				read cpopt
					case $cpopt in
						"1")
							echo "sub1"
							break
							;;
						"2")
							echo "sub2"
							break
						;;
						"3" )
							echo "Going Back"
							break 2
						;;
					esac
			done
			;;
		"2")
			echo "Plesk Stuff";
			break
		;;
		"3")
			echo "Ubuntu Stuff";
			break
		;;
		"4")
			echo "No Panel / Simple Control Panel";
			break
		;;
		*)
			echo "Invalid Input";
			break
		;;
	esac
done
