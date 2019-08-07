# guestbook: an example chart for educational purpose.

This chart provides example of some of the important features of Helm.

The chart installs a [guestbook](https://github.com/kubernetes/examples/tree/master/guestbook) application.

## Installing the Chart

Add the repository to your local environment:
```
$ helm repo add helm-repo https://akhilrajmailbox.github.io/GuestBook/docs
```

To install the chart with your preference of release name, for example, `my-app`:

```
$ helm install --namespace development helm-repo/guestbook --name my-app
```

### Uninstalling the Chart

To completely uninstall/delete the `my-app` deployment:

```
$ helm delete --purge my-app
$ helm repo remove helm-repo
$ helm repo list
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `replicaCount`         | Replicas for guestbook Deployment                                | `3`                                         |
| `version`               | demostrate Blue/Green Deployment (background colour)                                      | `while`                                                     |
| `image.frontend.repository`         | frontend Image repository                                | `akhilrajmailbox/guestbook`                                         |
| `image.frontend.tag`                | frontend Image tag                                       | `gb-frontend`                                                       |
| `image.frontend.pullPolicy`         | frontend Image pull policy                               | `Always`                                                   |
| `image.redismaster.repository`         | redismaster Image repository                                | `akhilrajmailbox/guestbook`                                         |
| `image.redismaster.tag`                | redismaster Image tag                                       | `redis-master`                                                       |
| `image.redismaster.pullPolicy`         | redismaster Image pull policy                               | `Always`                                                   |
| `image.redismslave.repository`         | redismslave Image repository                                | `akhilrajmailbox/guestbook`                                         |
| `image.redismslave.tag`                | redismslave Image tag                                       | `redis-slave`                                                       |
| `image.redismslave.pullPolicy`         | redismslave Image pull policy                               | `Always`                                                   |
| `resources.frontend.cpu`       | cpu for frontend                             | `100m`                                                     |
| `resources.frontend.memory`               | memory for frontend                                       | `100Mi`                                                     |
| `resources.redismaster.cpu`       | cpu for redismaster                             | `100m`                                                     |
| `resources.redismaster.memory`               | memory for redismaster                                       | `100Mi`                                                     |
| `resources.redismslave.cpu`       | cpu for redismslave                             | `100m`                                                     |
| `resources.redismslave.memory`               | memory for redismslave                                       | `100Mi`                                                     |
| `service.frontend.type`             | frontend Service type                                    | `NodePort`                                             |
| `service.frontend.port`             | frontend Service port                                    | `80`                                                     |
| `service.redismaster.type`             | redismaster Service type                                    | `ClusterIP`                                             |
| `service.redismaster.port`             | redismaster Service port                                    | `6379`                                                     |
| `service.redismslave.type`             | redismslave Service type                                    | `ClusterIP`                                             |
| `service.redismslave.port`             | redismslave Service port                                    | `6379`                                                     |


Specify each parameter using the `--set [key=value]` argument to `helm install`. For example,

```
$ helm install helm-repo/guestbook --set service.port=8080
```



### This is an example charts repository.

How It Works

Create github repository and create docs folder in root directory.

The docs folder contains index.html file

set up GitHub Pages to point to the docs folder. 



From there, I can create and publish docs like this:


```
$ helm create guestbook
$ helm package guestbook
$ mv guestbook-0.1.0.tgz docs
$ helm repo index docs --url https://akhilrajmailbox.github.io/GuestBook/docs
$ git add -i
$ git commit -av
$ git push origin master
```

add helm repo to your system and install.
```
helm repo add helm-repo https://akhilrajmailbox.github.io/GuestBook/docs
```