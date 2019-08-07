#!/bin/bash
echo "K8s Cluster configuration on ubuntu 16.04 system...!"

#################################
function install_dep() {
  apt-get update && apt-get install -y apt-transport-https
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
  apt-get update
  apt-get install -y docker.io
  apt-get install -y kubelet kubeadm kubectl kubernetes-cni
  apt-get update && apt-get install ceph-common -y
}


#################################
function cluster_info() {
cat << EOF
  
  "If you want to configure this server as K8s master, then run the following commands...!" 
  
  ## If your server have less than 2 vCPU, then run this command to ignore the error..! 
  # kubeadm init --ignore-preflight-errors=NumCPU

  ## Else run this default command to configure your server as K8s master node
  # kubeadm init
  # --apiserver-advertise-address >> use this if you want to expose the public ip address

  ## To start using your cluster, you need to run the following as a regular user:
  # mkdir -p $HOME/.kube
  # sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  # sudo chown \$(id -u):\$(id -g) $HOME/.kube/config
  # export KUBECONFIG=$HOME/.kube/config


  ## Run this following command to configure weave network (One of the CNI)
  ## CNI (Container Network Interface), we need to install an cni network in the master machine to help pod in cluster can communicate with each other
  # export kubever=\$(kubectl version | base64 | tr -d '\n')
  # kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=\$kubever"

  ## If you want to serve your master node as a workernode, run this command (Not recommended for production.. do this only for testing if you don't have much resources)
  # kubectl taint nodes --all node-role.kubernetes.io/master-

  ## Only in WorkerNodes
  ## Run command kubeadm join with params is the secret key of your kubernetes cluser and your master node ip in the workernodes to add that node in this cluster
  # kubeadm join 172.31.90.48:6443 --token sometoken \
    --discovery-token-ca-cert-hash sha256:somehasvalue  
EOF
}


install_dep \
&& cluster_info

