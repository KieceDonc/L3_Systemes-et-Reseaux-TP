#include <stdio.h>  
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>

int recursionCount;
int sum;

void son(int fd[]){
  int input;
  printf("Enter value :\n");
  scanf("%d", &input);
  
  write(fd[1], &input, sizeof(input));
}

void father(int fd[]){
  int input;
  read(fd[0], &input, sizeof(input));
  sum+=input;
  
  printf("Sum value : %d\n",sum);
}

int main(){

  int fd[2];

  pipe(fd);

  pid_t pid = fork();
  while(recursionCount<10){
    recursionCount+=1;
    if(pid==0){
      son(fd);
    }else{
      father(fd);
    }
  }


  if(pid==0){
    close(fd[1]);
  }else{
    close(fd[0]);
  }
  return 0;
}