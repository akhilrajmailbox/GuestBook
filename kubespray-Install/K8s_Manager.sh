#!/bin/bash
# link :: https://github.com/akhilrajmailbox/kubespray.git
# link :: https://github.com/kubernetes-incubator/kubespray.git
# link :: https://medium.com/@iamalokpatra/deploy-a-kubernetes-cluster-using-kubespray-9b1287c740ab
# link :: https://dzone.com/articles/kubespray-10-simple-steps-for-installing-a-product

export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
# sudo dpkg-reconfigure locales
# sudo update-locale LANG=en_US.UTF-8
sudo dpkg-reconfigure --frontend noninteractive locales

sudo apt-get update
sudo apt-get install software-properties-common git
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update
sudo apt-get install ansible -y
sudo apt-get install python-pip -y
sudo apt-get install python3-pip -y
pip2 install jinja2 --upgrade
sudo apt-get install python-netaddr -y
sudo sysctl net.ipv4.ip_forward
sudo sysctl -w net.ipv4.ip_forward=1
sudo ufw disable


## Configuring kubespray server andf its requirements
git clone https://github.com/akhilrajmailbox/kubespray.git
cd kubespray
pip3  install -r contrib/inventory_builder/requirements.txt
sudo pip install -r requirements.txt


## Configuring kubectl in K8s Manager server
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
mkdir $HOME/.kube
touch $HOME/.kube/config
echo "update the $HOME/.kube/config with admin.conf file of any one of the master node and replace the server: entry with your ELB address"


ansible --version