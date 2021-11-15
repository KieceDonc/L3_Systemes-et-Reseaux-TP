#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h> 

#define MAX_LEN 2000

//https://c.developpez.com/cours/bernard-cassagne/node74.php

int main(){  

   
  int fp = open("file2.txt", O_RDWR);

  char input[MAX_LEN];

  const char* toAsk[3];
  toAsk[0] = "Entrer le nom du compte";
  toAsk[1] = "Entrer le répertoire de login";
  toAsk[2] = "Entrer le groupe";

  char memory[MAX_LEN];

  for(int y = 0;y<3;y++){
    for(int x = 0; x < 3; x++){
      printf("%s\n",toAsk[x]);
      scanf("%s", input);
      strcat(memory, input);
      if(x!=2){
        strcat(memory, ":");
      }
    }
    strcat(memory, "\n");
  }


  write(fp,memory,strlen(memory));

  
  close(fp);//closing file 
  return 0; 
}  