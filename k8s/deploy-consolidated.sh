#!/bin/bash

echo "🚀 Deploying Bournemouth University IT API to Kubernetes..."

# Deploy Vault first
echo "🔐 Deploying HashiCorp Vault..."
kubectl apply -f vault.yml
kubectl wait --for=condition=ready pod -l app=vault -n vault-system --timeout=300s

# Install ESO using Helm
echo "📦 Installing External Secrets Operator..."
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets external-secrets/external-secrets -n external-secrets-system --create-namespace
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=external-secrets -n external-secrets-system --timeout=300s

# Wait for secrets sync
echo "⏳ Waiting for secrets to sync..."
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