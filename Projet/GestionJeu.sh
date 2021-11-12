#!/bin/bash

echo -n "Entrer le nombre de joueur : "
read NBPLAYERS

for x in $( eval echo {0..$(($NBPLAYERS-1))} );do
  xterm -e "./JoueurHumain.sh $x" &
  mkfifo $x.pipe
done

for x in $( eval echo {0..$(($NBPLAYERS-1))} );do
  echo "test pipe PLAYER_ID = "$x > $x.pipe 
done

