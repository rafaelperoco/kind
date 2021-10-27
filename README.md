<!-- TOC -->

- [kind](#kind)
- [Hardware requirements](#hardware-requirements)
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

[KinD](https://kind.sigs.k8s.io) (Kubernetes in Docker) with extra tools for development environments.

```diff
- Attention:
```
> Despite the name, the developers of this project did not create the [kind](https://github.com/kubernetes-sigs/kind) tool. We just automate the creation of a Kubernetes cluster using ``kind`` and deploy some useful services to the development/test environment.

# Hardware requirements

A cluster with 2 nodes requires (not counting the amount of hardware resources needed to run the applications you intend to deploy on the cluster).

* CPU: 1vCPU with 2 GHz
* Memory: 2 GB
* HD: 20 GB

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
* Istio for Service Discovery and service mesh with dashboard
* Example pod with installed ingress entrypoint

# Dependencies

Install dependecies following the instructions on the [REQUIREMENTS.md](REQUIREMENTS.md) file.

* jq - Command line JSON processor
* openssl - Command line SSL/TLS tool
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [docker](https://docs.docker.com/get-docker/)
* [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
* [helm](https://helm.sh/docs/intro/install/#from-script)
* [linkerd](https://linkerd.io/docs/latest/install/)
* [istio](https://istio.io/latest/docs/setup/install/)

# Creating your kind clusters

Create a kind cluster using the following commands:

Linkerd for Service Discovery and Service Mesh
```shell
chmod +x createCluster.sh
./createCluster.sh
```
Istio for Service Discovery and Service Mesh
```shell
chmod +x ./istio/createClusterWithIstio.sh
./istio/createClusterWithIstio.sh
```

Wait a few minutes (about 10 to 15 minutes) while the cluster is being created and services are being deployed.

# Access Application (Linkerd) 

Get the addresses of the applications to be accessed in the browser:

```shell
kubectl get ingress -A
```

Linkerd default username and password:

```shell
user: admin
password: admin
```

# Access Application (Istio)

If using'createClusterWithIstio.sh ' to access the application, just through the IP provided by metallb. 

To get the addresses of the applications, just find the IP:

```shell
kubectl get services --namespace istio-system istio-ingressgateway --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
```
Ex: curl http://172.18.0.130/productpage

# Cleanup / Uninstall

## Checking your created clusters

Get the list of clusters created with kind:

```shell
kind get clusters
```

## Deleting your created clusters

Remove a kind cluster:

```shell
kind delete clusters <clusterName>
```

Remove all clusters created with kind:

```shell
kind delete clusters $(kind get clusters)
```
