# Kubespray with Ansible


There are multiple ways to set up a Kubernetes Cluster. One of them is using Kubespray which uses Ansible.

I have an AWS account, I will be using it to spin up 5 Ubuntu machines. (2 master 2 node cluster and 1 K8s Manager [ Machine for accessing all server and configuring Kubespray ])

OS: Ubuntu 16.04
Number of Instances: 5
Configure all Instances with same ssh key
Copy ssh key "pem file" [passwordless login between all servers with Default user is "ubuntu"] to the K8s Manager



Installations

Tools to be installed on the K8s Manager

    Ansible v2.4
    Python-netaddr
    Jinja 2.9

run the following commands to configure the K8s Manager.
This script will download and configure all the dependencies and will clone the latest code for [kubespray](https://github.com/kubernetes-incubator/kubespray.git)

```
./base_machine.sh
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
|  k8s-node-2   |  172.31.36.146  |
|  k8s-node-2   |  172.31.38.245  |



## Copy the key file into the k8s Manager
Navigate into the kubespray folder

```
$ cd kubespray
```

Now you can either copy the pem file which you used to create the cluster on AWS into this directory from your local machine OR just copy the contents into a new file on the k8s Manager.

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

Since I will be creating a 2 master 2 node cluster, I have accordingly updated the inventory file. Update Ansible inventory file with inventory builder. Run the following commands to update the inventory file

Replace the sample IP’s with Private IP’s of the newly created instances before running the command

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
  children:
    kube-master:
      hosts:
        node1:
        node2:
    kube-node:
      hosts:
        node3:
        node4:
    etcd:
      hosts:
        node1:
        node2:
    k8s-cluster:
      children:
        kube-master:
        kube-node:
    calico-rr:
      hosts: {}
```



## Deploy Kubespray with Ansible Playbook

```
$ ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml --private-key=K8s.pem --flush-cache -s
```


## Check your Deployment
Now SSH into the Master Node and check your installation

```
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


## Additional steps might be needed while working with K8s cluster

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
$ ansible-playbook -i inventory/mycluster/hosts.yaml scale.yml --private-key=K8s.pem --flush-cache -s
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
$ ansible-playbook -i inventory/mycluster/hosts.yaml remove-node.yml --private-key=K8s.pem --flush-cache -s
```

3. Reset the entire cluster for fresh installation:

Keep the “hosts.ini” updated properly with all servers mentioned in the correct sections, and run   the following command:

```
$ ansible-playbook -i inventory/mycluster/hosts.yaml reset.yml --private-key=K8s.pem --flush-cache -s
```