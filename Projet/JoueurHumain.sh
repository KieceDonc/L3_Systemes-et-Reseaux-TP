#!/bin/bash

PLAYER_ID=$1
declare -i ROUND=1 # On déclare un integer. Il décrit le numéro du tour
CURRENT_CARDS=() # Contient les cartes du joueur
declare -i NB_CARDS=-1 # On déclare un integer. Il décrit le nombre de carte en main

function ListenCardToPlay(){
  CANT_PLAY_THIS_CARD=true # On initialise un booléen qui va servir de drapeau pour savoir si l'entrée utilisateur est bonne
  while $CANT_PLAY_THIS_CARD;do # Tant que l'entrée utilisateur est mauvaise on répète
    read CARD_TOPLAY # On demande au joueur d'input la carte qu'il souhaite jouer, CARD_TOPLAY = Carte choisit par l'utilisateur et qui doit être jouer
    
    if [[ $CARD_TOPLAY =~ ^-?[0-9]+$ ]];then # On regarde si l'entrée est bien un chiffre ou si il s'agit d'un message du shell / mauvaise entrée
      echo "9;test" > $PLAYER_ID.pipe
      for CURRENT_CARD in "${CURRENT_CARDS[@]}";do # On vérifie si elle est présente dans son jeu parmit toutes ses cartes
        if [ $CARD_TOPLAY -eq $CURRENT_CARD ];then # On vérifie si la carte courante est présente dans son jeu
          CANT_PLAY_THIS_CARD=false # elle est présente
        fi
      done  
      if [ $NB_CARDS -eq $((0)) ];then
        echo "Vous n'avez aucune carte a joué"
      elif [ "$CANT_PLAY_THIS_CARD" = true ]; then # Si l'entrée est mauvaise on lui montre ces cartes 
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
  INCOMING_DATA=$(cat $PLAYER_ID.pipe)
  SPLIT_DATA=(${INCOMING_DATA//;/ }) # https://stackoverflow.com/a/5257398
  API_CALL=${SPLIT_DATA[0]}
  API_MESSAGE=${SPLIT_DATA[1]}
  echo "API_CALL "$API_CALL
  echo "API_MESSAGE "$API_MESSAGE
  if [ $(($API_CALL)) -eq $((0)) ];then # Une carte a été reçu
      CURRENT_CARDS+=($API_MESSAGE)
      NB_CARDS+=1
  elif [ $(($API_CALL)) -eq $((5)) ];then # Toutes les cartes ont été reçu
    echo "Cartes reçut ! Vos cartes : "${CURRENT_CARDS[@]}
  elif [ $(($API_CALL)) -eq $((1)) ];then # Une carte du tour courant a été trouvé
    echo $API_MESSAGE
  elif [ $(($API_CALL)) -eq $((2)) ];then # Une mauvaise carte a été trouvé, le tour recommence
    echo $API_MESSAGE
    CURRENT_CARDS=()
  elif [ $(($API_CALL)) -eq $((3)) ];then # Le tour est terminé, on passe au tour suivant
    echo $API_MESSAGE
    CURRENT_CARDS=()
  elif [ $(($API_CALL)) -eq $((4)) ];then # Le jeu est terminé
    echo $API_MESSAGE
    exit
  elif [ $(($API_CALL)) -eq $((9)) ];then # Le jeu est terminé
    echo $API_MESSAGE
  fi
  ListenPipe &  
}

echo "Vous êtes le joueur n°"$PLAYER_ID
echo "En attente de vos cartes ..."
ListenPipe &
ListenCardToPlay 