#!/bin/bash

ROBOT_ID=$1
CURRENT_CARDS=() # Contient les cartes du joueur
declare -i NB_CARDS=0 # On déclare un integer. Il décrit le nombre de carte en main
SmallestCard=0
LAST_FOUNDED_CARD=0

function removeCard(){
  TO_REMOVE=$1
  NB_CARDS=$((${#CURRENT_CARDS[@]}))
  TMP=()
  for x in $( eval echo {0..$(($NB_CARDS-1))} );do
    TMP+=(${CURRENT_CARDS[x]})
  done

  # On retire la valeur à l'index voulu
  CURRENT_CARDS=()
  for x in $( eval echo {0..$(($NB_CARDS-1))} );do
    if [ $((${TMP[x]})) -ne $(($TO_REMOVE)) ];then
      CURRENT_CARDS+=(${TMP[x]})
    fi
  done
  NB_CARDS=$((${#CURRENT_CARDS[@]}))
  echo "Vos cartes ${CURRENT_CARDS[@]}"
}

function getSmallestCard(){
 # On trie les cartes que les joueurs doivent trouver
  SMALLEST_CARD=1000
  NB_CARDS=$((${#CURRENT_CARDS[@]}))
  for x in $( eval echo {0..$(($NB_CARDS-1))} );do
    CURRENT_CARD=${CURRENT_CARDS[x]}
    if [ $(($CURRENT_CARD)) -lt $(($SMALLEST_CARD)) ];then # On vérifie si la carte courante est inférieur au minimun courant
      SMALLEST_CARD=$CURRENT_CARD
    fi
  done    
}

function triggerShouldSendCard(){
  if [ $(($NB_CARDS)) -gt $((0)) ];then
    LAST_FOUNDED_CARD=$1
    getSmallestCard
    CURRENT_DISTANCE=$(($SMALLEST_CARD-$LAST_FOUNDED_CARD))
    RANDOM0=$((RANDOM%5+4))
    (sleep $RANDOM0; echo '9;'$CURRENT_DISTANCE> $ROBOT_ID.pipe) & 
  fi
}

function ListenPipe(){
  INCOMING_DATA=$(cat $ROBOT_ID.pipe)

  SPLIT_DATA=(${INCOMING_DATA//;/ }) # https://stackoverflow.com/a/5257398
  API_CALL=${SPLIT_DATA[0]}
  API_MESSAGE=${SPLIT_DATA[1]}

  if [ $(($API_CALL)) -eq $((0)) ];then # Une carte a été reçu
    CURRENT_CARDS+=($API_MESSAGE)
    NB_CARDS+=1
  elif [ $(($API_CALL)) -eq $((1)) ];then # Une carte du tour courant a été trouvé
    triggerShouldSendCard $API_MESSAGE
  elif [ $(($API_CALL)) -eq $((5)) ];then # Toutes les cartes ont été reçu
    echo "Cartes reçues ! Vos cartes : "${CURRENT_CARDS[@]}
    triggerShouldSendCard $API_MESSAGE
  elif [ $(($API_CALL)) -eq $((2)) ];then # Une mauvaise carte a été trouvé, le tour recommence
    CURRENT_CARDS=()
    LAST_FOUNDED_CARD=999
  elif [ $(($API_CALL)) -eq $((3)) ];then # Le tour est terminé, on passe au tour suivant
    CURRENT_CARDS=()
    LAST_FOUNDED_CARD=999
  elif [ $(($API_CALL)) -eq $((4)) ];then # Le jeu est terminé
    exit
  elif [ $(($API_CALL)) -eq $((9)) ];then
      RECEIVED_DISTANCE=$API_MESSAGE  
      getSmallestCard
      CURRENT_DISTANCE_2=$(($SMALLEST_CARD-$LAST_FOUNDED_CARD))

    if [ $(($RECEIVED_DISTANCE)) -eq $(($CURRENT_DISTANCE_2)) ];then # On vérifie si la distance n'a pas changé ( que aucune carte n'a été joué entre temps )
      # On joue la carte 
      echo $SMALLEST_CARD > gestionJeu.pipe
      echo "La carte $SMALLEST_CARD a été jouer"
      removeCard $SMALLEST_CARD
    fi
  fi

  ListenPipe
}

echo "Vous êtes le robot n°"$ROBOT_ID
echo "En attente de vos cartes ..."

ListenPipe 
