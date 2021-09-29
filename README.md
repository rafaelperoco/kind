<!-- TOC -->

- [kind](#kind)
- [OS Supported](#os-supported)
- [Features](#features)
- [Dependencies](#dependencies)
- [Creating your kind clusters](#creating-your-kind-clusters)
- [Get ingresses](#get-ingresses)
- [Cleanup / Uninstall](#cleanup--uninstall)
  - [Checking your created clusters](#checking-your-created-clusters)
  - [Deleting your created clusters](#deleting-your-created-clusters)

<!-- TOC -->

# kind

Kind with extra tools for development environments

# OS Supported

Tested with the following Operating Systems (OS):

* Red Hat/Centos/Fedora
* Debian/Ubuntu
# Features

* Calico CNI
* OpenEBS for Dynamic Volume Provisioning
* MetalLB for LoadBalancing
* Ingress NGINX with default backend
* Linkerd for Service Discovery and service mesh with dashboard
* Example pod with installed ingress entrypoint
# Dependencies

Install dependecies following the instructions on the [REQUIREMENTS.md](REQUIREMENTS.md) file.

* jq - Command line JSON processor
* openssl - Command line SSL/TLS tool
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Docker](https://docs.docker.com/get-docker/)
* [KinD](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
* [Helm](https://helm.sh/docs/intro/install/#from-script)
* [linkerd](https://linkerd.io/docs/latest/install/)

# Creating your kind clusters

```shell
./createCluster.sh
```

# Get ingresses

Get the addresses of the applications to be accessed in the browser:

```shell
kubectl get ingress -A
```

Linkerd default username and password:

```shell
user: admin
password: admin
```

# Cleanup / Uninstall

## Checking your created clusters

```shell
kind get clusters
```
## Deleting your created clusters

```shell
kind delete clusters <clusterName>
```