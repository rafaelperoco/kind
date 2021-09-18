#!/bin/bash -x
./certs.sh
# Gen cluster name
CLUSTER_NAME=cluster-$(openssl rand -hex 3)
# Create cluster
kind create cluster --name $CLUSTER_NAME --config cluster.yaml
# Get default gateway interface
KIND_ADDRESS=$(docker network inspect kind | jq '.[].IPAM | .Config | .[0].Subnet' | cut -d \" -f 2 | cut -d"." -f1-3)
# Create address range
KIND_LB_RANGE=$(echo $KIND_ADDRESS.100)
# Transform IP to Hex
IP_HEX=$(echo $KIND_LB_RANGE | awk -F '.' '{printf "%08x", ($1 * 2^24) + ($2 * 2^16) + ($3 * 2^8) + $4}')

# Install repos
helm repo add projectcalico https://docs.projectcalico.org/charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add metallb https://metallb.github.io/metallb
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add linkerd https://helm.linkerd.io/stable
helm repo add podinfo https://stefanprodan.github.io/podinfo
helm repo update

# Install Calico and check if it is installed
helm install calico projectcalico/tigera-operator \
  --namespace calico-system \
  --create-namespace \
  --version v3.20.0
kubectl wait --for condition=Available=True deploy/tigera-operator -n tigera-operator --timeout -1s

# Install metrics-server and check if it is installed
helm install metrics-server bitnami/metrics-server \
  --namespace kube-system \
  --set rbac.create=true \
  --set extraArgs.kubelet-insecure-tls=true \
  --set apiService.create=true
kubectl wait --for condition=Available=True deploy/metrics-server -n kube-system --timeout -1s

# Install MetalLB and check if it is installed
helm upgrade --install metallb metallb/metallb \
  --create-namespace \
  --namespace metallb-system \
  --set "configInline.address-pools[0].addresses[0]="$KIND_LB_RANGE/32"" \
  --set "configInline.address-pools[0].name=default" \
  --set "configInline.address-pools[0].protocol=layer2" \
  --set controller.nodeSelector.nodeapp=loadbalancer \
  --set "controller.tolerations[0].key=node-role.kubernetes.io/master" \
  --set "controller.tolerations[0].effect=NoSchedule" \
  --set speaker.tolerateMaster=true \
  --set speaker.nodeSelector.nodeapp=loadbalancer
kubectl wait --for condition=Available=True deploy/metallb-controller -n metallb-system --timeout -1s
kubectl wait --for condition=ready pod -l app.kubernetes.io/component=controller -n metallb-system --timeout -1s

# Install Ingress and check if it is installed
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.nodeSelector.nodeapp=loadbalancer \
  --set "controller.tolerations[0].key=node-role.kubernetes.io/master" \
  --set "controller.tolerations[0].effect=NoSchedule" \
  --set podLabels.nodeapp=loadbalancer \
  --set "service.annotations.metallb.universe.tf/address-pool=default"
kubectl wait --for condition=Available=True deploy/ingress-nginx-controller -n ingress-nginx --timeout -1s

helm upgrade --install linkerd linkerd/linkerd2 \
  --create-namespace \
  --namespace linkerd-system \
  --set-file identityTrustAnchorsPEM=ca.crt \
  --set-file identity.issuer.tls.crtPEM=issuer.crt \
  --set-file identity.issuer.tls.keyPEM=issuer.key \
  --set identity.issuer.crtExpiry=$(date -d '+8760 hour' +"%Y-%m-%dT%H:%M:%SZ")

kubectl wait --for condition=ready pod -l deploy/linkerd2 -n linkerd2 --timeout -1s

# Install Podinfo (example project) and check if it is installed
helm upgrade --install --wait frontend \
  --namespace default \
  --set replicaCount=2 \
  --set backend=http://backend-podinfo:9898/echo podinfo/podinfo \
  --set ingress.enabled=true \
  --set "ingress.hosts[0].host=$IP_HEX.nip.io" \
  --set "ingress.hosts[0].paths[0].path=/" \
  --set "ingress.hosts[0].paths[0].pathType=http" \
  --set linkerd.profile.enabled=true \
  --set ingress.className=nginx
kubectl wait --for condition=Available=True deploy/frontend-podinfo -n default --timeout -1s

helm upgrade --install --wait backend \
  --namespace default \
  --set redis.enabled=true podinfo/podinfo
kubectl wait --for condition=Available=True deploy/backend-podinfo -n default --timeout -1s
kubectl wait --for condition=Available=True deploy/backend-podinfo-redis -n default --timeout -1s