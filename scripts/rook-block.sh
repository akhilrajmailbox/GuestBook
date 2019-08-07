#!/bin/bash
# link : https://github.com/luxas/kubeadm-workshop

################################################
function rook_block() {
    kubectl apply -f ../rook-block/rook-operator.yaml
    kubectl apply -f ../rook-block/rook-cluster.yaml
    kubectl apply -f ../rook-block/rook-storageclass.yaml

    ## making rook-block available in kube-system namespace, 
    kubectl get secret rook-rook-user -oyaml | sed "/resourceVer/d;/uid/d;/self/d;/creat/d;/namespace/d" | kubectl -n kube-system apply -f -
}


rook_block