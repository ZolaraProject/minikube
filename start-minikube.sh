#!/bin/bash

set -e
set -x

minikube start \
    -p zolara \
    --memory=2048m \
    --cpus=2 \
    --driver=docker \
    --disable-metrics \
    # --apiserver-ips=20.160.221.93 \
    # --apiserver-name=apiserverzolara.me \
    # --apiserver-port=8445 \
    
minikube -p zolara addons enable ingress