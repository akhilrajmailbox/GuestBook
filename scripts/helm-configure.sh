#!/bin/bash
# link :: https://helm.sh/docs/using_helm/



################################################
function helm_config() {
    echo "installing helm in your system"
    curl -L https://git.io/get_helm.sh | bash


    kubectl create serviceaccount --namespace kube-system tiller
    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    sleep 40
    kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
    sleep 30     
    helm init --service-account tiller --upgrade
}

helm_config