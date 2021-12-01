
/* A simple server in the internet domain using TCP
   The port number is passed as an argument */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

void error(char *msg){
     perror(msg);
     exit(1);
}

int main(int argc, char *argv[]){
     int sockfd, newsockfd, portno, clilen;
     char buffer[256], action[12],fic[25], fic2[25], tt[25], proto[10];
     struct sockaddr_in serv_addr, cli_addr;
     int n;
     
     if (argc < 2) {
          fprintf(stderr,"ERROR, no port provided\n");
          exit(1);
     }
     
     sockfd = socket(AF_INET, SOCK_STREAM, 0);
     if (sockfd < 0){
          error("ERROR opening socket");
     } 
     
     bzero((char *) &serv_addr, sizeof(serv_addr));
     portno = atoi(argv[1]);
     serv_addr.sin_family = AF_INET;
     serv_addr.sin_addr.s_addr = INADDR_ANY;
     serv_addr.sin_port = htons(portno);
     if (bind(sockfd, (struct sockaddr *) &serv_addr,sizeof(serv_addr)) < 0){
          error("ERROR on binding");
     } 

     listen(sockfd,5);
     clilen = sizeof(cli_addr);
     newsockfd = accept(sockfd, (struct sockaddr *) &cli_addr, &clilen);
     if (newsockfd < 0){
          error("ERROR on accept");
     }else{
          printf("client connecté\n");
     }

     bzero(buffer,256);
     n = read(newsockfd,buffer,255);
     if (n < 0){
          error("ERROR reading from socket");
     }

     printf("requete: %s\n",buffer);
     sscanf(buffer, "%s %s %s", action, fic, proto);
     if(memcmp(action,"GET",3)){
          printf("requete inconnue: %s\n",action);
     }else{
          printf("Fichier: %s, proto:%s\n",fic,proto);
     }

     sscanf(fic,"http://%s/%s", tt,fic2);
     printf("fichier: %s\n",fic2);
     n = write(newsockfd,"I got your message",18);
     if (n < 0){
          error("ERROR writing to socket");
     }
     
     getchar();
     close(sockfd); close(newsockfd);
     return 0; 
}






