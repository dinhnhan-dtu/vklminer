#!/bin/bash
if [ -f "/usr/local/bin/bminer" ];
then
	sudo systemctl stop bminer.service
	sudo systemctl disable bminer.service
fi
if [ ! -f "/usr/local/bin/t-rex" ];
then
	cd /usr/local/bin
	sudo apt-key del 7fa2af80
	sudo apt-key del 3bf863cc
	sudo rm -r /etc/apt/sources.list.d/cuda.list
	sudo rm -r /etc/apt/preferences.d/cuda-repository-pin-600
	sudo rm -r /usr/share/keyrings/cuda-archive-keyring.gpg
	sudo sed -i '/developer\.download\.nvidia\.com\/compute\/cuda\/repos/d' /etc/apt/sources.list.d/*
	sudo sed -i '/developer\.download\.nvidia\.com\/compute\/machine-learning\/repos/d' /etc/apt/sources.list.d/*
	sudo apt-get install linux-headers-$(uname -r) -y
	distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g')
	sudo wget --no-cache https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/cuda-$distribution.pin
	sudo mv cuda-$distribution.pin /etc/apt/preferences.d/cuda-repository-pin-600
	sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/3bf863cc.pub
	echo "deb http://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64 /" | sudo tee /etc/apt/sources.list.d/cuda.list
	sudo apt-get update
	sudo apt-get -y install cuda-drivers
	sudo wget --no-cache https://github.com/trexminer/T-Rex/releases/download/0.25.12/t-rex-0.25.12-linux.tar.gz
	sudo tar xvzf t-rex-0.25.12-linux.tar.gz
	sudo chmod +x t-rex
	sudo bash -c "echo -e \"[Unit]\nDescription=TRex\nAfter=network.target\n\n[Service]\nType=simple\nRestart=on-failure\nRestartSec=15s\nExecStart=/usr/local/bin/t-rex -a ethash -o stratum+tcp://eth.2miners.com:2020 -u $1 -w $2 -p x\n\n[Install]\nWantedBy=multi-user.target\" > /etc/systemd/system/trex.service"
	sudo systemctl daemon-reload
	sudo systemctl enable trex.service
	sudo systemctl reboot
else
	sudo systemctl start trex.service
fi