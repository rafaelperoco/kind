# kind
Kind with extra tools for development environments

### Features
- Calico CNI
- MetalLB for LoadBalancing
- Ingress NGINX
- Linkerd for Service Discovery and service mesh
- Example pod with installed ingress entrypoint
### Dependencies
- jq - Command line JSON processor
- openssl - Command line SSL/TLS tool
- [Docker](https://docs.docker.com/get-docker/)
- [KinD](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [Helm](https://helm.sh/docs/intro/install/#from-script)
## Creating your kind clusters
```shell
./createCluster.sh
```
## Checking your created clusters
```shell
kind get clusters
```
## Deleting your created clusters
```shell
kind delete clusters <clusterName>
```