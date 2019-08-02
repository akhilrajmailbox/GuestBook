#!/bin/bash

#################################
function jenkins_install() {
    apt-get update
    apt-get install sudo wget unzip nano -y
    apt-get install openjdk-8-jdk -y
    export JAVA_HOME=/usr/lib/jvm/openjdk-8-jdk
    export PATH=$PATH:$JAVA_HOME/bin:/usr/sbin:/sbin:/usr/local/sbin
    apt-get install jenkins -y

    apt-get install -y kubectl
    mkdir -p /var/lib/jenkins/.kube
    touch /var/lib/jenkins/.kube/config
    echo "export KUBECONFIG=/var/lib/jenkins/.kube/config" >> /var/lib/jenkins/.bashrc
    echo "export JAVA_HOME=/usr/lib/jvm/openjdk-8-jdk" >> /var/lib/jenkins/.bashrc
    echo "export PATH=$PATH:$JAVA_HOME/bin:/usr/sbin:/sbin:/usr/local/sbin" >> /var/lib/jenkins/.bashrc
    chown -R jenkins:jenkins /var/lib/jenkins
    /etc/init.d/jenkins start
}




#################################
function jenkins_info() {
    jenkins_install
cat << EOF
  ## To access k8s cluster from jenkins as jenkins user for deployment, you need to do the following task manually :

  copy "/etc/kubernetes/admin.conf" file of kubernetes server to "/var/lib/jenkins/.kube/config" of jenkins server
  make sure that the user "jenkins" user in jenkins server have permission on the file "/var/lib/jenkins/.kube/config"

  "try to access kubernetes server from jenkins by following commands"
  ######
  export KUBECONFIG=/var/lib/jenkins/.kube/config
  kubectl get ns
  ######
  
  If everything working fine, then run the script "helm-configure.sh" in jenkins server as jenkins user.
  you will find the script under scripts folder
EOF
}




jenkins_info