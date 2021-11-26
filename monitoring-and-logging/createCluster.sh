#!/bin/bash -x

# Generate cluster name
CLUSTER_NAME=cluster-$(openssl rand -hex 3)

# Create cluster
kind create cluster --name $CLUSTER_NAME --config cluster.yaml

# Get default gateway interface
KIND_ADDRESS=$(docker network inspect kind | jq '.[].IPAM | .Config | .[0].Subnet' | cut -d \" -f 2 | cut -d"." -f1-3)

# Radomize Loadbalancer IP Range
KIND_ADDRESS_END=$(shuf -i 100-150 -n1)

# Create address range
KIND_LB_RANGE=$(echo $KIND_ADDRESS.$KIND_ADDRESS_END)

# Transform IP address to Hexadecimal
IP_HEX=$(echo $KIND_LB_RANGE | awk -F '.' '{printf "%08x", ($1 * 2^24) + ($2 * 2^16) + ($3 * 2^8) + $4}')

# Ingress Address
KIND_INGRESS_ADDRESS=$(echo $IP_HEX.nip.io)

# Setting up templates

# Install and upgrade Helm repositories
helm repo add projectcalico https://docs.projectcalico.org/charts
helm repo add openebs-nfs https://openebs.github.io/dynamic-nfs-provisioner
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add metallb https://metallb.github.io/metallb
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add linkerd https://helm.linkerd.io/stable
helm repo add podinfo https://stefanprodan.github.io/podinfo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Calico and check if it is installed
helm install calico projectcalico/tigera-operator \
  --namespace calico-system \
  --create-namespace \
  --version v3.21.1 \
  --wait
# Install Dynamic Volume Provisioner
helm install openebs openebs-nfs/nfs-provisioner \
  --namespace openebs --create-namespace \
  --wait
# Install metrics-server and check if it is installed
helm install metrics-server bitnami/metrics-server \
  --namespace kube-system \
  --set rbac.create=true \
  --set extraArgs.kubelet-insecure-tls=true \
  --set apiService.create=true \
  --wait
# Install MetalLB and check if it is installed
helm upgrade --install metallb metallb/metallb \
  --create-namespace \
  --namespace metallb-system \
  --set "configInline.address-pools[0].addresses[0]="$KIND_LB_RANGE/32"" \
  --set "configInline.address-pools[0].name=default" \
  --set "configInline.address-pools[0].protocol=layer2" \
  --set controller.nodeSelector.role=loadbalancer \
  --set "controller.tolerations[0].key=node-role.kubernetes.io/master" \
  --set "controller.tolerations[0].effect=NoSchedule" \
  --set speaker.tolerateMaster=true \
  --set speaker.nodeSelector.role=loadbalancer \
  --wait

# Install Ingress and check if it is installed
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.nodeSelector.role=loadbalancer \
  --set "controller.tolerations[0].key=node-role.kubernetes.io/master" \
  --set "controller.tolerations[0].effect=NoSchedule" \
  --set podLabels.role=loadbalancer \
  --set service.annotations={metallb.universe.tf/address-pool=default} \
  --set defaultBackend.enabled=true \
  --set defaultBackend.image.repository=rafaelperoco/default-backend,defaultBackend.image.tag=1.0.0 \
  --set controller.watchIngressWithoutClass=true \
  --wait

# Install Loki and check if it is installed
helm upgrade --install loki grafana/loki-stack \
  --namespace logging \
  --create-namespace \
  -f logging.yaml \
  --wait

# Install Prometheus Stack and check if it is installed
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.ingress.enabled=true \
  --set grafana.ingress.hosts={grafana.$KIND_INGRESS_ADDRESS} \
  --set prometheus.ingress.enabled=true \
  --set prometheus.ingress.hosts={prometheus.$KIND_INGRESS_ADDRESS} \
  --set prometheus.ingress.paths={"/"} \
  -f monitoring.yaml \
  --wait

# Install Podinfo (example project) and check if it is installed
helm upgrade --install --wait frontend \
  --namespace default \
  --set replicaCount=2 \
  --set backend=http://backend-podinfo:9898/echo podinfo/podinfo \
  --set ingress.enabled=true \
  --set "ingress.hosts[0].host=podinfo.$KIND_INGRESS_ADDRESS" \
  --set "ingress.hosts[0].paths[0].path=/" \
  --set "ingress.hosts[0].paths[0].pathType=ImplementationSpecific" \
  --set ingress.className=nginx
  --wait

helm upgrade --install --wait backend \
  --namespace default \
  --set redis.enabled=true podinfo/podinfo \
  --wait

# Apply custom settings
# kubectl apply --recursive -f custom/
