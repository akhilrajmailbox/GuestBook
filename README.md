# GuestBook on Kubernetes (Production Ready)


## table of Contents

<!--ts-->
   * [Requirement](#requirement)
   * [Highly Available Kubernetes Cluster](#highly-available-kubernetes-cluster)
   * [CI-CD pipeline using Jenkins](#ci-cd-pipeline-using-jenkins)
   * [Deploy Guestbook Application](#deploy-guestbook-application)
   * [Prometheus and Grafana](#prometheus-and-grafana)
   * [EFK (Elasticsearch, Fluentd & Kibana)](#elasticsearch-fluentd-and-kibana)
   * [Blue-Green and Canary Deployment](#blue-green-and-canary-deployment)
      * [Blue-Green Deployment of GuestBook Application](#blue-green-deployment-of-guestBook-application)
      * [Canary Deployment of GuestBook Application](#canary-deployment-of-guestBook-application)
        * [steps](#steps)
<!--te-->





## requirement

1. AWS Account
   * 9 ubuntu-16.04 machines with Internet access (`3 K8s Master` , `4 K8s WorkerNodes` , `1 Jenkins Server` and `1 K8s Manager Machine`) with moderate resources `(2 vCPUs, 8 GB RAM and 50 GB Hard Disk for each machines)` prefer `t2.large` type machine. (some of the deployment request limit is 4 GB RAM, so need this much resources for deploying our whole infra)
   * In AWS ubuntu machine, by default you will get the `ubuntu user` with `passwordless sudo permission`. So some scripts may have sudo commands and it will not ask password for ubuntu user, if your user doesn't have the passwordless sudo permission, either you can pass the password while running the script or configure the passwordless sudo permission  in `sudoers` file.
   * Load balancer for access the the services like HA k8s master, grafana, kibana, guestbook-frontend (with help of NodePort, you can access all of these services except HA k8s master as follow : `http://WorkerNode_IP:NodePort`). In this demo I am showing how to use AWS ELB for access our services from outside.
   * `2 Security Group`, one with enable all internal communication within the default VPC and another one for enable access for the NodePort and http ports from ELB. for testing purpose and to simplify this step, you can create one security group with inbound and outbound connection enables for all ports. and use this `security group` for both AWS ELB and instances (don't use it in production)

2. Kubernetes version : 1.8+   # [metrics-server](https://github.com/kubernetes-incubator/metrics-server) configured here support kubernetes version 1.8 or higher.

3. Local system requirement (Optional, we are configuring `K8s Manager Machine` as your local system where you can access the entire services)
   * Ubuntu Machine
   * [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
   * [helm](https://git.io/get_helm.sh)

[Table of contents](#table-of-contents)


## highly available kubernetes cluster

    In this Demo, I'm using kubespray with ansible to Create Multi-master/etcd cluster.
[Go here](https://github.com/akhilrajmailbox/GuestBook/tree/master/kubespray-Install) and follow the steps for install and configure the HA K8s Cluster.


You will find the scripts also there for configure the K8s Manager...!
Note :: you have to configure the K8s Manager with `admin.conf` file once the k8s cluster created. you may need this in upcoming steps.

[Table of contents](#table-of-contents)


## ci-cd pipeline using jenkins

Note : Assumning that you are successfully configured the Multi master Kubernetes Cluster (you  may required the admin.conf file from the previous steps.)


Use one ubuntu 16.04 machine from the 9 machines which we created before. You can find the [jenkins.sh](https://raw.githubusercontent.com/akhilrajmailbox/GuestBook/master/scripts/jenkins.sh) scripts under `scripts folder` for install and configure jenkins in ubuntu machine without any worries.

1. ssh to jenkins machine

2. Clone the repository

3. run the following commands within the cloned location as `root` user

```
$ git clone https://github.com/akhilrajmailbox/GuestBook.git
$ cd GuestBook/scripts/
$ ./jenkins.sh
```

After running the script in jenkins server, you have to copy `admin.conf` file from K8s manager server (the kubernetes config file updated with ELB Ip Address for accessing multi master k8s.) to `/var/lib/jenkins/.kube/config` in jenkins server.

give permission for jenkins user for its home folder `/var/lib/jenkins`

```
$ chown -R jenkins:jenkins /var/lib/jenkins   # as root user
```
switch user to jenkins

```
$ su jenkins
```

try to access kubernetes server from jenkins by following commands

```
$ export KUBECONFIG=/var/lib/jenkins/.kube/config
$ kubectl get ns
```
If you are able to access kubernetes cluster form jenkins server as jenkins user, the configure helm in jenkins server
NOTE : Assuming that you are already configured the helm in kubernetes cluster by running the script [helm-configure.sh](https://raw.githubusercontent.com/akhilrajmailbox/GuestBook/master/scripts/helm-configure.sh) in `K8s Manager Machine`


```
$ helm init --client-only
```

Once you configured the jenkins, you have to access it form web ui and need to do some basic setup for jenkins (adding some plugins and configuring admin password). You can use the public ip address of the jenkins machine to access the jenkins web ui.

```
http://JENKINS_SERVER_IP:8080
```

Configure password for  `admin` user and seetup your jenkins.

(incase if you are not able to access it check the security group of your instances -- ensure that 8080 port are able to access from outside)

[Table of contents](#table-of-contents)


## deploy guestbook application

You can take a look into my [Helm Chart](https://github.com/akhilrajmailbox/GuestBook/tree/master/guestbook). 

There are lots of custom parameters I configured in order to customise the deployment with your needs, but for this demo, you don't need to do any parameter customisation and by default I gave all required parameters to the helm chart.

In the coming steps (Blue/Green Deployment and Canary Deployment), you are going to use the same docker images and will update this deployment which you are going to deploy from jenkins.

So the flow is something like this : 

```
jenkins cicd build test         :       using helm you will deploy it from jenkins.
Blue/Green Deployment test      :       will deploy new deployment for this app with shell script and then  delete this deployment of jenkins build.
Canary Deployment test          :       deploy new deployment with canary strategy and will delete the deployment which done with Blue/Green.
```

Note : for all of these test, you are going to access the guestbook ui with same url.


For showcase the helm deployment, [Blue/Green Deployment](#Blue-Green-Deployment-of-GuestBook-Application) and [Canary Deployment](#Canary-Deployment-of-GuestBook-Application); I am using my own Custom docker image (Updated the existing docker image for guestbook) for guestbook Deployment.

```
akhilrajmailbox/guestbook:gb-frontend       :       GuestBook Frontend
akhilrajmailbox/guestbook:redis-master      :       Redis Master
akhilrajmailbox/guestbook:redis-slave       :       Redis Slave
```


for configuring the CI/CD from jenkins to deploy the guestbook application in kubernetes cluster, do the following steps :

1. Configure the jenkins from ui. (Assuming that you can do the basic jenkins setup)

2. create jenkins job

3. In `Build` area, choose `execute shell` from `Add build step` and add the build [script](https://raw.githubusercontent.com/akhilrajmailbox/GuestBook/master/scripts/build.sh) as follow.

```
curl -s https://raw.githubusercontent.com/akhilrajmailbox/GuestBook/master/scripts/build.sh | bash
```


Once you deploy the GuestBook successfully from Jenkins, Kubernetes will automatically assign one `NodePort` to your application. Go to jenkins current build console and take the `NodePort` of your deployment. (you may need this for configuring the AWS ELB -- Classic Load balancer)

Assuming that My Deployment get `NodePort : 30427`

Create one classic Load Balancer with following parameters in order to access the GuestBook from outside.


*Health check*

```
Ping Target             TCP:30427
Timeout                 5 seconds
Interval                30 seconds
Unhealthy threshold     2
Healthy threshold       10
```

*listeners*

| Load Balancer Protocol | Load Balancer Port | Instance Protocol | Instance Port | Cipher | SSL Certificate |
| ---------------------- | ------------------ | ----------------- | ------------- | ------ | --------------- |
| http | 80 | http | 30427 | N/A | N/A |


Add your `K8s master` and `K8s slave` instances to the ELB, wait for some time and try to access the guestbook from outside with your AWS ELB address. (incase if you are not able to access it check the security group of your instances and AWS ELB -- ensure that all ports are able to access from outside)

[Table of contents](#table-of-contents)


## prometheus and grafana

Note : Assumning that you are successfully configured the Multi master Kubernetes Cluster and K8s Manager machine to connect to K8s cluster with kubectl and helm commands.

run these two commands to ensure that you are able to access the kubernetes cluster from your `K8s Manager Machine`.

ssh to `K8s Manager Machine`

```
$ kubectl get ns
$ helm repo list
```

If you are not able to connect, go to previous steps and check your configuration.

If you successfully connected to the Kubernetes Cluster, well done..!, you can configure `Prometheus & Grafana`

Here for deploing this application, we are using `helm charts` and `Rook` for `persistent storage`.

As long as we don't have a `persistent storage` in manual configured K8s Cluster, and for some application we may need `persistent storage` inorder to persist the data. For that you need somewhere to store persistent data, and that's not easy to achieve on bare metal. Rook is a promising project aiming to solve this by building a Kubernetes integration layer upon the battle-tested Ceph storage solution.

For configuring the `persistent storage` in our Kubernetes Cluster, run the [rook-block.sh](https://raw.githubusercontent.com/akhilrajmailbox/GuestBook/master/scripts/Rook.sh) scripts.

Clone the [GuestBook]() if you don't have it in k8s manager
```
git clone https://github.com/akhilrajmailbox/GuestBook.git
```


```
$ cd GuestBook/scripts/
$ ./rook-block.sh
```

Once the `Rook` configured, we can deploy our `Prometheus & Grafana` with `persistentVolume`.

Note :: If the `Rook` is not properly configured, then the application will not start and will throw error.


The default username and password for for grafana dashboard is :

| Username | Password |
| -------- | -------- | 
| admin | MyGRafan@ |


You can change the default password for `admin` user by passing you custom password in parameter : `GRAFANA_PASSWORD` on top of the script [prometheus-grafana.sh](https://raw.githubusercontent.com/akhilrajmailbox/GuestBook/master/scripts/prometheus-grafana.sh)



Configure your monitoring Servers on namespace `monitoring` by running the [prometheus-grafana.sh](https://raw.githubusercontent.com/akhilrajmailbox/GuestBook/master/scripts/prometheus-grafana.sh) script from `K8s Manager`

```
$ cd GuestBook/scripts/
$ ./prometheus-grafana.sh
```

Once you deploy the `Prometheus & Grafana` successfully, Kubernetes will automatically assign one `NodePort` to your application. You will get that NodePort from the output of about script with keyword `Grafana NodePort`. (you may need this for configuring the AWS ELB)

Assuming that My Deployment get `NodePort : 30429`

Create one classic Load Balancer with following parameters in order to access the `Grafana` from outside.


*Health check*

```
Ping Target             TCP:30429
Timeout                 5 seconds
Interval                30 seconds
Unhealthy threshold     2
Healthy threshold       10
```


*listeners*

| Load Balancer Protocol | Load Balancer Port | Instance Protocol | Instance Port | Cipher | SSL Certificate |
| ---------------------- | ------------------ | ----------------- | ------------- | ------ | --------------- |
| http | 80 | http | 30429 | N/A | N/A |

[Table of contents](#table-of-contents)



NOTE :: If your application not starting up, then check the logs for the pods. if tha is related to the `pvc`, then check the `rook` deployment, try to recreate it, the previous deployment for rook may be get failed due to lack of resources.

delete all rook configuration and create it

```
kubectl delete -f rook-block/
```

```
kubectl get secret rook-rook-user -oyaml | sed "/resourceVer/d;/uid/d;/self/d;/creat/d;/namespace/d" | kubectl -n monitoring apply -f -
```


## elasticsearch fluentd and kibana

You can deploy and Configure EFK in K8s Cluster by running the [efk.sh](https://raw.githubusercontent.com/akhilrajmailbox/GuestBook/master/scripts/efk.sh) script.


```
$ cd GuestBook/scripts/
$ ./efk.sh
```


Once you deploy the `EFK` successfully, Kubernetes will automatically assign one `NodePort` to your application. You will get that NodePort from the output of about script with keyword `Kibana NodePort`. (you may need this for configuring the AWS ELB)

Assuming that My Deployment get `NodePort : 30434`

Create one classic Load Balancer with following parameters in order to access the `Kibana` from outside.


*Health check*

```
Ping Target             TCP:30434
Timeout                 5 seconds
Interval                30 seconds
Unhealthy threshold     2
Healthy threshold       10
```

*listeners*

| Load Balancer Protocol | Load Balancer Port | Instance Protocol | Instance Port | Cipher | SSL Certificate |
| ---------------------- | ------------------ | ----------------- | ------------- | ------ | --------------- |
| http | 80 | http | 30434 | N/A | N/A |

[Table of contents](#table-of-contents)


## blue-green and canary deployment

In this demo, we are upgrading the Guestbook Deployment which we did before. To show the demo, Im Changing the background color of the application. by default it is white , you saw it already if you deployed the Guestbook and you can access the latest Guestbook application with the same AWS ELB which you created before for the guestbook application.


Please find the below table to understand the `Background Colour` for each strategy


| Deployment strategy | Background Colour |
| ------------------- | ----------------- |
| Blue/Green Deployment | Green |
| Canary Deployment | Blue |



### blue green deployment of guestBook application

Note :: Assuming that the GuestBook Application that you deployed from jenkins is up and running.

You can deploy Latest version of `GuestBook` application in K8s Cluster by running the [blue-green.sh](https://raw.githubusercontent.com/akhilrajmailbox/GuestBook/master/scripts/blue-green.sh) script.

```
$ cd GuestBook/scripts/
$ ./blue-green.sh
```

Once the deployment done with the `blue-green.sh` script, try to access the guestbook application with your Load Balancer, refresh many time to reflect your changes, or try from `incognito` to see the latest changes (green background colour) without any downtime.



### canary deployment of guestBook application

Note :: Assuming that the GuestBook Application is up and running with latest changes that you have done with `blue / green deployment`.


You can deploy Latest version of `GuestBook` application in K8s Cluster by running the [canary.sh](https://raw.githubusercontent.com/akhilrajmailbox/GuestBook/master/scripts/canary.sh) script.


This script have 2 option, you must have to pass anyone of this option to run this script.

```
deploy      : 	Deploy Canary Release along with running stable release in ratio of 3:2 [stable:canary]
rollout     : 	Delete Old release (stable release) and scale up canary release, now canary release become new stable release
```


#### steps

1. run the script with deploy option, tjhis will deploy canary release along with stable release. So each release that will receive the live traffic.

```
$ cd /GuestBook/scripts/
$ ./canary.sh -o deploy
```

Refresh your web page many time to see the changes, you can notice the background colour will change between `green and blue`.

2. In production, or in any other environment where we are using `canary strategy` to deploy, Once you’re confident, you can promote the `canary release` as the `new application release` (new stable release) and remove the old stable release.

for that you can use the following command

```
$ cd GuestBook/scripts/
$ ./canary.sh -o rollout
```

[Table of contents](#table-of-contents)
