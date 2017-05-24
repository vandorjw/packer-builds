#!/bin/bash

# remove old source list
sudo rm -f /etc/apt/sources.list

# generate new source list which includes jenkins stable repo
cat << EOF | sudo tee /etc/apt/sources.list > /dev/null
deb http://cloudfront.debian.net/debian jessie main contrib non-free
deb http://security.debian.org/ jessie/updates main contrib non-free
deb http://cloudfront.debian.net/debian jessie-updates main contrib non-free
EOF

