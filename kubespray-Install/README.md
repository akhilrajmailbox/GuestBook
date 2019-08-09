[Go Back](https://github.com/akhilrajmailbox/GuestBook)

# Kubespray with Ansible


There are multiple ways to set up a Kubernetes Cluster. One of them is using Kubespray which uses Ansible.

I have an AWS account, I will be using it to spin up 5 Ubuntu machines. (2 master 2 node cluster and 1 K8s Manager [ Machine for accessing all server and configuring Kubespray ])

OS: Ubuntu 16.04
Number of Instances: 5
Configure all Instances with same ssh key
The ssh user for ubuntu system in AWS have passwordless sudo permission
configure Security group for all vm
 1. expose all inbound and outbound within the vpc
 2. expose 22 ports externally to access the vm over ssh
Copy ssh key "pem file" [passwordless login between all servers with Default user is "ubuntu"] to the K8s Manager
Configure one Load Balancer for accessing the kubernetes clister from outside


Installations

Tools to be installed on the K8s Manager

    Ansible v2.4
    Python-netaddr
    Jinja 2.9

run the following commands to configure the K8s Manager.
This script will download and configure all the dependencies and will clone the latest code for [kubespray](https://github.com/kubernetes-incubator/kubespray.git)

login to K8s Manager Machine over ssh, use the default user (ubuntu). then run the following commands

```
$ git clone https://github.com/akhilrajmailbox/GuestBook.git
$ cd GuestBook/kubespray-Install/
$ ./K8s_Manager.sh
```

Note:   While installing all requirements packages, if you get errors related to “requests” package, follow the steps below:

-  Download the latest “requests” [package](https://pypi.org/project/requests/#files) (.tar.gz file)

-  Untar the tar file and run command ---  ```python setup.py install```

-  If the requests issue still doesn't resolve, go to "/usr/lib/python2.7/site-packages" and rename all requests files and folders there, and re-run the requirements.txt deployment.




take all Instances Ip Addresses and save it for next steps :

| Instances                  | IP Address                                      | 
| -----------------------    | ---------------------------------------------   |
|  k8s-manager   |  172.31.33.234  |
|  k8s-master-1   |  172.31.33.235  |
|  k8s-master-2    |  172.31.45.66  |
|  k8s-node-1   |  172.31.36.146  |
|  k8s-node-2   |  172.31.38.245  |
|  k8s-node-3   |  172.31.38.147  |
|  k8s-node-4   |  172.31.38.249  |




## Load-Balancer (Classic Load balancer)

If you are using AWS / GCP or any other cloud services, then use their Load Balancer (ELB in AWS), because manual configure nginx / apache2 proxy will serve same like cloud Load Balancer but not an HA.


We have to configure the Classic Load balancer in aws to get the CNAME for Load Balancer. this url required for configurinmg the cluster (need to add this domain address as a "supplementary_addresses_in_ssl_keys" for ssl certificates of cluster)

Create one classic Load Balancer in AWS before start configuring the kubernetes cluster with following  parameters.


listeners >>

| Load Balancer Protocol | Load Balancer Port | Instance Protocol | Instance Port | Cipher | SSL Certificate |
| ---------------------- | ------------------ | ----------------- | ------------- | ------ | --------------- |
| tcp | 433 | tcp | 6443 | N/A | N/A |

 
Add the 2 master instances to the ELB, now it will show unhealthy. don't worry it will come up.


## Copy the key file into the k8s Manager

Navigate into the kubespray folder

```
$ cd kubespray
```

Now you can either copy the pem file which you used to create the instances on AWS into this directory from your local machine OR just copy the contents into a new file on the k8s Manager.

View the contents of K8s.pem file on your local machine using the command line.

```
$ cat K8s.pem
```

Copy the contents of the file

Connect / ssh onto the k8s Manager

On k8s Manager

```
$ cd kubespray
$ vim K8s.pem
```

This will create and open a new file by the name K8s.pem. Paste the contents here.

To save Hit Esc key and then type :wq

Change permissions of this file.

```
$ chmod 600 K8s.pem
```


## Modify the inventory file as per your cluster

Copy the inventory sample inventory and create your own duplicate as per your cluster

```
$ cd kubespray
$ cp -rfp inventory/sample inventory/mycluster
```


### Configure Load Balancer address in "k8s-cluster.yml" for ssl validation with [ELB we created before](#Load-Balancer) 

```
$ vim inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml
```
search for "supplementary_addresses_in_ssl_keys" in the file and update the line with your ELB address as follow
assuming the my ELB address is  : ```k8s-master-876887687.us-east-1.elb.amazonaws.com```

```
supplementary_addresses_in_ssl_keys: [k8s-master-876887687.us-east-1.elb.amazonaws.com]
```

### Configure ceph-commmon in all master and workewr node of your kubernetes cluster for using rook

```
vim roles/bootstrap-os/tasks/main.yml
```

search for the keyword : `ceph-common`

comment the line `when: rbd_provisioner_enabled|default(false)` , so the manifest look like this :

```
........................
...................
........................
- name: "Install ceph-commmon package"
  package:
    name:
      - ceph-common
    state: present
#  when: rbd_provisioner_enabled|default(false)
........................
...................
........................
```

By using kubespray We can configure helm, metrics server, private registry etc... but we are not going to use it and we are installing and configuring everything from scrach...


Since I will be creating a 2 master 2 node cluster, I have accordingly updated the inventory file. Update Ansible inventory file with inventory builder. Run the following commands to update the inventory file

Replace the sample IP’s with Private IP’s of the newly created instances before running the command

`example :: declare -a IPS=(k8s-master-1 k8s-master-2 k8s-node-1 k8s-node-2)`

```
$ cd kubespray
$ declare -a IPS=(172.31.33.235 172.31.45.66 172.31.36.146 172.31.38.245)
$ CONFIG_FILE=inventory/mycluster/hosts.ini python3 contrib/inventory_builder/inventory.py ${IPS[@]}
$ mv inventory/mycluster/hosts.ini inventory/mycluster/hosts.yaml
```

so the "inventory/mycluster/hosts.yaml" become like the following :

```
all:
  hosts:
    node1:
      ip: 172.31.33.235
      access_ip: 172.31.33.235
      ansible_host: 172.31.33.235
    node2:
      ip: 172.31.45.66
      access_ip: 172.31.45.66
      ansible_host: 172.31.45.66
    node3:
      ip: 172.31.36.146
      access_ip: 172.31.36.146
      ansible_host: 172.31.36.146
    node4:
      ip: 172.31.38.245
      access_ip: 172.31.38.245
      ansible_host: 172.31.38.245
    node5:
      ip: 172.31.36.146
      access_ip: 172.31.36.146
      ansible_host: 172.31.36.147
    node6:
      ip: 172.31.38.245
      access_ip: 172.31.38.245
      ansible_host: 172.31.38.149
  children:
    kube-master:
      hosts:
        node1:
        node2:
    kube-node:
      hosts:
        node1:
        node2:
        node4:
        node3:
        node5:
        node6:
    etcd:
      hosts:
        node1:
        node2:
        node3:
    k8s-cluster:
      children:
        kube-master:
        kube-node:
    calico-rr:
      hosts: {}
```



## Deploy Kubespray with Ansible Playbook

```
$ ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml --private-key=K8s.pem -b
```


## Check your Deployment
Now SSH into the Master Node and check your installation

```
$ sudo su
$ export KUBECONFIG=/etc/kubernetes/admin.conf
```

Command to fetch nodes

```
$ kubectl get nodes
```

Command to fetch services in the namespace ‘kube-system’

```
$ kubectl -n kube-system get services
```

Wohhoooo!!! We are done!!!



Copy the "/etc/kubernetes/admin.conf" from your master node and paste it "K8s-Manager-home-folder/.kube/config" of K8s-Manager server

replace the `server:` entry with your ELB address. so the config file in K8s-Manager server should look like this :

```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FU.......
    ...............................................................
    .......................WT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    server: https://k8s-master-876887687.us-east-1.elb.amazonaws.com
  name: cluster.local
  .......................
  .....................
  .......................
```


Check the load balancer configuration by trying to access the K8s cluster.

Exit from the K8s-Manager server terminal, then ssh to that machine again. then run the following commands to test the K8s Cluster....

```
$ kubectl get nodes
```

If you are able to access the kubernetes Cluster, then you can configure helm in in the cluster by running the script [helm-configure.sh](https://raw.githubusercontent.com/akhilrajmailbox/GuestBook/master/scripts/helm-configure.sh).


```
$ cd scripts/
$ ./helm-configure.sh
```


## Additional steps might be needed while working with K8s cluster (Not Required for this Demo)

1.  Adding a new node (node5 - 172.31.38.247) to a cluster (add these lines at the bottom of this section)

-  Add the server node5 to “inventory/mycluster/hosts.yaml” file
  In “[all]” section:

```
    node5:
      ip: 172.31.38.247
      access_ip: 172.31.38.247
      ansible_host: 172.31.38.247
```

- In “[kube-node]” section: (add these lines at the bottom of this section)

```
node5
```

- Now run the following command to scale your cluster:
```
$ ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml --private-key=K8s.pem -b
```


2. Removing a new node (node5 - 172.31.38.247) from cluster:

- In “[all]” section: keep the node information

- In the “[kube-node]” section keep ONLY the node server which needs to be removed from cluster. So in this example, we will keep only “node5” mentioned. 

```
[kube-node]
node5
```
- Now run the following command to scale your cluster:
```
$ ansible-playbook -i inventory/mycluster/hosts.yaml remove-node.yml --private-key=K8s.pem --extra-vars "node=node5" -b
```

3. Reset the entire cluster for fresh installation:

Keep the “hosts.ini” updated properly with all servers mentioned in the correct sections, and run the following command:

```
$ ansible-playbook -i inventory/mycluster/hosts.yaml reset.yml --private-key=K8s.pem -b
```

[Go Back](https://github.com/akhilrajmailbox/GuestBook)