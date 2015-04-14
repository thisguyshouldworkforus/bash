<?php
# --------------------------------------------------------------
# Author: Alexander Snyder
# Email: info@ThisGuyShouldWorkFor.Us
#
# Description: 
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

// Create connection

// GRANT ALL PRIVILEGES ON cphulkd.* TO brutescopy@'localhost' IDENTIFIED BY 'j3PZ89!fcAk2tM5mwD';

$con = mysqli_connect("localhost","brutescopy","j3PZ89!fcAk2tM5mwD","cphulkd");

// Check connection
if (mysqli_connect_errno())
  {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
  }

$moveip = ("INSERT INTO blacklist (IP) SELECT IP FROM brutes"); //move the IPs from the 'brutes' table onto the 'blacklist'
$empty = ("TRUNCATE TABLE brutes"); //empty the brutes table

mysqli_query($con, $moveip); // do it...
mysqli_query($con, $empty); // get to da choppah!

mysqli_close($con); // goooooo!

?>
