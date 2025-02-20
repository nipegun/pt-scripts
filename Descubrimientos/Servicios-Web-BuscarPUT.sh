#!/bin/bash

vURL="http://192.168.10.7:3000/api/Products"

curl -X OPTIONS -D - "$vURL"
