#!/bin/bash

FICH=$1;
NAME=$(basename $FICH)
while read line;do
  if [ $(basename $line) = $NAME ];then
    if [ $(dirname $line) != $(dirname $FICH) ];then
      echo $line
    fi
  fi
done < './liste'
