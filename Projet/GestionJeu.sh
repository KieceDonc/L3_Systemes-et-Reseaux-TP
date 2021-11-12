#!/bin/bash

declare -i LAST_CARD_INDEX=0 # On déclare un integer. Il décrit l'index de la dernière envoyé à un joueur dans le tableau CARDS 
declare -i ROUND=1 # On déclare un integer. Il décrit le numéro du tour
CURRENT_ROUND_SORTED_CARDS=() # Liste des cartes tirer et trier pour le tour courant
declare -i CURRENT_ROUND_INDEX=0 # On déclare un integer. Il décrit l'index de la carte que l'on doit trouver pour le round courant

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

function SortCurrentRoundCards(){
  UNSORTED_CARDS_LENGTH=$(($ROUND*$NBPLAYERS-1))
  for x in $( eval echo {0..$(($ROUND*$NBPLAYERS-1))} );do
    CURRENT_MINUS=1000
    for y in $( eval echo {0..$UNSORTED_CARDS_LENGTH} );do 
      CURRENT_CARD=${CURRENT_ROUND_UNSORTED_CARDS[y]} # Carte courante de la liste des cartes non trier
      echo $CURRENT_CARD
      if [ $(($CURRENT_CARD)) -lt $(($CURRENT_MINUS)) ];then # On vérifie si la carte courante est inférieur au minimun courant
        CURRENT_MINUS=$CURRENT_CARD
      fi
    done
    CURRENT_ROUND_SORTED_CARDS+=($CURRENT_MINUS)
    CURRENT_ROUND_UNSORTED_CARDS=( ${CURRENT_ROUND_UNSORTED_CARDS[@]/$CURRENT_MINUS}) # On supprime le minimum courant des cartes non trier
    UNSORTED_CARDS_LENGTH=$(($UNSORTED_CARDS_LENGTH-1))
  done    
  echo ${CURRENT_ROUND_SORTED_CARDS[@]}
}

function SendCardsToPlayers(){
  for x in $( eval echo {0..$(($NBPLAYERS-1))} );do
    for y in $( eval echo {1..$ROUND} );do
      CURRENT_CARD=${CARDS[$LAST_CARD_INDEX]}
      $(echo $CURRENT_CARD > $x.pipe) 
      CURRENT_ROUND_UNSORTED_CARDS+=($CURRENT_CARD)
      LAST_CARD_INDEX+=1
    done
  done
  SortCurrentRoundCards
}

function ListenPipe(){
  mkfifo gestionJeu.pipe
  INCOMING_CARD=$(cat $PLAYER_ID.pipe)
  WINNING_CARD=${CURRENT_ROUND_SORTED_CARDS[CURRENT_ROUND_INDEX]}
  if [ $(($WINNING_CARD)) -eq $(($INCOMING_CARD)) ];then
    #for x in $( eval echo {0..$(($NBPLAYERS-1))} )
    #$(echo "Bravo, la carte $WINNING_CARD a été trouvés, voici les cartes trouvées : " > $x.pipe)
    #CURRENT_ROUND_INDEX+=1
  else
    for x in $( eval echo {0..$(($NBPLAYERS-1))} );do
      $(echo "Perdu, la carte $INCOMING_CARD n'était pas la bonne, la bonne était : $WINNING_CARD" > $x.pipe) 
    done
  fi

}

function removePipe(){
  rm *.pipe
}

InitAndRandomlySortCards
InitPlayers
SendCardsToPlayers
read tmp
removePipe