#!/bin/bash
export K8S_NAMESPACE=development
export SERVICE_NAME=guestbook
export STABLE_DEPLOY_NAME=guestbook-green
export CANARY_DEPLOY_NAME=guestbook-blue


function canary_deploy() {
    kubectl -n $K8S_NAMESPACE apply -f ../sources/blue-guestbook-frontend-deployment.yaml
    ## im doing service patch because previous service having some label which used for blue-green deployment
    kubectl -n $K8S_NAMESPACE patch service $SERVICE_NAME --type='json' -p='[{"op":"add", "path":"/spec/selector", "value":{"app.kubernetes.io/name": "guestbook","app.kubernetes.io/tier":"frontend"}}]'
    echo "wait for 10 sec"
    sleep 10
    echo "You can tweak the number of replicas of the stable and canary releases to determine the ratio of each release that will receive live production traffic"
    echo "In this case, 3:2 -- (stable:canary))"
}


function stable_rollout() {
    kubectl -n $K8S_NAMESPACE scale deploy $CANARY_DEPLOY_NAME --replicas=3
    echo "wait for 10 sec"
    sleep 10
    kubectl -n $K8S_NAMESPACE delete deploy $STABLE_DEPLOY_NAME
    echo "wait for 10 sec"
    sleep 10
    echo "Canary Deployment Done....!"
}

export Command_Usage="Usage: ./canary.sh -o [OPTION]"

while getopts ":o:" opt
   do
     case $opt in
        o ) option=$OPTARG;;
     esac
done



if [[ $option = deploy ]]; then
	canary_deploy
elif [[ $option = rollout ]]; then
	stable_rollout
else
	echo "$Command_Usage"
cat << EOF
_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

Main modes of operation:

   deploy 		: 	Deploy Canary Release along with running stable release in ratio of 3:2 [stable:canary]
   rollout 		: 	Delete Old release (stable release) and scale up canary release, now canary release become new stable release
_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
EOF
fi