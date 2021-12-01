#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <pthread.h>
#include <semaphore.h>

//gcc exo7.c -o exo7.o -lpthread

int numberOfLocalIteration = 1000;

sem_t semaphore0;
sem_t semaphore1;
sem_t semaphore2;

void *t1(void *vargp){
  int threadLocalID = 1;
  // printf("Thread init %i\n",threadLocalID);

  // printf("Before Thread %i\n",threadLocalID);
  for(int x=0;x<numberOfLocalIteration;x++);
  printf("After Thread %i\n",threadLocalID);

  sem_post(&semaphore0);
  sem_post(&semaphore0);
  sem_post(&semaphore0);
}

void *t2(void *vargp){
  int threadLocalID = 2;
  // printf("Thread init %i\n",threadLocalID);

  sem_wait(&semaphore0);

  // printf("Before Thread %i\n",threadLocalID);
  for(int x=0;x<numberOfLocalIteration;x++);
  printf("After Thread %i\n",threadLocalID);

  sem_post(&semaphore1);
}

void *t3(void *vargp){
  int threadLocalID = 3;
  // printf("Thread init %i\n",threadLocalID);

  sem_wait(&semaphore0);

  // printf("Before Thread %i\n",threadLocalID);
  for(int x=0;x<numberOfLocalIteration;x++);
  printf("After Thread %i\n",threadLocalID);

  sem_post(&semaphore1);
}

void *t4(void *vargp){
  int threadLocalID = 4;
  // printf("Thread init %i\n",threadLocalID);

  sem_wait(&semaphore0);

  // printf("Before Thread %i\n",threadLocalID);
  for(int x=0;x<numberOfLocalIteration;x++);
  printf("After Thread %i\n",threadLocalID);

  sem_post(&semaphore2);
}

void *t5(void *vargp){
  int threadLocalID = 5;
  // printf("Thread init %i\n",threadLocalID);

  sem_wait(&semaphore1);
  sem_wait(&semaphore1);

  // printf("Before Thread %i\n",threadLocalID);
  for(int x=0;x<numberOfLocalIteration;x++);
  printf("After Thread %i\n",threadLocalID);

  sem_post(&semaphore2);
}

void *t6(void *vargp){
  int threadLocalID = 6;
  // printf("Thread init %i\n",threadLocalID);

  sem_wait(&semaphore2);
  sem_wait(&semaphore2);

  // printf("Before Thread %i\n",threadLocalID);
  for(int x=0;x<numberOfLocalIteration;x++);
  printf("After Thread %i\n",threadLocalID);
}

int main(int argc, char *argv[]){
  if(sem_init(&semaphore0,0,0) == -1){
    printf("semaphore 0 init failed\n");
    exit(0);
  }
  if(sem_init(&semaphore1,0,0) == -1){
    printf("semaphore 1 init failed\n");
    exit(0);
  }
  if(sem_init(&semaphore2,0,0) == -1){
    printf("semaphore 2 init failed\n");
    exit(0);
  }
  
  pthread_t thread_id[6];
  pthread_create(&thread_id[0], NULL, t1, NULL);
  pthread_create(&thread_id[1], NULL, t2, NULL);
  pthread_create(&thread_id[2], NULL, t3, NULL);
  pthread_create(&thread_id[3], NULL, t4, NULL);
  pthread_create(&thread_id[4], NULL, t5, NULL);
  pthread_create(&thread_id[5], NULL, t6, NULL);

  for(int x = 0;x<6; x++){
    pthread_join(thread_id[x], NULL);
  }

  sem_destroy(&semaphore0);
  sem_destroy(&semaphore1);
  sem_destroy(&semaphore2);
  return 0;
}