# kind
Kind with extra tools for development environments

# Tested with the following OS:
## - rhl/centos/fedora
## - debian/ubuntu

### Features
- Calico CNI
- MetalLB for LoadBalancing
- Ingress NGINX with default backend
- Linkerd for Service Discovery and service mesh with dashboard
- Example pod with installed ingress entrypoint
### Dependencies
- jq - Command line JSON processor
- openssl - Command line SSL/TLS tool
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Docker](https://docs.docker.com/get-docker/)
- [KinD](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [Helm](https://helm.sh/docs/intro/install/#from-script)
- [linkerd](https://linkerd.io/docs/latest/install/)
## Creating your kind clusters
```shell
./createCluster.sh
```
## Get ingresses
```shell
kubectl get ingress -A
```
### Some information
Linkerd default username and password
```shell
admin / admin
```

# Cleanup
## Checking your created clusters
```shell
kind get clusters
```
## Deleting your created clusters
```shell
kind delete clusters <clusterName>
```