#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Wrong number of arguments"
	echo "Usage $0 <IP> <PSWRD>"
	exit 1
fi

IP="$1"
PSWRD="$2"
USER="root"
PORT="86"

if ! command -v sshpass &> dev/null; then
	sudo apt-get update
	sudo apt-get install -y sshpass
fi

sshpass -p "$PSWRD" ssh -p $PORT $USER@$IP << EOF

	if [ -d "system_info" ]; then
		rm -rf system_info
	else
		mkdir system_info
	fi

	if ! command -v lshw &> /dev/null; then
		echo "lshw not found, installing..."
		yum -y install lshw
	fi

	touch system_info/cpu.txt
	echo "-------------- CPU Information --------------" >> system_info/cpu.txt
	lshw -C cpu >> system_info/cpu.txt

	touch system_info/memory.txt
	echo "-------------- Memory Information --------------" >> system_info/memory.txt
	lshw -C memroy >> system_info/memory.txt

	touch system_info/disk.txt
	echo "-------------- Disk Information --------------" >> system_info/disk.txt
	lshw -C disk >> system_info/disk.txt

	touch system_info/network.txt
	echo "-------------- Network Information --------------" >> system_info/network.txt
	lshw -C network >> system_info/network.txt


	# Zip the directory containing the output file
	$ZIP_NAME="${IP}_system_info.zip"
	zip -r $ZIP_NAME system_info

	# Send the zipped file to another computer using scp
	scp $ZIP_NAME "@$REMOTE_HOST:$REMOTE_PATH

	exit
	
EOF

# Output completion message
echo "Script completed successfully, and the file has been sent to $REMOTE_HOST."
