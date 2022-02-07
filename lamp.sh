#!/bin/bash

# --------------------------------------------------------------
# Date:
# Circa 2012/2013
# --------------------------------------------------------------

# Very first script

###########################################
# Fresh Install of CentOS 6 - Making LAMP #
###########################################

if [ "$UID" != "0" ];
	then echo 'Only ROOT may run this script.';
		exit 1;
fi

#############################
# Configure CentOS iptables #
#############################

	# Flush the current configuration
		iptables -F

	# Accept all traffic from LOCALHOST
		iptables -A INPUT -i lo -j ACCEPT

	# Allow existing traffic to remain
		iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

	# Allow FTP Connections (Data)
		iptables -A INPUT -p udp --dport 20 -j ACCEPT

	# Allow FTP Connections (Info)
		iptables -A INPUT -p tcp --dport 21 -j ACCEPT

	# Allow SSH Connections
		iptables -A INPUT -p tcp --dport 22 -j ACCEPT

	# Allow all inbound traffic on port 80
		iptables -A INPUT -p tcp --dport 80 -j ACCEPT

	# Allow all inbound HTTPS traffic
		iptables -A INPUT -p tcp --dport 443 -j ACCEPT

	# Allow all MYSQL inbound traffic
		iptables -A INPUT -p tcp --dport 3306 -j ACCEPT

	# Set the standard 'Deny All' Policy if a packet does not meet our rules
		iptables -P INPUT DROP
		iptables -P FORWARD DROP

	# Accept all outbound traffic
		iptables -P OUTPUT ACCEPT

	# Save the configuration
		/sbin/service iptables save

	# List all the rules
		iptables -L -v

################################################
# Install RPMforge Repository (for phpMyAdmin) #
################################################

#	Install The GPG Key

		rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt

#	Download The RPM (x86_64)

		wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm

#	Verify The RPM Package

		rpm -K rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm

#	Install The Package

		rpm -i rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm

################################################
# Install the EPEL Repository (for php-mcrypt) #
################################################

#	Import the GPG Key

		rpm --import http://download.fedora.redhat.com/pub/epel/RPM-GPG-KEY-EPEL-6

#	Get The Package

		wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-5.noarch.rpm

#	Verify the RPM Package

		rpm -K epel-release-6-5.noarch.rpm

#	Install The Package

		rpm -i epel-release-6-5.noarch.rpm

##########################################
# Install Apache, MySQL, PHP, phpMyAdmin #
##########################################

	yum install -y httpd
	yum install -y mysql-server
	yum install -y mysql
		# once rebooted, and the MySQL Server is running (/etc/init.d/mysqld start) run mysql_secure_installation --follow prompts
	yum install -y php
	yum install -y php-xml
	yum install -y php-common
	yum install -y php-mcrypt
	yum install -y phpmyadmin
		# phpMyAdmin files are going to be stored in /usr/share/phpmyadmin & /etc/httpd/conf.d/phpmyadmin
		# edit /etc/httpd/conf.d/phpmyadmin.conf to "Allow From 70.162.15.219 (( public IP of your box ))"
		# edit /etc/httpd/conf.d/phpmyadmin.conf to "Allow From 50.56.237.68 (( public IP of your server ))"
		# add "Blowfish" key to /usr/share/phpmyadmin/config.inc.php

#####################################################
# Install ZIP & UNZIP (for extraction of Wordpress) #
#####################################################

	yum install -y zip
	yum install -y unzip

##############
# Update YUM #
##############

	yum update -y

########################################
# Change Ownership Of WWW & Set Perms  #
########################################

	chown apache:apache /var/www/html -R
	chmod 744 /var/www/html -R

###########################################
# Change Ownership phpMyAdmin & Set Perms #
###########################################

	chown apache:apache /usr/share/phpmyadmin -R
	chmod 744 /usr/share/phpmyadmin -R

##############################################
# Set The Run Level Of Apache & MySQL Server #
##############################################

	/sbin/chkconfig --levels 235 httpd on
	/sbin/chkconfig --levels 235 mysqld on

#################
# Get Wordpress #
#################

	wget http://www.wordpress.org/latest.zip
	unzip latest.zip
	cp -rf wordpress /var/www/html
	chown apache:apache /var/www/html/wordpress -R
	chmod 744 /var/www/html/wordpress -R

#####################
# Reboot The Server #
#####################

	reboot
