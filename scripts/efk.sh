#!/bin/bash
# link :: https://mherman.org/blog/logging-in-kubernetes-with-elasticsearch-Kibana-fluentd/

################################################
function efk-server() {
    # creating namespace called logging
    kubectl apply -f ../efk/namespace.yaml

    # installing and configuring elasticsearch in logging namespace
    kubectl -n logging apply -f ../efk/elasticsearch-deployment.yaml
    kubectl -n logging apply -f ../efk/elasticsearch-service.yaml

    # installing and configuring kibana in logging namespace
    kubectl -n logging apply -f ../efk/kibana-deployment.yaml
    kubectl -n logging apply -f ../efk/kibana-service.yaml

    # installing and configuring fluentd in kube-system namespace
    kubectl apply -f ../efk/fluentd-rbac.yaml
    kubectl apply -f ../efk/fluentd-daemonset.yaml
}


################################################
function efk-info() {
    efk-server
    echo "the logs need to have format > timestampFormat: YYYY-MM-DD HH:mm:ss.SSS"
    sleep 20
    if [[ $(kubectl -n logging get services kibana -o jsonpath="{.spec.type}") == NodePort ]] ; then
        export NODE_PORT=$(kubectl get --namespace logging -o jsonpath="{.spec.ports[0].nodePort}" services kibana)
        export NODE_IP=$(kubectl get nodes --namespace logging -o jsonpath="{.items[0].status.addresses[0].address}")
        echo ""
        echo "kibana Nodeport Configuration will be :: "
        echo http://$NODE_IP:$NODE_PORT
    fi
}


efk-info