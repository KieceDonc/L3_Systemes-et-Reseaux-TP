#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdbool.h>

void timer_handler (int signum){
    printf("bip\n"); 
}

int main (){
    struct sigaction sa;
    struct itimerval timer;

    signal(SIGALRM,timer_handler);

    timer.it_value.tv_sec = 5;
    timer.it_value.tv_usec = 0;
    timer.it_interval.tv_sec = 5;
    timer.it_interval.tv_usec = 0;
    setitimer(ITIMER_REAL, &timer, NULL);

    while (1) {
       sleep(1);
    }

    printf("job done bye bye\n");
    exit(0);
}