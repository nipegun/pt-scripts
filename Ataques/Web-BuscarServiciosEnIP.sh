#!/bin/bash

vHost="localhost"

nmap "$vHost" -p- | sed "s|^|http://$vHost:|" | sed 's-/tcp--g'
