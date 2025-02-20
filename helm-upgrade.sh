#!/bin/bash

usage() {
    echo "Usage: "
    echo "$0 [-s pki-vault-service]
    [-v v0.1.0]
    [-n vault]
    [-h]" 1>&2;
    echo "-s : The name of the microservice"
    echo "-v : The version of the microservice"
    echo "-n : The namespace of the microservice"
    echo "-h : display help"
    exit 1;
}

microservice=""
version=""
namespace=""

while getopts ":s:v:n:" option;
do case "${option}" in
    s)
        microservice=${OPTARG}
        ;;
    v)
        version=${OPTARG}
        ;;
    n)
        namespace=${OPTARG}
        ;;
    \?)
        usage
        ;;
    esac
done

currentContext=$(kubectl config current-context)

[[ "$microservice" == "" || "$version" == "" || "$namespace" == "" ]] && usage

release=$(helm list -n $namespace | grep -E "[[:space:]]${microservice}-helm" | head -1 | cut -f1)
echo "Release: $release"

HELM_EXPERIMENTAL_OCI=1 helm upgrade $release oci://nexuszolara.me/zolara-microservice/${microservice}-helm --version $version -n $namespace --reuse-values --set image.tag=$version