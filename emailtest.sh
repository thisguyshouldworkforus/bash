#!/bin/bash

# --------------------------------------------------------------
# Author: Alexander Snyder
# Email: info@ThisGuyShouldWorkFor.Us
# Copyright (C) 2015 Alexander Snyder
# 
# Description: Simple BASH Script to test email operation
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
# Dependency: None
# --------------------------------------------------------------

SUBJECT=$1  
RECEIVER=$2  
TEXT=$3  

SERVER_NAME=$HOSTNAME  
SENDER=$(whoami)  
USER="noreply"

[[ -z $1 ]] && SUBJECT="Notification from $SENDER on server $SERVER_NAME"  
[[ -z $2 ]] && RECEIVER="apsubmit@secureserver.net"   
[[ -z $3 ]] && TEXT="no text content"  

MAIL_TXT="Subject: $SUBJECT\nFrom: $SENDER\nTo: $RECEIVER\n\n$TEXT"  
echo -e $MAIL_TXT | sendmail -t  
exit $?
