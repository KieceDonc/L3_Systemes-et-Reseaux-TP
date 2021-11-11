#include <stdio.h>
#include <stdlib.h>

void createParty(){

}

void getAvaibleParty(){

}

void showMainMenu(){
  printf("The mind, un jeu coopératif\n");
  printf("Menu\n");
  printf("\tc - Pour créer une partie\n");
  printf("\ts - Pour montrer la liste des parties disponibles\n");
  printf("\tq - Pour quitter\n");
}

void handleInputMainMenu(){
  char input;
  scanf("%c",&input);
  switch(input){
    case 'c':{
      break;
    }
    case 's':{
      break;
    }
    case 'q':{
      exit(0);
    }
    default :{
      printf("Touche %c invalide",input);
    }

  }
}


int main(){
  showMainMenu();
  handleInputMainMenu();
  return 0;
} 