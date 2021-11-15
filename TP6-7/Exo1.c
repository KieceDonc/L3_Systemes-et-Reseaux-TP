#include <stdio.h>  

#define MAX_LEN 80

//https://c.developpez.com/cours/bernard-cassagne/node74.php



int main(){  

  FILE *fp;  
  fp = fopen("file.txt", "w");//opening file  

  char input[MAX_LEN];

  const char* toAsk[3];
  a[0] = "Entrée le nom du compte";
  a[1] = "Entrée le répertoire de login";
  a[1] = "Entrée le groupe";

  for(int x = 0; x < 3; x++){
    printf(a[x]);
    scanf("%s", input);
    int returnCode = fprintf(fp, input+"\n");//writing data into file  
  }
  fclose(fp);//closing file 
  return 0; 
}  