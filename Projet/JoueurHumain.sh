#!/bin/bash

PLAYER_ID=$1
CURRENT_CARDS=() # Contient les cartes du joueur
declare -i NB_CARDS=0 # On déclare un integer. Il décrit le nombre de carte en main

function ListenCardToPlay(){
  while true;do
    CANT_PLAY_THIS_CARD=true # On initialise un booléen qui va servir de drapeau pour savoir si l'entrée utilisateur est bonne

    while $CANT_PLAY_THIS_CARD;do # Tant que l'entrée utilisateur est mauvaise on répète
      read CARD_TOPLAY # On demande au joueur d'input la carte qu'il souhaite jouer, CARD_TOPLAY = Carte choisit par l'utilisateur et qui doit être jouer
    
      
      CURRENT_CARDS=()
      while read CURRENT_CARD; do
        CURRENT_CARDS+=("$CURRENT_CARD")
      done < $PLAYER_ID"_CURRENT_CARDS.tmp"
      NB_CARDS=${#CURRENT_CARDS[@]}

      if [[ $CARD_TOPLAY =~ ^-?[0-9]+$ ]];then # On regarde si l'entrée est bien un chiffre ou si il s'agit d'un message du shell / mauvaise entrée
        for x in $( eval echo {0..$NB_CARDS} );do
          CURRENT_CARD=${CURRENT_CARDS[x]};
          if [ $(($CARD_TOPLAY)) -eq $(($CURRENT_CARD)) ];then # On vérifie si la carte courante est présente dans son jeu
            CANT_PLAY_THIS_CARD=false # elle est présente
          fi
        done  
        if [ $NB_CARDS -eq $((0)) ];then
          echo "Vous n'avez aucune carte à jouer"
        elif [ "$CANT_PLAY_THIS_CARD" = true ]; then # Si l'entrée est mauvaise on lui montre ces cartes 
            echo "Impossible de jouer cette carte, vos cartes sont :" ${CURRENT_CARDS[@]}
        fi
      fi
    done

    NEW_CURRENT_CARDS=()
    for x in $( eval echo {0..$NB_CARDS} );do
      CURRENT_CARD=${CURRENT_CARDS[x]};
      if [ $(($CARD_TOPLAY)) -ne $(($CURRENT_CARD)) ];then
        NEW_CURRENT_CARDS+=($CURRENT_CARD)
      fi
    done
    NB_CARDS=$(($NB_CARDS-1))

    for CURRENT_VALUE in "${NEW_CURRENT_CARDS[@]}";do
      echo $CURRENT_VALUE
    done >$PLAYER_ID"_CURRENT_CARDS.tmp"
    NB_CARDS=${#CURRENT_CARDS[@]}

    echo $CARD_TOPLAY > gestionJeu.pipe

  done
}

function ListenPipe(){
  INCOMING_DATA=$(cat $PLAYER_ID.pipe)

  SPLIT_DATA=(${INCOMING_DATA//;/ }) # https://stackoverflow.com/a/5257398
  API_CALL=${SPLIT_DATA[0]}
  API_MESSAGE=${SPLIT_DATA[1]}

  CURRENT_CARDS=()
  while read CURRENT_CARD; do
    CURRENT_CARDS+=("$CURRENT_CARD")
  done < $PLAYER_ID"_CURRENT_CARDS.tmp"
  NB_CARDS=${#CURRENT_CARDS[@]}

  #echo ">> API_CALL "$API_CALL "API_MESSAGE "$API_MESSAGE
  if [ $(($API_CALL)) -eq $((5)) ];then # Toutes les cartes ont été reçu
    echo "Cartes reçues ! Vos cartes : "${CURRENT_CARDS[@]}
    ListenCardToPlay &
  elif [ $(($API_CALL)) -eq $((1)) ];then # Une carte du tour courant a été trouvé
    echo $(awk "NR==$API_MESSAGE" gestionJeu.tmp)
  elif [ $(($API_CALL)) -eq $((2)) ];then # Une mauvaise carte a été trouvé, le tour recommence
    echo $(awk "NR==$API_MESSAGE" gestionJeu.tmp)
    CURRENT_CARDS=()
  elif [ $(($API_CALL)) -eq $((3)) ];then # Le tour est terminé, on passe au tour suivant
    echo $(awk "NR==$API_MESSAGE" gestionJeu.tmp)
    CURRENT_CARDS=()
  elif [ $(($API_CALL)) -eq $((4)) ];then # Le jeu est terminé
    echo $(awk "NR==$API_MESSAGE" gestionJeu.tmp)
    read tmp
    exit
  fi

  for CURRENT_VALUE in "${CURRENT_CARDS[@]}";do
    echo $CURRENT_VALUE
  done > $PLAYER_ID"_CURRENT_CARDS.tmp"
  NB_CARDS=${#CURRENT_CARDS[@]}

  ListenPipe
}

echo "Vous êtes le joueur n°"$PLAYER_ID
echo "En attente de vos cartes ..."

ListenPipe 
