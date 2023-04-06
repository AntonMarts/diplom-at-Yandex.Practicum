# Argo CD Chart

A Helm chart for Argo CD, a declarative, GitOps continuous delivery tool for Kubernetes.

В данной папке расположены файлы стандартного чарта из официального репозитория Argo CD

```console
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```