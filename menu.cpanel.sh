#!/bin/bash

# --------------------------------------------------------------
# Author: Alexander Snyder
# Email: info@ThisGuyShouldWorkFor.Us
#
# Description: cPanel menu
#
# Licensing: 
# The work contained herein, and those works referenced
# are free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the
# Free Software Foundation either version 3 of the License, or
# (at your option) any later version.
#
# Repository: 
# https://github.com/misteralexander/bash
#
# Dependency: 
# --------------------------------------------------------------

function menu.cp() {
clear
echo -en "\t+--------------------------------+\n";
echo -en "\t\t+  cPanel Server  +\n";
echo -en "\t+--------------------------------+\n";
echo -en "1.) Check for EasyApache Error\n"
echo -en "2.) Check for zlib (32-bit version required for many packages)\n"
echo -en "3.) Enable \"Updates\", \"Extras\", and \"Plus\" Repositories\n"
echo -en "4.) Flush the YUM cache\n"
echo -en "5.) Update the system (YUM Update)\n"
echo -en "6.) Check the history file\n"
echo -en "7.) Exit\n\n"
echo -en "Enter Selection: \n\n"
}
menu.cp