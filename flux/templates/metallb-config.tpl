apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: metallb-config
data:
  config: |
    address-pools:
    - addresses:
      - kind_lb_range
      name: default
      protocol: layer2
