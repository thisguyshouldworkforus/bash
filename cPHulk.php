/*
Date: March 2015
Author: Alexander S. (info@misteralexander.com)

https://github.com/misteralexander/bash

On versions of WHM (up to 11.46), copy the data from the
cPHulk Brute Force table directly into the cPHulk Blacklist
*/

<?php

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
