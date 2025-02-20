#!/bin/bash

# Select kube context to use
kubecontext=""
select ctx in $(kubectl config get-contexts -oname); do
  kubecontext="$ctx"
  break
done

# Init variables
envPath="environment/$kubecontext"
envName="$kubecontext"
if [[ "$kubecontext" == *"local"* ]]; then
  echo "Using minikube context"
  envPath="environment/local"
  envName="local"
fi
valuesPath="$envPath/values"

echo "Deploying valuesPath=$valuesPath"

# Test connection to the cluster
echo "Testing connection to the cluster ..."
if ! kubectl --context $kubecontext get pods > /dev/null 2>&1
then
    echo "----------------------------------"
    echo "ERROR : Failed to connect to the cluster"
    echo "Please verify your .kube/config file for kubernetes context $kubecontext"
    exit 1
else
    echo "Succeed to contact the cluster"
fi

# Update versions configmap
kubectl --context $kubecontext create cm deploy -n default --dry-run=client -oyaml --from-literal=last-deploy="$(whoami) $(date)" | kubectl --context $kubecontext apply -f -
echo
echo "Deploying microservices-version configmap:"
echo
kubectl --context $kubecontext get configmap -n api-$deploymentColor microservices-versions > /dev/null 2>&1 && kubectl --context $kubecontext delete configmap -n api microservices-versions
kubectl --context $kubecontext create configmap microservices-versions --from-file=microservices_version.config=$envPath/microservices_version.env -n api

# Run skaffold
if [[ ! -f "$envPath/microservices_version.env" ]]; then
  echo "ERROR: Environment file $envPath/microservices_version.env not found!"
  exit 1
fi

set -o allexport; source "$envPath/microservices_version.env"; set +o allexport

echo "Starting skaffold deployment"

HELM_EXPERIMENTAL_OCI=1 \
SK_ENV_NAME="$envName" \
SK_VALUES_PATH="$valuesPath" \
skaffold deploy --kube-context=$kubecontext