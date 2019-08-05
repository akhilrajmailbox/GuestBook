#!/bin/bash
# link :: https://github.com/kubernetes-incubator/kubespray.git
# link :: https://medium.com/@iamalokpatra/deploy-a-kubernetes-cluster-using-kubespray-9b1287c740ab
# link :: https://dzone.com/articles/kubespray-10-simple-steps-for-installing-a-product

export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
# sudo dpkg-reconfigure locales
# sudo update-locale LANG=en_US.UTF-8
dpkg-reconfigure --frontend noninteractive locales

sudo apt-get update
sudo apt-get install software-properties-common git
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update
sudo apt-get install ansible -y
sudo apt-get install python-pip -y
sudo apt-get install python3-pip -y
pip2 install jinja2 --upgrade
sudo apt-get install python-netaddr
sudo sysctl net.ipv4.ip_forward
sudo sysctl -w net.ipv4.ip_forward=1
sudo ufw disable


git clone https://github.com/kubernetes-incubator/kubespray.git
cd kubespray
pip3  install -r contrib/inventory_builder/requirements.txt
sudo pip install -r requirements.txt


ansible --version