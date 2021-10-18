#!/bin/bash

FCHNOM=$1
FCHPDF=$2

while read line;
do
	DIR=$(echo $line | tr -d ' '| tr [:lower:] [:upper:])
	mkdir $DIR
	cp $FCHPDF $DIR
	LISTDIR=$DIR $LISTDR
done <$1
