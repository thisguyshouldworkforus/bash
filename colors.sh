#!/bin/bash

# --------------------------------------------------------------
# Author: Alexander Snyder
# Email: info@ThisGuyShouldWorkFor.Us
#
# Description: establishing colors to use in scripts!
# Source: http://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
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

black=$('\033[0;30m')
dgray=$('\033[1;30m')
blue=$('\033[0;34m')
lblue=$('\033[1;34m')
green=$('\033[0;32m')
lgreen=$('\033[1;32m')
cyan=$('\033[0;36m')
lcyan=$('\033[1;36m')
red=$('\033[0;31m')
lred=$('\033[1;31m')
purple=$('\033[0;35m')
lpurple=$('\033[1;35m')
brown=$('\033[0;33m')
yellow=$('\033[1;33m')
lgray=$('\033[0;37m')
white=$('\033[1;37m')
norm=$('\033[0m')

echo $red"Hello World"$norm
