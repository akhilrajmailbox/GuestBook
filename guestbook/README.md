# guestbook: an example chart for educational purpose.

This chart provides example of some of the important features of Helm.

The chart installs a [guestbook](https://github.com/kubernetes/examples/tree/master/guestbook) application.

## Installing the Chart

Add the repository to your local environment:
```
$ helm repo add helm-repo https://akhilrajmailbox.github.io/GuestBook/docs
```

To install the chart with the default release name:

```
$ helm install helm-repo/guestbook
```

To install the chart with your preference of release name, for example, `my-app`:

```
$ helm install helm-repo/guestbook --name my-app
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
| `image.repository`         | Image repository                                | `gcr.io/google-samples/gb-frontend`                                         |
| `image.tag`                | Image tag                                       | `v4`                                                       |
| `image.pullPolicy`         | Image pull policy                               | `Always`                                                   |
| `service.type`             | Service type                                    | `NodePort`                                             |
| `service.port`             | Service port                                    | `80`                                                     |
| `resources.cpu`       | cpu for guestbook                             | `100m`                                                     |
| `resources.memory`               | memory for guestbook                                       | `100Mi`                                                     |

Specify each parameter using the `--set [key=value]` argument to `helm install`. For example,

```
$ helm install helm-repo/guestbook --set service.port=8080
```
