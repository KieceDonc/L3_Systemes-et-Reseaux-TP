#! /usr/bin/awk -f 

BEGIN{previous=""}
{if($1=="ATOM" && $5 != previous) print$0}
{previous=$5}
END{}