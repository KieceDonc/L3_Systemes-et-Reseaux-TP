#!/bin/bash

PLAYER_ID=$1
CURRENT_CARDS=() # Contient les cartes du joueur
declare -i NB_CARDS=0 # On déclare un integer. Il décrit le nombre de carte en main

function setCards(){
  # On enregistre les cartes du joueur courant dans son fichier tmp associé
  for CURRENT_VALUE in "${CURRENT_CARDS[@]}";do
    echo $CURRENT_VALUE
  done > $PLAYER_ID"_CURRENT_CARDS.tmp"
  NB_CARDS=${#CURRENT_CARDS[@]}
}

function getCards(){
  # On récupère les cartes du joueur courant dans son fichier tmp associé
  CURRENT_CARDS=()
  while read CURRENT_CARD; do 
    CURRENT_CARDS+=("$CURRENT_CARD")
  done < $PLAYER_ID"_CURRENT_CARDS.tmp"
  NB_CARDS=${#CURRENT_CARDS[@]}
}

function ListenCardToPlay(){
  while true;do
    CANT_PLAY_THIS_CARD=true # On initialise un booléen qui va servir de drapeau pour savoir si l'entrée utilisateur est bonne

    while $CANT_PLAY_THIS_CARD;do # Tant que l'entrée utilisateur est mauvaise on répète
      read CARD_TOPLAY # On demande au joueur d'input la carte qu'il souhaite jouer, CARD_TOPLAY = Carte choisit par l'utilisateur et qui doit être joué
    
      getCards

      # On regarde si l'entrée est bien un chiffre ou si il s'agit d'un message du shell / mauvaise entrée
      if [[ $CARD_TOPLAY =~ ^-?[0-9]+$ ]];then
        for x in $( eval echo {0..$NB_CARDS} );do
          CURRENT_CARD=${CURRENT_CARDS[x]};
          
          # On vérifie si la carte courante est présente dans son jeu
          if [ $(($CARD_TOPLAY)) -eq $(($CURRENT_CARD)) ];then 
            CANT_PLAY_THIS_CARD=false # elle est présente
          fi

        done  

        # On regarde si le joueur a bien des cartes et si il peut la jouée
        if [ $NB_CARDS -eq $((0)) ];then
          echo "Vous n'avez aucune carte à jouer"
        elif [ "$CANT_PLAY_THIS_CARD" = true ]; then # Si l'entrée est mauvaise on lui montre ces cartes 
            echo "Impossible de jouer cette carte, vos cartes sont :" ${CURRENT_CARDS[@]}
        fi

      fi
    done

    # On supprime la carte jouée par l'utilisateur
    NEW_CURRENT_CARDS=()
    for x in $( eval echo {0..$NB_CARDS} );do
      CURRENT_CARD=${CURRENT_CARDS[x]};
      if [ $(($CARD_TOPLAY)) -ne $(($CURRENT_CARD)) ];then
        NEW_CURRENT_CARDS+=($CURRENT_CARD)
      fi
    done
    CURRENT_CARDS=()
    CURRENT_CARDS=(${NEW_CURRENT_CARDS[@]})

    setCards

    # On envoie la carte jouée à GestionJeu
    echo $CARD_TOPLAY > gestionJeu.pipe
  done
}

function ListenPipe(){
  # On récupère les données qui arrive au travers du pipe
  INCOMING_DATA=$(cat $PLAYER_ID.pipe)

  # On récupère l'id et le message de l'action
  API_CALL=${INCOMING_DATA:0:1}
  API_MESSAGE=${INCOMING_DATA:2}

  # On traite l'action
  if [ $(($API_CALL)) -eq $((5)) ];then 
    # Toutes les cartes ont été reçues
    getCards
    echo "Cartes reçues ! Vos cartes : "${CURRENT_CARDS[@]}
    ListenCardToPlay &
  elif [ $(($API_CALL)) -eq $((1)) ];then 
    # Une carte du tour courant a été trouvée
    echo $API_MESSAGE
  elif [ $(($API_CALL)) -eq $((2)) ];then 
    # Une mauvaise carte a été trouvée, le tour recommence
    echo $API_MESSAGE
  elif [ $(($API_CALL)) -eq $((3)) ];then 
    # Le tour est terminé, on passe au tour suivant
    echo $API_MESSAGE
  elif [ $(($API_CALL)) -eq $((4)) ];then 
    # Le jeu est terminé
    echo $API_MESSAGE
    read tmp
    exit
  fi

  ListenPipe
}

echo "Vous êtes le joueur n°"$PLAYER_ID
echo "En attente de vos cartes ..."

ListenPipe 
