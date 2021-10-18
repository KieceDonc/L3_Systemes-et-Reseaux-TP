#!/bin/bash

for p in {A..Z};do
  $(echo $p >> $p)
  #$(rm $p.txt)
done  