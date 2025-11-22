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
helm uninstall student-api -n student-api --ignore-not-found || true
helm uninstall postgresql -n student-api --ignore-not-found || true
kubectl delete namespace student-api --ignore-not-found || true

echo "⏳ Waiting for cleanup..."
sleep 10

# Step 2: Create namespace
echo "🏷️ Creating namespace..."
kubectl create namespace student-api

# Step 3: Create database secret manually
echo "🔐 Creating database secret..."
kubectl create secret generic db-secret \
  --from-literal=DB_USER=postgres \
  --from-literal=DB_PASSWORD=postgres \
  -n student-api

# Step 4: Deploy PostgreSQL (with ESO disabled)
echo "🗄️ Deploying PostgreSQL database..."
helm install postgresql ./postgresql \
  --namespace student-api \
  --set externalSecrets.enabled=false \
  --wait --timeout=300s

wait_for_deployment "postgres-db" "student-api"

# Step 5: Deploy Student API (with ESO disabled)
echo "🚀 Deploying Student API application..."
helm install student-api ./student-api \
  --namespace student-api \
  --set externalSecrets.enabled=false \
  --wait --timeout=300s

wait_for_deployment "student-api" "student-api"

echo ""
echo "✅ Simple Helm deployment completed successfully!"
echo ""
echo "📋 Access Information:"
echo "====================="

kubectl get services -n student-api

echo ""
echo "🌐 Access URLs:"
echo "   Port Forward: kubectl port-forward svc/student-api-service 8080:8080 -n student-api"
echo ""

echo "🧪 Test Commands:"
echo "================"
echo "curl http://localhost:8080/healthcheck"
echo "curl http://localhost:8080/api/v1/students"