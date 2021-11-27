#!/bin/bash
 
CARDS=() # Tableau qui contient les cartes mélangées
declare -i ROUND=1 # On déclare un integer. Il décrit le numéro du tour
CURRENT_ROUND_SORTED_CARDS=() # Liste des cartes tirer et trier pour le tour courant
declare -i CURRENT_CARD_INDEX=0 # On déclare un integer. Il décrit l'index de la carte que l'on doit trouver pour le round courant
NBPLAYERS=0 # Décrit le nombre de joueur
NBROBOT=0 # Décrit le nombre de robot
declare -i MAX_ROUND=0 # On déclare un integer. Décrit le nombre maximun de tour
declare -i MSG_INDEX=1 # On déclare un integer. Il décrit la ligne du dernier message envoyé

function InitPlayers(){
  # On demande le nombre de joueur
  echo -n "Entrer le nombre de joueur : "
  read NBPLAYERS

  # On demande le nombre de robot 
  echo -n "Entrer le nombre de robot : "
  read NBROBOT

  # On supprime les pipes existent ( normalement non nécessaire, cette fonction est juste là pendant la période de développement et sert de sécurité une fois le projet finit )
  removeOldFiles
  
  if [ $(($NBPLAYERS)) -gt $((0)) ];then
    # On initialise les terminaux + pipes pour les joueurs
    for x in $( eval echo {0..$(($NBPLAYERS-1))} );do
      xterm -e "./JoueurHumain.sh $x" & # Initialisation des terminaux en donnant en paramètre le n° du joueur
      mkfifo $x.pipe # Initialisation des pipes qui prennent le nom "n°Joueur.pipe"
    done
  fi
  
  if [ $(($NBROBOT)) -gt $((0)) ];then
    # On initialise les terminaux + pipes pour les robots
    for x in $( eval echo {$(($ROUND*$NBPLAYERS))..$(($ROUND*$NBPLAYERS+$ROUND*$NBROBOT-1))} );do
      xterm -e "./JoueurRobot.sh $x" & # Initialisation des terminaux en donnant en paramètre le n° du robot
      mkfifo $x.pipe # Initialisation des pipes qui prennent le nom "n°robot.pipe"
    done
  fi;
}

function InitMaxRound(){
  MAX_ROUND=0
  NOT_FOUND=true # On initialise un booléen qui va servir de drapeau pour savoir si on a trouver le nombre maximum de tour
  while $NOT_FOUND 
  do
    if [ $(($MAX_ROUND*$NBPLAYERS+$MAX_ROUND*$NBROBOT)) -le $((100)) ];then # On vérifie si le nombre de carte distribués est inférieur ou égale à 100
      MAX_ROUND+=1 # On peut rajouter un tour
    else
      NOT_FOUND=false # On a trouver le nombre max de tour
    fi
  done
}

function SendCards(){
  # On initialise les cartes
  CARDS=()

  # On initialise l'index de la carte que l'on doit trouver pour le round courant
  CURRENT_CARD_INDEX=0

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

  # On envoit les cartes pour chaque joueur
  CURRENT_ROUND_UNSORTED_CARDS=()
  declare -i CURRENT_CARD_INDEX=0
  for x in $( eval echo {0..$(($NBPLAYERS+$NBROBOT-1))} );do 

    for y in $( eval echo {0..$(($ROUND-1))} );do
      CURRENT_CARD=${CARDS[CURRENT_CARD_INDEX]}
      echo $CURRENT_CARD
      CURRENT_ROUND_UNSORTED_CARDS+=($CURRENT_CARD)
      CURRENT_CARD_INDEX+=1
    done > $x"_CURRENT_CARDS.tmp"

  done

  # On envoit un message qui décrit que les cartes ont été distribuées 
  sendMsgPlayers "5" ""
  sendMsgRobot "5" "robot msg skip"

  # On trie les cartes que les joueurs doivent trouver
  CURRENT_ROUND_SORTED_CARDS=()
  for x in $( eval echo {0..$(($ROUND*$NBPLAYERS+$ROUND*$NBROBOT-1))} );do
    CURRENT_MINUS=1000
    MINUS_INDEX=-1
    UNSORTED_INDEX=$((${#CURRENT_ROUND_UNSORTED_CARDS[@]}-1))
    for y in $( eval echo {0..$UNSORTED_INDEX} );do 
      CURRENT_CARD=${CURRENT_ROUND_UNSORTED_CARDS[y]} # Carte courante de la liste des cartes non trier
      if [ $(($CURRENT_CARD)) -lt $(($CURRENT_MINUS)) ];then # On vérifie si la carte courante est inférieur au minimun courant
        CURRENT_MINUS=$CURRENT_CARD
        MINUS_INDEX=$y
      fi
    done
    CURRENT_ROUND_SORTED_CARDS+=($CURRENT_MINUS)
    removeValueAtIndexInUnsortedCards $MINUS_INDEX
  done    
  echo "Liste des cartes à trouver : ${CURRENT_ROUND_SORTED_CARDS[@]}"
}

#
function removeValueAtIndexInUnsortedCards(){
  # USE TO REPLACE CURRENT_ROUND_UNSORTED_CARDS=(${CURRENT_ROUND_UNSORTED_CARDS[@]/$CURRENT_MINUS}) 
  # Working with low array or high array but without numbers < 10 

  # On supprime la carte jouée par l'utilisateur
  INDEX_TOREMOVE=$1
  TMP=()
  for x in $( eval echo {0..$UNSORTED_INDEX} );do
    if [ $(($x)) -ne $(($INDEX_TOREMOVE)) ];then
      TMP+=(${CURRENT_ROUND_UNSORTED_CARDS[x]})
    fi
  done
  CURRENT_ROUND_UNSORTED_CARDS=()
  CURRENT_ROUND_UNSORTED_CARDS=(${TMP[@]})
}

function updateFoundedCards(){
  FOUNDED_CARDS="( " # On prépare l'affichage de toutes les cartes trouver
  for x in $( eval echo {0..$(($CURRENT_CARD_INDEX))} );do # On affiche toutes les cartes trouver
    FOUNDED_CARDS="$FOUNDED_CARDS ${CURRENT_ROUND_SORTED_CARDS[x]} "
  done
  FOUNDED_CARDS="$FOUNDED_CARDS )"
}

function ListenPipe(){
  # On regarde si la pipe a déjà été créer
  # Cette condition est nécessaire pour créer la pipe lors de l'initialisation et éviter les erreurs lors des appels récursif de ListenPipe()
  if [[ ! -p "gestionJeu.pipe" ]];then
    mkfifo gestionJeu.pipe
  fi
  
  INCOMING_CARD=$(cat gestionJeu.pipe) # On récupère la carte reçus
  WINNING_CARD=${CURRENT_ROUND_SORTED_CARDS[CURRENT_CARD_INDEX]} # On récupère la carte à trouvée
  if [ $(($WINNING_CARD)) -eq $(($INCOMING_CARD)) ];then # On regarde si la carte jouer est la carte devant être trouver
    # Une bonne carte a été jouer
    updateFoundedCards
    sendMsgPlayers "1" "Bravo, une carte a été trouvée, voici les cartes trouvées : $FOUNDED_CARDS"
    sendMsgRobot "1" $FOUNDED_CARDS
    CURRENT_CARD_INDEX+=1 # Le tour continue, on incrémente l'index de la prochaine carte à trouvée
    if [ $(($CURRENT_CARD_INDEX)) -eq $(($ROUND*$NBPLAYERS+$ROUND*$NBROBOT)) ];then # On vérifie si la dernière carte trouvée correspond à la dernière carte pouvant être jouer ce tour ( on vérifie si le tour est terminé )
      if [ $(($ROUND*$NBPLAYERS+$ROUND*$NBROBOT)) -le $((100)) ];then # On vérifie si il reste un tour
        # Le tour est terminer, on passe au tour suivant
        sendMsgPlayers "3" "Félicitations, le tour n°'$ROUND' est terminé, on passe au tour suivant"
        sendMsgRobot "3" $ROUND
        ROUND+=1
        SendCards
     else
        # Le jeu est terminer
        sendMsgPlayers "4" "Félicitations, le jeu est terminé" 
        sendMsgRobot "4" "robot msg skip"
        removeOldFiles
        exit
      fi
    fi
  else 
    # Une mauvaise carte a été jouée
    sendMsgPlayers "2" "Perdu, la carte $INCOMING_CARD n'était pas la bonne, la bonne était : $WINNING_CARD. On recommence !" 
    sendMsgRobot "2" "robot msg skip"
    SendCards
  fi
  ListenPipe
}

function sendMsgPlayers(){
  # Permet d'envoyer un message à tout les humains
  # Prend un premier paramètre qui est l'id de l'action
  # Prend un deuxième paramètre optionnel qui est un message que l'on souhaite afficher côté joueur
  if [ $(($NBPLAYERS)) -gt $((0)) ];then
    MSG_TO_SEND=$2
    MSG_ID=$1
    echo $MSG_TO_SEND >> gestionJeu.tmp
    for x in $( eval echo {0..$(($NBPLAYERS-1))} );do
    echo "$MSG_ID;$MSG_INDEX" > $x.pipe
    done
    MSG_INDEX+=1
  fi
}

function sendMsgRobot(){
  # Permet d'envoyer un message à tout les robots
  # Prend un premier paramètre qui est l'id de l'action
  # Prend un deuxième paramètre optionnel qui est un message que l'on souhaite afficher côté joueur
  if [ $(($NBPLAYERS)) -gt $((0)) ];then
    MSG_TO_SEND=$2
    MSG_ID=$1
    echo $MSG_TO_SEND >> gestionJeu.tmp
    for x in $( eval echo {$(($NBPLAYERS))..$(($NBPLAYERS+$NBROBOT-1))} );do
      echo "$MSG_ID;$MSG_INDEX" > $x.pipe
    done
    MSG_INDEX+=1
  fi;
}

function removeOldFiles(){
  # Supprime toutes les pipes / tout les fichiers tmp précédent
  # On envoit les messages d'erreurs vers null 
  # Cette redirection est justifier par le fait que si il n'existe pas de fichiers .tmp alors rm affiche une erreur
  rm .pipe 2>/dev/null
  rm *.tmp 2>/dev/null
  rm *.pipe 2>/dev/null
}

InitPlayers
InitMaxRound
SendCards
ListenPipe