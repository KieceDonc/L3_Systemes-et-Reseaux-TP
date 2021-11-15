#include <stdio.h>  
#include <unistd.h>
#include <string.h>

#define MAX_LEN 80

//https://c.developpez.com/cours/bernard-cassagne/node74.php



int main(){  

  FILE *fp;  
  fp = fopen("file.txt", "w");//opening file 
  char input[MAX_LEN];

  const char* toAsk[3];
  toAsk[0] = "Entrer le nom du compte";
  toAsk[1] = "Entrer le répertoire de login";
  toAsk[2] = "Entrer le groupe";

  char memory[250];

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
  
  fprintf(fp, "%s",memory);//writing data into file  
  
  fclose(fp);//closing file 
  return 0; 
}  