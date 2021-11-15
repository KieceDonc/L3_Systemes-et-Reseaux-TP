#! /usr/bin/awk -f 

BEGIN{sum=0}
{sum+=NF;print NR, $0}
END{print sum, sum/(NR)}