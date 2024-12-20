#!/bin/bash

database_config="postgres-config"
database_credentials="postgres-credentials"

database_username_path="./database/username"
database_password_path="./database/password"
database_init_file_path="./database/init.sql"

echo "----------------------------------"
echo "Create namespaces"
kubectl apply -f ./namespaces.yaml


echo "----------------------------------"
echo "Create PersistentVolumes"
kubectl apply -f ./persistent-volume

echo "----------------------------------"
echo "Create Configmaps"
kubectl create configmap $database_config --from-file=init.sql=$database_init_file_path -n database --dry-run=client -oyaml | kubectl apply -f -

echo "----------------------------------"
echo "Create Secrets"
echo "In namespace database"
kubectl create secret generic $database_credentials --from-file=username=$database_username_path --from-file=password=$database_password_path -n database --dry-run=client -oyaml | kubectl apply -f -