#!/bin/bash

echo "🚀 Deploying Bournemouth University IT API to Kubernetes..."

# Deploy Vault first
echo "🔐 Deploying HashiCorp Vault..."
kubectl apply -f k8s/vault.yml
kubectl wait --for=condition=ready pod -l app=vault -n vault-system --timeout=300s

# Initialize Vault with secrets
echo "📝 Initializing Vault with secrets..."
kubectl exec -it $(kubectl get pod -l app=vault -n vault-system -o jsonpath='{.items[0].metadata.name}') -n vault-system -- \
  vault kv put secret/database username=postgres password=postgres
kubectl exec -it $(kubectl get pod -l app=vault -n vault-system -o jsonpath='{.items[0].metadata.name}') -n vault-system -- \
  vault kv put secret/application api_key=test-key

# Install External Secrets Operator CRDs
echo "📦 Installing External Secrets Operator CRDs..."
kubectl apply -f k8s/crds.yml

# Wait for CRDs to be established
echo "⏳ Waiting for CRDs to be established..."
kubectl wait --for=condition=established --timeout=300s crd/secretstores.external-secrets.io
kubectl wait --for=condition=established --timeout=300s crd/externalsecrets.external-secrets.io

# Deploy External Secrets Operator
echo "🔄 Deploying External Secrets Operator..."
kubectl apply -f k8s/eso.yml
kubectl wait --for=condition=ready pod -l app=external-secrets-operator -n external-secrets-system --timeout=300s

# Wait for secrets to be created
echo "⏳ Waiting for secrets to be synced..."
sleep 30

# Apply database components
echo "📊 Deploying database components..."
kubectl apply -f k8s/database.yml
kubectl wait --for=condition=ready pod -l app=postgres-db -n student-api --timeout=300s

# Apply application components
echo "🔧 Deploying application components..."
kubectl apply -f k8s/application.yml
kubectl wait --for=condition=ready pod -l app=student-api -n student-api --timeout=300s

# Setup port forwarding for external access
echo "🌐 Setting up external access..."
nohup kubectl port-forward --address 0.0.0.0 svc/student-api-service 8081:8080 -n student-api > /dev/null 2>&1 &

echo "✅ Deployment completed!"
echo ""
echo "🌐 Access URLs:"
echo "- AWS EC2 External: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8081"
echo "- NodePort: http://$(minikube ip):30080"
echo "- LoadBalancer: kubectl get svc student-api-loadbalancer -n student-api"
echo ""
echo "📊 Check status:"
echo "kubectl get all -n student-api"
echo ""
echo "🔍 Verify ESO secrets:"
echo "kubectl get externalsecret -n student-api"
echo "kubectl get secret db-secret app-secret -n student-api"