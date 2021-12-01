startserver: build
	sudo ./server.o 850

startclient: build
	sudo ./client.o localhost 850

build : client.o server.o

client.o: client.c
	gcc client.c -o client.o

server.o: server.c
	gcc server.c -o server.o