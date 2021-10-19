#! /usr/bin/awk -f 

BEGIN{FS="[\t]"}
{print $2 $1}