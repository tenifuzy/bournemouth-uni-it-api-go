#!/bin/bash

echo "🚀 Deploying Bournemouth University IT API to Kubernetes..."

# Deploy Vault first
echo "🔐 Deploying HashiCorp Vault..."
kubectl apply -f vault.yml
kubectl wait --for=condition=ready pod -l app=vault -n vault-system --timeout=300s

# Install External Secrets Operator CRDs
echo "📦 Installing External Secrets Operator CRDs..."
kubectl apply -f https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/crds/bundle.yaml

# Wait for CRDs to be established
echo "⏳ Waiting for CRDs to be established..."
sleep 15
kubectl wait --for condition=established --timeout=60s crd/secretstores.external-secrets.io
kubectl wait --for condition=established --timeout=60s crd/externalsecrets.external-secrets.io

# Deploy External Secrets Operator
echo "🔄 Deploying External Secrets Operator..."
kubectl apply -f eso.yml
kubectl wait --for=condition=ready pod -l app=external-secrets-operator -n external-secrets-system --timeout=300s

# Wait for secrets to be created
echo "⏳ Waiting for secrets to be synced..."
sleep 30

# Apply database components
echo "📊 Deploying database components..."
kubectl apply -f database.yml
kubectl wait --for=condition=ready pod -l app=postgres-db -n student-api --timeout=300s

# Apply application components
echo "🔧 Deploying application components..."
kubectl apply -f application.yml
kubectl wait --for=condition=ready pod -l app=student-api -n student-api --timeout=300s

echo "✅ Deployment completed!"
echo ""
echo "🌐 Access URLs:"
echo "- LoadBalancer: kubectl get svc student-api-loadbalancer -n student-api"
echo "- NodePort: http://<node-ip>:30080"
echo "- Port Forward: kubectl port-forward svc/student-api-service 8080:8080 -n student-api"
echo ""
echo "📊 Check status:"
echo "kubectl get all -n student-api"