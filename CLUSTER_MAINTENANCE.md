

Historical:
----------

Cluster setup was done with:

```
az provider register --namespace Microsoft.OperationsManagement
az provider register --namespace Microsoft.OperationalInsights

az aks create --resource-group bl-staging-rg --name bl-staging-cluster --node-count 5 --enable-addons monitoring --generate-ssh-keys

az network public-ip create --resource-group MC_bl-staging-rg_bl-staging-cluster_uksouth --name blStagingPublicIP --sku Standard --allocation-method static

helm --kubeconfig ~/.kube/notch8-bl-stage-config install nginx-ingress ingress-nginx/ingress-nginx --namespace nginx-ingress --set controller.replicaCount=3 --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux --set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux --set controller.service.loadBalan
cerIP="20.90.72.114" --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"="nginx-ingress" --set controller.service.externalTrafficPolicy=Local
```
