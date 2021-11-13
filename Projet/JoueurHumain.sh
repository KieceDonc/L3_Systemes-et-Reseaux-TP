#!/bin/bash

PLAYER_ID=$1
declare -i ROUND=1 # On déclare un integer. Il décrit le numéro du tour
CURRENT_CARDS=() # Contient les cartes du joueur
declare -i NB_CARDS # On déclare un integer. Il décrit le nombre de carte en main

function ListenCardToPlay(){
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
    if [ $NB_CARDS -eq $((0)) ];then
      echo "Vous n'avez aucune carte a joué"
    else
      if [ "$CANT_PLAY_THIS_CARD" = true ]; then # Si l'entrée est mauvaise on lui montre ces cartes 
        echo "Impossible de jouer cette carte, vos cartes sont :" ${CURRENT_CARDS[@]}
      fi
    fi
  done

  OLD_CURRENT_CARDS=CURRENT_CARDS
  CURRENT_CARDS=()
  for x in $( eval echo {0..$(($NB_CARDS))} );do
    OLD_CURRENT_CARD=$(($OLD_CURRENT_CARDS[x]));
    if [ $CARD_TOPLAY -ne $OLD_CURRENT_CARD ];then
      CURRENT_CARDS+=$OLD_CURRENT_CARD
    fi
  done
  NB_CARDS=$(($NB_CARDS-1))

  echo $CARD_TOPLAY > gestionJeu.pipe
}

function ListenPipe(){
  ListenCardToPlay
  INCOMING_DATA=$(cat $PLAYER_ID.pipe)
  SPLIT_DATA=(${INCOMING_DATA//;/ }) # https://stackoverflow.com/a/5257398
  API_CALL=SPLIT_DATA[0]
  API_MESSAGE=SPLIT_DATA[1]

  if [ $(($API_CALL)) -eq $((0)) ];then # Une carte a été reçu
      INCOMING_CARD=$(cat $PLAYER_ID.pipe)
      CURRENT_CARDS+=($INCOMING_CARD)
      NB_CARDS+=1
      ListenPipe
  elif [ $(($API_CALL)) -eq $((5)) ];then # Toutes les cartes ont été reçu
    echo "Cartes reçut ! Vos cartes : "${CURRENT_CARDS[@]}
    ListenPipe
  elif [ $(($API_CALL)) -eq $((1)) ];then # Une carte du tour courant a été trouvé
    echo $API_MESSAGE
    ListenPipe
  elif [ $(($API_CALL)) -eq $((2)) ];then # Une mauvaise carte a été trouvé, le tour recommence
    echo $API_MESSAGE
    CURRENT_CARDS=()
    ListenPipe
  elif [ $(($API_CALL)) -eq $((3)) ];then # Le tour est terminé, on passe au tour suivant
    echo $API_MESSAGE
    CURRENT_CARDS=()
    ListenPipe
  elif [ $(($API_CALL)) -eq $((4)) ];then # Le jeu est terminé
    echo $API_MESSAGE
    exit
  fi

}

echo "Vous êtes le joueur n°"$PLAYER_ID
echo "En attente de vos cartes ..."
ListenPipe