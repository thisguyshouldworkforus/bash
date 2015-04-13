#! /bin/bash
#
# Date: March 2015
# Author: Alexander S. (info@misteralexander.com)
#
# https://github.com/misteralexander/bash
#
# Fix YUM, fixing some of the most common cPanel error on a new server
# Written for use on GoDaddy VPH3 (Vertigo) servers

#In case someone has removed the 32-bit version of zlib, here is how you can get it back
zlib=$(rpm -qa | grep zlib | grep i686)
if [[ -z $zlib ]]
	then wget http://mirror.centos.org/centos/6/os/i386/Packages/zlib-1.2.3-29.el6.i686.rpm && rpm -i zlib-1.2.3-29.el6.i686.rpm
	else
		echo -r "You already have the 32-bit version of zlib, which is required by several packages\n\n"
fi

# If someone complains about an EasyApache Failure, its likely due to a multilib error
ea=$(egrep -wi --color 'Protected multilib versions' /usr/local/cpanel/logs/easy/apache/* | awk 'NR==1{print $7}')
if [[ -z "$ea" ]]
	then
		echo -e "Protected Multilib Version Error Not Found\n\n"
	else
		fixmultilib=$(rpm -e --nodeps --justdb $ea)
		echo -e "Protected Multilib Version Error Found\nWe are fixing it now\n\n"
		echo "$fixmultilib"
fi

# Update our repositories to make sure we are listen to all channels
updaterepo=$(sed 's/#baseurl/baseurl/g' -i /etc/yum.repos.d/CentOS-Base.repo; sed -r 's/gpgcheck=1/gpgcheck=1\nenabled=1/g' -i /etc/yum.repos.d/CentOS-Base.repo; sed '/enabled=0/d' -i /etc/yum.repos.d/CentOS-Base.repo; echo "skip_broken=1" >> /etc/yum.conf);

# Flush the cache, we want to make sure we have the latest package listen
flushcache=$(yum clean all)

# Determine the last time YUM was updated and store that YMD string in the variable
yumupdate=$(yum history | grep -i update | grep -v conf | grep `date +%Y` | awk 'NR==1{print $6; exit}')

# Update the system
updatenow=$(yum update)

# Determine if the variable has anything stored in it.
if [[ ! -z $yumupdate ]]
	then
# If its not empty then it converts that YMD value into a UNIX epoch time-stamp
		echo -e "The last system update was\n"$yumupdate
		lastupdate=$(date +%s -d $yumupdate)
# Find out what the UNIX epoch time-stamp is for RIGHT Now
		today=$(date +%s)
# Evaluate the expression, subtract today from the last update, find out how long its been
		count=$(expr $today - $lastupdate)
# If its been more than a week, then it calls for an update, otherwise, we're fine.
			if [[ $count -gt 604800 ]]
				then
# If its been more than a week since we updated, lets get updated
					echo "Its been more than a week since we updated, lets do that now"
# Update our repositories to make sure we are listen to all channels
					echo -e "Updating the repository list now\n\n"
					echo "$updaterepo"
# Since we opened up new channels, lets flush all of our old information
					echo -e "Flushing the cache, to get a new list of the available repository packages\n\n"
					echo "$flushcache"
# Since its been more than a week, lets update the system
					echo -e "Updating the system now\n\n"
					echo "$updatenow"
				else
					echo "Its been less than a week since the last update, we're fine."
			fi
	else
		echo -e "YUM has never updated the system! So lets do that now!\n\n"
		sleep 5;
		echo -e "Flushing the cache, to get a new list of the available repository packages\n\n"
		echo "$flushcache"
		echo -e "Updating the system now\n\n"
		echo "$updatenow"
fi
# Update WHM, ensure we are on the most recent major/minor version (11.48)
ver=$(cat /usr/local/cpanel/version | cut -b4,5)
while [[ $ver -lt 48 ]] do
	/scripts/upcp --force;
done