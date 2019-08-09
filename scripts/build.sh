#!/bin/bash
export K8S_NAMESPACE=development

function pre_check() {
    ## check k8s server accessibility
    if kubectl get nodes >/dev/null ; then
        echo "K8s Server accessible...!"
    else
        echo "kubernetes server not accessible...! or kubectl commands not available...!"
        exit 1
    fi

    ## check helm installation
    if helm repo list >/dev/null ; then
        echo "helm configured...!"
    else
        echo ""
        echo "Trying to Configure helm now...!"
        curl -s https://raw.githubusercontent.com/akhilrajmailbox/GuestBook/master/scripts/helm-configure.sh | bash
        if [[ $? -ne 0 ]] ; then
            echo "you have to configure helm manually; then run this build again"
            echo "https://raw.githubusercontent.com/akhilrajmailbox/GuestBook/master/scripts/helm-configure.sh"
            exit 1
        fi
        sleep 30
    fi
}


function guestbook_install() {
    pre_check
    kubectl create ns $K8S_NAMESPACE
    helm repo add helm-repo https://akhilrajmailbox.github.io/GuestBook/docs
    helm install --namespace $K8S_NAMESPACE helm-repo/guestbook --name my-app
}



################################################
function efk_info() {
    if [[ $(kubectl -n $K8S_NAMESPACE get services guestbook -o jsonpath="{.spec.type}") == NodePort ]] ; then
        export NODE_PORT=$(kubectl get --namespace $K8S_NAMESPACE -o jsonpath="{.spec.ports[0].nodePort}" services guestbook)
        export NODE_IP=$(kubectl get nodes --namespace $K8S_NAMESPACE -o jsonpath="{.items[0].status.addresses[0].address}")
        echo ""
        echo "guestbook Nodeport Configuration will be :: "
        echo http://$NODE_IP:$NODE_PORT
        echo ""
        echo "If you are planning to configure AWS ELB, then use this port to configure ELB to access guestbook"
        echo "Guestbook NodePort : $NODE_PORT"
    fi
}


efk_info