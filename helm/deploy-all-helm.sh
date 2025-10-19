#!/bin/bash

set -e

echo "🚀 Deploying Bournemouth University IT Student API using Helm Charts"
echo "===================================================================="

# Function to wait for deployment
wait_for_deployment() {
    local deployment=$1
    local namespace=$2
    echo "⏳ Waiting for deployment $deployment in namespace $namespace..."
    kubectl wait --for=condition=available --timeout=300s deployment/$deployment -n $namespace
}

# Function to wait for job completion
wait_for_job() {
    local job=$1
    local namespace=$2
    echo "⏳ Waiting for job $job in namespace $namespace..."
    kubectl wait --for=condition=complete --timeout=300s job/$job -n $namespace
}

# Step 1: Clean up existing CRDs if they exist
echo "🧹 Cleaning up existing External Secrets resources..."
kubectl delete crd externalsecrets.external-secrets.io secretstores.external-secrets.io --ignore-not-found=true
kubectl delete namespace external-secrets-system --ignore-not-found=true

# Step 2: Deploy External Secrets Operator
echo "🔌 Deploying External Secrets Operator..."
helm install external-secrets ./external-secrets \
  --create-namespace \
  --wait --timeout=300s
wait_for_deployment "external-secrets" "external-secrets-system"

# Step 3: Deploy Vault
echo "🔐 Deploying HashiCorp Vault..."
helm install vault ./vault \
  --namespace student-api \
  --create-namespace \
  --wait --timeout=300s
wait_for_deployment "vault" "student-api"

# Step 4: Wait for Vault initialization
echo "🔑 Waiting for Vault initialization..."
wait_for_job "vault-init" "student-api"

# Step 5: Deploy PostgreSQL
echo "🗄️  Deploying PostgreSQL database..."
helm install postgresql ./postgresql \
  --namespace student-api \
  --wait --timeout=300s
wait_for_deployment "postgres-db" "student-api"

# Step 6: Wait for External Secret to create db-secret
echo "⏳ Waiting for External Secret to create database secret..."
timeout=60
while [ $timeout -gt 0 ]; do
    if kubectl get secret db-secret -n student-api >/dev/null 2>&1; then
        echo "✅ Database secret created successfully by External Secrets"
        break
    fi
    echo "Waiting for External Secret to create secret... ($timeout seconds remaining)"
    sleep 5
    timeout=$((timeout - 5))
done

if [ $timeout -le 0 ]; then
    echo "⚠️  External Secret timeout - secret may not be created yet"
fi

# Step 7: Deploy Student API
echo "🚀 Deploying Student API application..."
helm install student-api ./student-api \
  --namespace student-api \
  --wait --timeout=300s
wait_for_deployment "student-api" "student-api"

echo ""
echo "✅ Helm deployment completed successfully!"
echo ""
echo "📋 Access Information:"
echo "====================="

# Get service information
echo "🔍 Getting service information..."
kubectl get services -n student-api

echo ""
echo "🌐 Access URLs:"
if kubectl get service student-api-loadbalancer -n student-api >/dev/null 2>&1; then
    EXTERNAL_IP=$(kubectl get service student-api-loadbalancer -n student-api -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
    if [ "$EXTERNAL_IP" != "pending" ] && [ "$EXTERNAL_IP" != "" ]; then
        echo "   LoadBalancer: http://$EXTERNAL_IP:8080"
    else
        echo "   LoadBalancer: External IP pending... Use 'kubectl get svc -n student-api' to check status"
    fi
fi

# For local development (minikube/kind)
echo "   Port Forward: kubectl port-forward svc/student-api-service 8080:8080 -n student-api"
echo ""

echo "🧪 Test Commands:"
echo "================"
echo "# Health Check:"
echo "curl http://localhost:8080/healthcheck"
echo ""
echo "# Get Students:"
echo "curl http://localhost:8080/api/v1/students"
echo ""

echo "🔍 Useful Helm Commands:"
echo "========================"
echo "# List releases:"
echo "helm list --all-namespaces"
echo ""
echo "# Check release status:"
echo "helm status student-api -n student-api"
echo ""
echo "# Upgrade release:"
echo "helm upgrade student-api ./helm/student-api -n student-api"
echo ""
echo "# Uninstall all releases:"
echo "helm uninstall student-api -n student-api"
echo "helm uninstall postgresql -n student-api"
echo "helm uninstall vault -n student-api"
echo "helm uninstall external-secrets -n external-secrets-system"