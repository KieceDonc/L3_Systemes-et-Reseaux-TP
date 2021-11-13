#!/bin/bash
 
CARDS=() # Tableau qui contient les cartes mélangées
declare -i LAST_CARD_INDEX=0 # On déclare un integer. Il décrit l'index de la dernière envoyé à un joueur dans le tableau CARDS 
declare -i ROUND=1 # On déclare un integer. Il décrit le numéro du tour
CURRENT_ROUND_SORTED_CARDS=() # Liste des cartes tirer et trier pour le tour courant
declare -i CURRENT_ROUND_INDEX=0 # On déclare un integer. Il décrit l'index de la carte que l'on doit trouver pour le round courant
NBPLAYERS=0 # Décrit le nombre de joueur
NBROBOT=0 # Décrit le nombre de robot
declare -i MAX_ROUND=0 # On déclare un integer. Décrit le nombre maximun de tour

function InitAndRandomlySortCards(){
  
  # On initialise les cartes
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

  # On supprime les pipes existent ( normalement non nécessaire, cette fonction est juste là pendant la période de développement et sert de sécurité une fois le projet finit )
  removePipe
  
  # On initialise les terminaux + pipes
  for x in $( eval echo {0..$(($NBPLAYERS-1))} );do
    xterm -e "./JoueurHumain.sh $x" & # Initialisation des terminaux en donnant en paramètre le n° du joueur
    mkfifo $x.pipe # Initialisation des pipes qui prennent le nom "n°Joueur.pipe"
  done
}

function InitMaxRound(){
  MAX_ROUND=0
  NOT_FOUND=true # On initialise un booléen qui va servir de drapeau pour savoir si on a trouver le nombre maximum de tour
  while $NOT_FOUND 
  do
    if [ $(($MAX_ROUND*$NBPLAYERS)) -le $((100)) ];then # On vérifie si le nombre de carte distribués est inférieur ou égale à 100
      MAX_ROUND+=1 # On peut rajouter un tour
    else
      NOT_FOUND=false # On a trouver le nombre max de tour
    fi
  done
}

function SortCurrentRoundCards(){
  UNSORTED_CARDS_LENGTH=$(($ROUND*$NBPLAYERS-1))
  for x in $( eval echo {0..$(($ROUND*$NBPLAYERS-1))} );do
    CURRENT_MINUS=1000
    for y in $( eval echo {0..$UNSORTED_CARDS_LENGTH} );do 
      CURRENT_CARD=${CURRENT_ROUND_UNSORTED_CARDS[y]} # Carte courante de la liste des cartes non trier
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
  echo $NBPLAYERS
  for x in $( eval echo {0..$(($NBPLAYERS-1))} );do # Pour chaque joueur 
    echo $x
    for y in $( eval echo {1..$ROUND} );do # Pour le numéro de carte que l'on doit envoyé
      CURRENT_CARD=${CARDS[$LAST_CARD_INDEX]} # On recupère une carte 
      $(echo "0;"$CURRENT_CARD > $x.pipe)  # On l'envoit au joueur
      CURRENT_ROUND_UNSORTED_CARDS+=($CURRENT_CARD) # On indique dans une liste non trier qu'une nouvelle carte est dans le jeu
      LAST_CARD_INDEX+=1 # On incrémente l'index qui décrit le n° de la carte envoyé à un joueur
      echo $x
    done
    $(echo "5;Msg pour éviter de crash" > $x.pipe)  # On notifie que toutes les cartes ont été envoyées
  done
  SortCurrentRoundCards # On trie du plus petit au plus grand les cartes envoyé aux joueurs 
}

function updateFoundedCards(){
  FOUNDED_CARDS="( " # On prépare l'affichage de toutes les cartes trouver
  for x in $( eval echo {0..$CURRENT_ROUND_INDEX);do # On affiche toutes les cartes trouver
    FOUNDED_CARDS=FOUNDED_CARDS+"${CURRENT_ROUND_SORTED_CARDS[CURRENT_ROUND_INDEX]} "
  done
  FOUNDED_CARDS=FOUNDED_CARDS+")"
}

function ListenPipe(){
  mkfifo gestionJeu.pipe
  INCOMING_CARD=$(cat gestionJeu.pipe) # On récupère la carte reçus
  WINNING_CARD=${CURRENT_ROUND_SORTED_CARDS[CURRENT_ROUND_INDEX]} # On récupère la carte à trouvée
  if [ $(($WINNING_CARD)) -eq $(($INCOMING_CARD)) ];then
    updateFoundedCards
    for x in $( eval echo {0..$(($NBPLAYERS-1))} );do # On envoit un message à tout les joueurs disant que la carte trouvée était la bonne
      $(echo "1;Bravo, la carte $WINNING_CARD a été trouvés, voici les cartes trouvées : $FOUNDED_CARDS" > $x.pipe)
    done
    CURRENT_ROUND_INDEX+=1 # Le tour continue, on incrémente l'index de la prochaine carte à trouvée
    if [ $(($CURRENT_ROUND_INDEX)) -eq $(($ROUND*$NBPLAYERS)) ];then # On vérifie si la dernière carte trouvée correspond à la dernière carte pouvant être jouer ce tour ( on vérifie si le tour est terminé )
      if [ $(($ROUND*$NBPLAYERS)) -le $((100)) ];then # On vérifie si il reste un tour
        $(echo "3;Félications, le tour n°$ROUND est terminé, on passe au tour suivant" > $x.pipe)
        ROUND+=1
        SendCardsToPlayers
     else
        $(echo "4;Félications, le jeu est terminé" > $x.pipe)
        removePipe
        exit
      fi
    fi
  else
    for x in $( eval echo {0..$(($NBPLAYERS-1))} );do # On envoit un message à tout les joueurs disant que la carte trouvée était la mauvaise
      $(echo "2;Perdu, la carte $INCOMING_CARD n'était pas la bonne, la bonne était : $WINNING_CARD. On recommence !" > $x.pipe) 
    done
    CURRENT_ROUND_INDEX=0 # Le tour recommence, on réinitialise l'index de la prochaine carte à trouvée
  fi
  ListenPipe
}

function removePipe(){
  for x in $( eval echo {0..$(($NBPLAYERS-1))} );do
    CURRENT_PIPE="$x.pipe"
    if [[ -p $CURRENT_PIPE ]];then
      rm $x.pipe
    fi
  done
  CURRENT_PIPE="gestionJeu.pipe"
  if [[ -p $CURRENT_PIPE ]];then
    rm $CURRENT_PIPE
  fi
}

InitAndRandomlySortCards
InitPlayers
InitMaxRound
SendCardsToPlayers
ListenPipe