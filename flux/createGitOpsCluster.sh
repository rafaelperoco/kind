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

# Installing Cilium CNI
cilium install

# Creating Load Balancer with MetalLB
kubectl create namespace metallb-system
sed "s/\$kind_lb_range/$KIND_LB_RANGE\/32/g" templates/metallb-config.tpl > /tmp/metallb-configmap.yaml
kubectl apply -f /tmp/metallb-configmap.yaml

# Tainting infra node
kubectl taint nodes $(kubectl get nodes -l role=infra -ojson | jq -r '.items[].metadata.name') role=infra:NoSchedule

# Installing Flux V2
flux install --toleration-keys=node-role.kubernetes.io/master

kubectl apply -f ~/Desktop/secret.yaml
kubectl apply -f ~/Desktop/gitrepo.yaml
kubectl apply -f clusters/dev/infra/infra.yaml