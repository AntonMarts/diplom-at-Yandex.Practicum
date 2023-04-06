## Yandex automatic load balancer Helm Chart

1. В данной папке расположены файлы стандартного чарта из официального репозитория yc-alb-ingress

# install helm chart

```shell
kubectl create namespace yc-alb-ingress
export VERSION=v0.1.3
export HELM_EXPERIMENTAL_OCI=1
helm pull --version ${VERSION} oci://cr.yandex/yc/yc-alb-ingress-controller-chart
helm install -n yc-alb-ingress --set folderId=<FOLDER_ID> --set clusterId=<CLUSTER_ID> yc-alb-ingress-controller --set-file saKeySecretKey=sa-key.json ./yc-alb-ingress-controller-chart-${VERSION}.tgz
```
