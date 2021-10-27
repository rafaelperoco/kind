#!/bin/bash -x

# Generate cluster name
CLUSTER_NAME=cluster-$(openssl rand -hex 3)

# Create cluster
kind create cluster --name $CLUSTER_NAME --config cluster.yaml

# Get default gateway interface
KIND_ADDRESS=$(docker network inspect kind | jq '.[].IPAM | .Config | .[0].Gateway' | cut -d \" -f 2 | cut -d"." -f1-3)

# Radomize Loadbalancer IP Range
KIND_ADDRESS_END=$(shuf -i 100-150 -n1)

# Create address range
KIND_LB_RANGE=$(echo $KIND_ADDRESS.$KIND_ADDRESS_END)

# Install and upgrade Helm repositories
helm repo add projectcalico https://docs.projectcalico.org/charts
helm repo add openebs-nfs https://openebs.github.io/dynamic-nfs-provisioner
helm repo add metallb https://metallb.github.io/metallb
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Calico and check if it is installed
helm install calico projectcalico/tigera-operator \
  --namespace calico-system \
  --create-namespace \
  --version v3.20.0
kubectl wait --for condition=Available=True deploy/tigera-operator -n tigera-operator --timeout -1s

# Install Dynamic Volume Provisioner
helm install openebs openebs-nfs/nfs-provisioner \
  --namespace openebs --create-namespace
kubectl wait --for condition=Available=True deploy/openebs-nfs-provisioner -n openebs --timeout -1s

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

# Install kubernetes dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.1.0/aio/deploy/recommended.yaml
kubectl create clusterrolebinding default-admin --clusterrole cluster-admin --serviceaccount=default:default
token=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)
echo "kubectl proxy for access dashboard :)"
echo "Token for login: $token"

# Install Istio
istioctl install \
  --set values.gateways.istio-ingressgateway.nodeSelector.nodeapp=loadbalancer \
  --set "values.gateways.istio-ingressgateway.tolerations[0].key=node-role.kubernetes.io/master" \
  --set "values.gateways.istio-ingressgateway.tolerations[0].effect=NoSchedule" \
  --set "values.gateways.istio-ingressgateway.serviceAnnotations.metallb.universe.tf/address-pool=default" \
  --skip-confirmation

# Add Auto Injection Istio
kubectl label namespace default istio-injection=enabled

# Install Addons Kiali, Prometheus, Grafana, Jaeger and Zipkin
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/addons/kiali.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/addons/grafana.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/addons/jaeger.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/addons/extras/zipkin.yaml

# Book Info Application
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/bookinfo/platform/kube/bookinfo.yaml

# Virtual Service and Gateway
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/bookinfo/networking/bookinfo-gateway.yaml