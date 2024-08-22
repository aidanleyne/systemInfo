#!/bin/bash

if [ "$#" -ne 4 ]; then
	echo "Wrong number of arguments"
	echo "Usage $0 <rec_password> <rec_hostname> <IP> <PSWRD>"
	exit 1
fi

REC_PSWD="$1"
REC_HN="$2"
IP="$3"
PSWRD="$4"
USER="root"
PORT=${5:-22}

sshpass -p "$PSWRD" ssh -T -p "$PORT" "$USER@$IP" << 'EOF'
    echo "Testing basic command output"
    uname -a
    ls -l /home
EOF

