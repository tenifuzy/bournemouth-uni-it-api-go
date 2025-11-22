#!/bin/bash

set -e

echo "🚀 Deploying Student API using Simple Helm Charts (No ESO/Vault/CRDs)"
echo "=================================================================="

# Function to wait for deployment
wait_for_deployment() {
    local deployment=$1
    local namespace=$2
    echo "⏳ Waiting for deployment $deployment in namespace $namespace..."
    kubectl wait --for=condition=available --timeout=300s deployment/$deployment -n $namespace
}

# Step 1: Clean up existing resources
echo "🧹 Cleaning up existing resources..."
helm uninstall student-api -n student-api --ignore-not-found
helm uninstall postgresql -n student-api --ignore-not-found
kubectl delete namespace student-api --ignore-not-found

echo "⏳ Waiting for cleanup..."
sleep 5

# Step 2: Create namespace
echo "🏷️ Creating namespace..."
kubectl create namespace student-api

# Step 3: Create database secret
echo "🔐 Creating database secret..."
kubectl create secret generic db-secret -n student-api \
  --from-literal=DB_USER=postgres \
  --from-literal=DB_PASSWORD=postgres

# Step 4: Deploy PostgreSQL
echo "🗄️ Deploying PostgreSQL database..."
helm install postgresql ./postgresql \
  --namespace student-api \
  --wait --timeout=300s
wait_for_deployment "postgres-db" "student-api"

# Step 5: Deploy Student API (without wait to see what happens)
echo "🚀 Deploying Student API application..."
helm install student-api ./student-api \
  --namespace student-api

echo "📋 Checking deployment status..."
kubectl get pods -n student-api
kubectl get deployments -n student-api

echo ""
echo "🔍 If pods are not ready, check with:"
echo "kubectl describe pod -l app=student-api -n student-api"
echo "kubectl logs -l app=student-api -n student-api"
echo ""
echo "🌐 To access the API (once ready):"
echo "kubectl port-forward svc/student-api-service 8080:8080 -n student-api"