#! /usr/bin/awk -f 

BEGIN{NB0=0;NBN=0;NBC=0;}
/O/{if($3=="O")NB0+=1;}
/N/{if($3=="N")NBN+=1;}
/C/{if($3=="C")NBC+=1;}
END{print "O="NB0,"\nN="NBN,"\nC="NBC}