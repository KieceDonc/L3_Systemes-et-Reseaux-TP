#!/bin/bash

ALLCURRENTFILES=$(find $(pwd)/ -type f)

while read currentFile; do
  ALLDOUBLONS=$(./doublons.sh $currentFile)
  while read currentDoublon; do
    if $(cmp -s $currentFile $currentDoublon);then
      echo 'fichier egaux'$currentFile $currentDoublon
    fi
  done <<< $ALLDOUBLONS
done <<< $ALLCURRENTFILES