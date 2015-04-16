#!/bin/bash

# --------------------------------------------------------------
# Author: Alexander Snyder
# Email: info@ThisGuyShouldWorkFor.Us
# Copyright (C) 2015 Alexander Snyder
# 
# Description: 
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
# Dependency: 
# --------------------------------------------------------------





#Intended to take a Minimal Install (CentOS-6.6)
#and configure a fully operational LAMP stack
#running WordPress, all without human interaction

#Step One: Configure Networking
sed 's/ONBOOT=no/ONBOOT=yes' /etc/sysconfig/network-scripts/ifcfg-eth0

#Step Two: Restart Networking
${/etc/init.d/networking restart}


#Step Three: Test Networking
${ping -c4 google.com}
