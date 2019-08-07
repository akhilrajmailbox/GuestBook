#!/bin/bash
export K8S_NAMESPACE=development
export SERVICE_NAME=frontend
export DEPLOY_NAME=frontend

kubectl -n $K8S_NAMESPACE apply -f ../sources/guestbook-frontend-deployment.yaml
kubectl -n $K8S_NAMESPACE patch service $SERVICE_NAME -p '{"spec":{"selector":{"app.kubernetes.io/version":"green"}}}'
echo "wait for 10 sec"
sleep 10
echo "deleting old version of Deployment : $DEPLOY_NAME"
kubectl -n $K8S_NAMESPACE delete deployment $DEPLOY_NAME
