#!/bin/bash
# link :: https://gist.github.com/jamesbuckett/659bf0675acd306407a29d90901bce86
# https://gist.github.com/jamesbuckett/17fe25caa2b85886c78597310bab74bd
# https://github.com/luxas/kubeadm-workshop


################################################
function metrics_server() {
    echo "configuring metrics-server in kubernetes"
	kubectl apply -f ../metrics-server/
    sleep 20
}

################################################
function namespace() {
    metrics_server
    echo "creating namespace : monitoring in kubernetes cluster"
    kubectl create namespace monitoring
    sleep 20
    kubectl get secret rook-rook-user -oyaml | sed "/resourceVer/d;/uid/d;/self/d;/creat/d;/namespace/d" | kubectl -n monitoring apply -f -
    if [[ $? -ne 0 ]] ; then
      exit 1
      echo "rook-block have some issue...! If you haven't configured rook-block yet then configure it first......!"
    fi
}

################################################
function prometheus_server() {
    namespace
    echo "Deploying prometheus in kubernetes"
    helm install stable/prometheus \
        --name prometheus \
        --namespace monitoring \
        --set alertmanager.persistentVolume.enabled=true \
        --set server.persistentVolume.enabled=true \
        --set alertmanager.persistentVolume.storageClass="rook-block" \
        --set server.persistentVolume.storageClass="rook-block"
    sleep 20
}

################################################
function grafana_server() {
    prometheus_server
    echo "Deploying grafana in kubernetes"
    helm install stable/grafana \
        --name grafana \
        --namespace monitoring \
        --set persistence.enabled=true \
        --set persistence.storageClassName="rook-block" \
        --set adminPassword="MyGRafan@" \
        --set datasources."datasources\.yaml".apiVersion=1 \
        --set datasources."datasources\.yaml".datasources[0].name=Prometheus \
        --set datasources."datasources\.yaml".datasources[0].type=prometheus \
        --set datasources."datasources\.yaml".datasources[0].url=http://prometheus-server.monitoring.svc.cluster.local \
        --set datasources."datasources\.yaml".datasources[0].access=proxy \
        --set datasources."datasources\.yaml".datasources[0].isDefault=true \
        --set service.type=NodePort
}


################################################
function grafana_url() {
    grafana_server
    sleep 20
    if [[ $(kubectl -n monitoring get services grafana -o jsonpath="{.spec.type}") == NodePort ]] ; then
        export NODE_PORT=$(kubectl get --namespace monitoring -o jsonpath="{.spec.ports[0].nodePort}" services grafana)
        export NODE_IP=$(kubectl get nodes --namespace monitoring -o jsonpath="{.items[0].status.addresses[0].address}")
        echo ""
        echo "Grafana Nodeport Configuration will be :: "
        echo http://$NODE_IP:$NODE_PORT
    fi
}


################################################
function grafana_dashboard() {
    grafana_url
cat << EOF
    Import these two dashboard to the grafana ui with the following id to get better experience in kubernetes management
    3146    >   Kubernetes Pods
    8588    >   Kubernetes Deployment Statefulset Daemonset metrics   
EOF
}


grafana_dashboard