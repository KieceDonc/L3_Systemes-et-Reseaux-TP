#!/bin/bash

PLAYER_ID=$1
declare -i ROUND=1 # On déclare un integer. Il décrit le numéro du tour

function askCardToPlay(){
  CANT_PLAY_THIS_CARD=true # On initialise un booléen qui va servir de drapeau pour savoir si l'entrée utilisateur est bonne
  while $CANT_PLAY_THIS_CARD # Tant que l'entrée utilisateur est mauvaise on répète
  do
    echo -n "Entrer la carte que vous souhaiter jouer : "
    read CARD_TOPLAY # On demande au joueur d'input la carte qu'il souhaite jouer, CARD_TOPLAY = Carte choisit par l'utilisateur et qui doit être jouer
    for CURRENT_CARD in "${CURRENT_CARDS[@]}";do # On vérifie si elle est présente dans son jeu parmit toutes ses cartes
      if [ $CARD_TOPLAY -eq $CURRENT_CARD ];then # On vérifie si la carte courante est présente dans son jeu
        CANT_PLAY_THIS_CARD=false # elle est présente
      fi
    done  
    if [ "$CANT_PLAY_THIS_CARD" = true ]; then # Si l'entrée est mauvaise on lui montre ces cartes 
      echo "Impossible de jouer cette, vos cartes sont :" ${CURRENT_CARDS[@]}
    fi
  done
}

function waitForCards(){
  CURRENT_CARDS=() # Contient les cartes du joueur
  for x in $( eval echo {1..$(($ROUND))} );do
    INCOMING_CARD=$(cat $PLAYER_ID.pipe)
    CURRENT_CARDS+=($INCOMING_CARD)
  done
  echo "Cartes reçut ! Vos cartes : "${CURRENT_CARDS[@]} 
}

echo "Vous êtes le joueur n°"$PLAYER_ID
echo "En attente de vos cartes ..."
waitForCards
askCardToPlay