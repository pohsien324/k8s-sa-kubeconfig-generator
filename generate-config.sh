#!/bin/bash

echo -n "Create a new ServiceAccount? (y/n):  "
read answer

echo -n "Input the ServiceAccount name:  "
read saname

echo -n "Input the API Server URL (https://...:6443):  "
read apiurl

# Create ServiceAccount
if [ "$answer" = "y" ]
then
    kubectl create serviceaccount $saname -n kube-system
    printf "\nThe ServiceAccount $saname has been created Successfully.\n"
fi

# Create ClusterRolebinding
kubectl create clusterrolebinding cluster-admin-$saname --clusterrole=cluster-admin --serviceaccount=kube-system:$saname

# Get the ServiceAccount's Token Name (Secret)
secret=$(kubectl get sa $saname -o yaml -n kube-system | grep -o "$saname-token-.*" | tail -n1)
printf "Get the sercret name: %s" $secret

# Get the Token value
token=$(kubectl get secret/$secret -o jsonpath='{.data.token}' -n kube-system | base64 --decode)

# Set cluster for config
kubectl config --kubeconfig=myconfig set-cluster my-k8s-cluster --server $apiurl --insecure-skip-tls-verify

# Set credentials for config
kubectl config --kubeconfig=myconfig set-credentials $saname --token=$token

# Set context name for config
kubectl config --kubeconfig=myconfig set-context k8s-admin --cluster my-k8s-cluster --user $saname

# Set current context for config
kubectl config --kubeconfig=myconfig  use-context k8s-admin

printf "\n.kubeconfig has been created Successfully."
printf "\nPlease use the following commands to verify the authorization:"
printf "\n\n\n\t export KUBECONIFG=myconfig \n\n\n"


