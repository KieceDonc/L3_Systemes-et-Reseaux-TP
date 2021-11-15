#include <stdio.h>  
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

int main(){

    //FILE *fp;
    //fp = fopen ("exo2.txt","a+");
    pid_t currentPid = fork();

    char tmp[500];
    if(currentPid == 0)
        strcpy(tmp,"je suis dans fils");
    else
        strcpy(tmp,"je suis dans père");
    
    for(int x = 0 ; x <= 20; x++){
        printf("n°%i %s\n",x,tmp);
    }



    return 0;

}