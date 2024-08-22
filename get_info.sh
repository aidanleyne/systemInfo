#!/bin/bash

if [ "$#" -ne 5 ]; then
	echo "Wrong number of arguments"
	echo "Usage $0 <rec_password> <rec_hostname> <IP> <PSWRD> <PORT>"
	exit 1
fi

REC_PSWD="$1"
REC_HN="$2"
IP="$3"
PSWRD="$4"
USER="root"
PORT=${5:-22}

if ! command -v sshpass &> /dev/null; then
	sudo apt-get update
	sudo apt-get install -y sshpass
fi

sshpass -p "$PSWRD" ssh -p $PORT $USER@$IP << EOF
	
	echo "Connection to client established".
	cd /home || { echo "Failed to change directory to /home"; exit 1; }

	mkdir -p system_info && rm -rf system_info/* || { echo "Failed to create or clean system_info directory"; exit 1; }

	if ! command -v lshw &> /dev/null; then
        echo "lshw not found, attempting to install..."
        if command -v yum &> /dev/null; then
            sudo yum -y install lshw && sudo yum -y install sshpass || { echo "Failed to install lshw via yum"; exit 1; }
        elif command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y lshw && sudo apt-get install -y sshpass || { echo "Failed to install lshw via apt-get"; exit 1; }
        else
            echo "Unsupported package manager. Please install lshw manually."
            exit 1
        fi
    fi
	
	dmidecode >> system_info/dmi.txt

	echo "-------------- CPU Information --------------" > system_info/cpu.txt
	lshw -C cpu >> system_info/cpu.txt

	echo "-------------- Memory Information --------------" > system_info/memory.txt
	lshw -C memory >> system_info/memory.txt

	echo "-------------- Disk Information --------------" > system_info/disk.txt
	lshw -C disk >> system_info/disk.txt

	echo "-------------- Network Information --------------" > system_info/network.txt
	lshw -C network >> system_info/network.txt


	# Zip the directory containing the output file
	ZIP_NAME="${IP}_system_info.zip"
	zip -r "\${ZIP_NAME}" system_info
	echo "Script completed on client."
	
	# Send file back to host machine
	sshpass -p "$REC_PSWD" scp -P 86 *system_info.zip root@"$REC_HN":/home/system_infos/
	echo "Files copied to recipient."
	exit
EOF

echo "Script completed successfully."
