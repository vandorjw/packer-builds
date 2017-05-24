#!/bin/bash
sudo apt update
# install curl to fix broken wget while retrieving content from secured sites
sudo apt -y install curl
sudo apt -y install nginx-full
sudo apt -y upgrade
