#!/bin/bash 

set -e 

IMAGE_TAG=${1:-latest}
ECR_URL="557690607676.dkr.ecr.us-east-2.amazonaws.com/asterra-devops-repo"

echo "starting full deployment proces..."

# =====PostGIS && Helm======
echo "Installing PostgreSQL with PostGIS via Helm..."
Helm repo add bitnami https://charts.binami.com/bitnami
Helm repo update 

Helm update --install postgres bitnami/postgresql -f k8s/db/postgresql-values.yaml

# =====kubernetes===== 

echo "Deploying to kubernetes...."

kubectl apply -f k8s/config/env-configmap.yaml
kubectl apply -f k8s/app/deployment.yaml
kubectl apply -f k8s/app/service.yaml
kubectl apply -f k8s/app/hpa.yaml

kubectl set image deployment/geojson-processor geojson-container=$ECR_URL:$IMAGE_TAG

kubectl rollout status deployment geojson-processor

echo "Deployment finished!"
