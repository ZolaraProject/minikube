#!/bin/bash

secrets_path="./secrets" # base path for secrets

harbor_ca="harbor-ca-cert"
harbor_ca_path="./harbor.crt"

redis_credentials="redis-credentials"
redis_password_path="$secrets_path/redis/password"
redis_helm_name="zolara-redis"
redis_helm_path="./redis/redis.yaml"

database_config="postgres-config"
database_credentials="postgres-credentials"
database_username_path="$secrets_path/database/username"
database_password_path="$secrets_path/database/password"
database_init_file_path="./database/init.sql"

jwt_secret_key="jwt-secret"
jwt_secret_key_path="./jwtSecretKey"

echo "----------------------------------"
echo "Copy harbor certificate"
minikube cp -p zolara $harbor_ca_path /etc/docker/certs.d/nexuszolara.me/ca.crt
minikube cp -p zolara $harbor_ca_path /etc/containerd/certs.d/nexuszolara.me/ca.crt
kubectl apply -f kube-daemonset.yaml

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
# echo "Harbor certificate"
# kubectl create secret generic $harbor_ca --from-file=$harbor_ca_path -n kube-system

echo "In namespace database"
kubectl create secret generic $database_credentials --from-file=username=$database_username_path --from-file=password=$database_password_path -n database --dry-run=client -oyaml | kubectl apply -f -
kubectl create secret generic $database_credentials --from-file=username=$database_username_path --from-file=password=$database_password_path -n vault --dry-run=client -oyaml | kubectl apply -f -

echo "In namespace api"
kubectl create secret generic $jwt_secret_key --from-file=jwtSecretKey=$jwt_secret_key_path -n api --dry-run=client -oyaml | kubectl apply -f -
kubectl create secret generic $redis_credentials --from-file=redis-password=$redis_password_path -n api --dry-run=client -oyaml | kubectl apply -f -

echo "In namespace redis"
kubectl create secret generic $redis_credentials --from-file=redis-password=$redis_password_path -n redis --dry-run=client -oyaml | kubectl apply -f -

echo "----------------------------------"
echo "Create Redis"
helm install $redis_helm_name bitnami/redis -f $redis_helm_path -n redis