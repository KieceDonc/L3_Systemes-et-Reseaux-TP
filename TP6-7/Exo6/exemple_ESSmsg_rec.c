#include <sys/types.h>  
#include <sys/ipc.h>  
#include <sys/msg.h>  
#include <stdio.h>  
#include <stdlib.h>  
#define MAXSIZE 128  
  
void erreur(char *s){  
  perror(s);  
  exit(1);  
}  
  
typedef struct msgbuf{  
  long mtype;  
  char mtext[MAXSIZE];  
};  
  
  
int main(){  
  int msqid;  
  key_t key;  
  struct msgbuf rcvbuffer;  

  key = 1234;  

  if ((msqid = msgget(key, 0666)) < 0){  
    erreur("msgget()");  
  }


  //Reception d'un message de type 1.  
  if (msgrcv(msqid, &rcvbuffer, MAXSIZE, 1, 0) < 0){  
    erreur("msgrcv");  
  }

  printf("%s\n", rcvbuffer.mtext);  
  
  return 0;  
}  
