#!/bin/bash

sudo apt -y update
sudo apt -y upgrade
sudo apt -y install git curl python3 python3-pip python3-venv wine64 unzip mingw-w64 mono-devel
wget https://github.com/upx/upx/releases/download/v5.0.0/upx-5.0.0-amd64_linux.tar.xz
