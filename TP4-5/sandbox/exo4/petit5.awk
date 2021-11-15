#! /usr/bin/awk -f 

BEGIN{}
{tab[$3]+=1;}
END{print tab["N"],"\n"print tab["C"],"\n"print tab["O"]}