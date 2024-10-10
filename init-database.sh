#!/bin/bash

echo "Initializing database on the kube cluster"
kubectl apply -f ./database/postgres.yml