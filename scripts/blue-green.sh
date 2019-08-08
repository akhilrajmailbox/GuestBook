#!/bin/bash
# link : https://github.com/akhilrajmailbox/ci-cd/blob/kubernetes/kubernetes-production.pdf

export K8S_NAMESPACE=development
export SERVICE_NAME=guestbook
export DEPLOY_NAME=guestbook


function bg_deploy() {
    kubectl -n $K8S_NAMESPACE apply -f ../sources/green-guestbook-frontend-deployment.yaml
    kubectl -n $K8S_NAMESPACE patch service $SERVICE_NAME -p '{"spec":{"selector":{"app.kubernetes.io/version":"green"}}}'
    echo "wait for 10 sec"
    sleep 10
    echo "deleting old version of Deployment : $DEPLOY_NAME"
    kubectl -n $K8S_NAMESPACE delete deployment $DEPLOY_NAME
    sleep 5
    echo "refresh webpage many time to see your work...!"
}

bg_deploy