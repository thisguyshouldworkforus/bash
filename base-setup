#! /bin/bash
#
# Date: January 2015
# Author: Alexander S. (info@misteralexander.com)
#
# https://github.com/misteralexander/
#
#Intended to take a Minimal Install (CentOS-6.6)
#and configure a fully operational LAMP stack
#running WordPress, all without human interaction

#Step One: Configure Networking
sed 's/ONBOOT=no/ONBOOT=yes' /etc/sysconfig/network-scripts/ifcfg-eth0

#Step Two: Restart Networking
${/etc/init.d/networking restart}


#Step Three: Test Networking
${ping -c4 google.com}
