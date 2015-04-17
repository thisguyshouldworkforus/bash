#!/bin/bash

# --------------------------------------------------------------
# Author: Alexander Snyder
# Email: info@ThisGuyShouldWorkFor.Us
# Copyright (C) 2015 Alexander Snyder
# 
# Description: Script to review a mail queue and try to help
# -- If there is a SPAM compromise.
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



function postfix() {
POSTCOUNT=$(postqueue -p | tail -n 1 | cut -d' ' -f5)

service postfix stop #tkemp 05.31.2014
# Putting information into the output file that Postfix is installed
echo -e "\nPostfix is installed\nGetting Postfix Queue Information\n" | tee -a "/root/spam_proof.$(date +%F).txt"

# Making a backup of one hundered emails to /root/mailbackup
echo -e "\nMaking backups of 100 emails currently in the queue.\n"|tee -a "/root/spam_proof.$(date +%F).txt"

# Creating the directory /root/mailbackup
mkdir -p "/root/mailbackup"

# Getting a list of one hundred emails in the customer and putting them in files with the queue id in /root/mailbackup
for e in $(postqueue -p 2>/dev/null|egrep "[A-Z0-9]{11,}" | awk '{print $1}' | tr -d "*" | egrep -v "[:punct:]" | head -n 100); do
	postcat -q $e > "/root/mailbackup/$e"
done

# Parsing the backed up emails to find the top ten addresses sending email
echo -e "\nFinding the top ten senders in the backed up email\n" | tee -a "/root/spam_proof.$(date +%F).txt"
cat "/root/mailbackup/*" | grep "sender:" | awk '{print $2}' | sort | uniq -c | sort -r | head -n 10 | tee -a "/root/spam_proof.$(date +%F).txt"

# Parsing the backed up emails to find the top ten scripts sending email if applicable
echo -e "\nLooking for scripts sending email\n" | tee -a "/root/spam_proof.$(date +%F).txt"
cat "/root/mailbackup/*" | grep "X-PHP-Originating-Script:" | awk '{print $2}' | sort | uniq -c | sort -r | head -n 10 | tee -a "/root/spam_proof.$(date +%F).txt"

# Parsing the backed up emails to find the top ten subjects of email being sent
echo -e "\nGetting the top ten subjects\n" | tee -a "/root/spam_proof.$(date +%F).txt"
cat "/root/mailbackup/*" | grep "Subject:" | sort | uniq -c | sort -r | head -n 10 | tee -a "/root/spam_proof.$(date +%F).txt"

# Getting the number of emails currently in the queue
echo -e "\nCounting the email in the queue. This may take a while.\n" | tee -a "/root/spam_proof.$(date +%F).txt"



echo -e "\nNumber of emails in the queue:\t$(echo $POSTCOUNT)" | tee -a "/root/spam_proof.$(date +%F).txt"

# End of Postfix section
}

function qmail() {
QCOUNT=$(/var/qmail/bin/qmail-qstat)

service qmail stop #added by tkemp 05.31.2014

# If Qmail is installed starting to gather information
echo -e "\nQmail is installed\nGetting Qmail Queue Information\n" | tee -a "/root/spam_proof.$(date +%F).txt"

# Making a backup of one hundred emails on the server
echo -e "\nMaking backups of 100 emails currently in the queue.\n" | tee -a "/root/spam_proof.$(date +%F).txt"

# Creating the directory /root/mailbackup
mkdir -p "/root/mailbackup"

# Getting a list of one hundred emails in the customer and putting them in files with the queue id in /root/mailbackup
for e in $(/var/qmail/bin/qmail-qread 2>/dev/null | egrep "#" | awk '{print $6}' | tr -d "[:punct:]" | head -n 100); do
	find "/var/qmail/queue" -name $e | xargs cat > "/root/mailbackup/$e"
done

# Parsing the email logs to find the top ten addresses sending email
echo -e "\nFinding the top ten senders from the logs\n" | tee -a "/root/spam_proof.$(date +%F).txt"
grep qmail-remote-handlers "/usr/local/psa/var/log/maillog" | awk '/from/ {print $6}' | cut -d"=" -f2 | sort | uniq -c | egrep "@" | sort -n | tail -n 10 | tee -a "/root/spam_proof.$(date +%F).txt"

# Finding out of the email is being generated - From Apache - A specific user - Or by logging into the server
echo -e "\nChecking to see if the email is coming from a network connection or from Apache\n" | tee -a "/root/spam_proof.$(date +%F).txt"
for f in $(ls /root/mailbackup/); do
	cat "/root/mailbackup/$f" | head -n 1 | awk '{print $7}' | tr -d "[:punct:]"
done | sort | uniq -c | sort | head -n 5 | tee -a "/root/spam_proof.$(date +%F).txt"

# Parsing the backed up emails to find the top ten addresses sending email
echo -e "\nGetting the top ten subjects\n" | tee -a "/root/spam_proof.$(date +%F).txt"
for f in $(ls /root/mailbackup/); do
	cat "/root/mailbackup/$f" | head -n 5 | tail -n 1
done | sort | uniq -c | sort | tail -n 5 | tee -a "/root/spam_proof.$(date +%F).txt"

# Getting the number of emails currently in the queue
echo -e "\nCounting the email in the queue. This may take a while.\n" | tee -a "/root/spam_proof.$(date +%F).txt"
echo -e "\nNumber of emails in the queue:\n$(echo $QCOUNT)" | tee -a "/root/spam_proof.$(date +%F).txt"
}

# Setting the variable to be used as the date in output file name
DATE=$(date)

# Suggesting the script is run in a screen so other
# things can be done at the same time in the ssh session
echo "You may want to run this script in a screen. If you are not running in a screen please exit the script in the next five seconds and run it in a screen."
# Pausing for five seconds to allow exiting of script to run in screen if not already doing so
sleep 5
# Telling you not to restart as all of the information in the output file will be deleted
echo "Do not stop and restart this script as all the old file contents will be removed if you do so."
# Creating the output file
echo $DATE > /root/spam_proof.$(date +%F).txt
# Checking to see if Postfix is installed on the server

postfix=$(ls /etc/init.d | egrep -q postfix)
if [[ -z ${postfix} ]]
# If postfix is installed starting to gather information
	then
		qmail
	else
		postfix
fi
