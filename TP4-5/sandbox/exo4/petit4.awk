#! /usr/bin/awk -f 

BEGIN{previous=""}
{if($1=="AUTHOR" && previous != "AUTHOR") print $0}
{previous=$1}
END{}