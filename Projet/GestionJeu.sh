#!/bin/bash

declare -i LAST_CARD_INDEX=0 # On déclare un integer. Il décrit l'index de la dernière envoyé à un joueur dans le tableau CARDS 

function InitAndRandomlySortCards(){
  # Initialisation du tableau 
  CARDS=()

  # On ajoute les cartes de 1 à 100 au tableau
  for x in {1..100};do
    CARDS+=($x)
  done

  # On échange une carte à l'index entre 0 à 99 avec une autre carte à l'index entre 0 et 99
  for x in {1..100};do
    RANDOM0=$((RANDOM%99))
    RANDOM1=$((RANDOM%99))
    TMP=${CARDS[$RANDOM0]}
    CARDS[$RANDOM0]=${CARDS[$RANDOM1]}
    CARDS[$RANDOM1]=$TMP
  done

  #echo ${CARDS[@]}
}

function InitPlayers(){
  # On demande le nombre de joueur
  echo -n "Entrer le nombre de joueur : "
  read NBPLAYERS

  # On initialise les terminaux + pipes
  for x in $( eval echo {0..$(($NBPLAYERS-1))} );do
    xterm -e "./JoueurHumain.sh $x" & # Initialisation des terminaux en donnant en paramètre le n° du joueur
    mkfifo $x.pipe # Initialisation des pipes qui prennent le nom "n°Joueur.pipe"
  done
}

function SendCardsToPlayers(){
  for x in $( eval echo {0..$(($NBPLAYERS-1))} );do
    echo ${CARDS[$LAST_CARD_INDEX]} > $x.pipe 
    LAST_CARD_INDEX+=1
  done
}

function ListenPipe(){
  mkfifo gestionJeu.pipe
}

function removePipe(){
  rm *.pipe
}

InitAndRandomlySortCards
InitPlayers
SendCardsToPlayers
read tmp
removePipe