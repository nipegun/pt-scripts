# Scripts de Python para ataques Modbus de TryHackMe

Estos scripts de Python son proporcionados por TryHackMe para resolver las salas "Attacking ICS Plant #1" y "Attacking ICS Plant #2". Usan la librería PyModbus de Python. Concretamente pymodbus 1.5.2.

## Instalación en Debian o derivadas

Mediante usuario con permisos sudo:

```
curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Modbus/ScriptsTryHackMe/Instalar.sh | bash
```

Mediante usuario root (para sistemas sin sudo:

```
curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Modbus/ScriptsTryHackMe/Instalar.sh | sed 's-sudo--g' | bash
```

## Uso

.
