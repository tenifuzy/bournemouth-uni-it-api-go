#!/bin/bash

set -e

echo "🚀 Deploying Bournemouth University IT Student API to Kubernetes"
echo "================================================================"

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

# Step 1: Create namespace
echo "📁 Creating namespace..."
kubectl apply -f k8s/namespaces/

# Step 2: Deploy ConfigMaps
echo "⚙️  Creating ConfigMaps..."
kubectl apply -f k8s/configmaps/

# Step 3: Deploy Vault
echo "🔐 Deploying HashiCorp Vault..."
kubectl apply -f k8s/vault/
wait_for_deployment "vault" "student-api"

# Wait for Vault initialization job
echo "🔑 Waiting for Vault initialization..."
wait_for_job "vault-init" "student-api"

# Step 4: Deploy External Secrets Operator
echo "📦 Deploying External Secrets Operator..."
kubectl apply -f k8s/eso/eso-deployment.yml
kubectl wait --for=condition=available --timeout=300s deployment/external-secrets -n external-secrets-system

# Step 5: Configure External Secrets
echo "🔗 Configuring External Secrets..."
kubectl apply -f k8s/eso/external-secret.yml

# Wait for secret to be created by ESO
echo "⏳ Waiting for database secret to be created by ESO..."
timeout=60
while [ $timeout -gt 0 ]; do
    if kubectl get secret db-secret -n student-api >/dev/null 2>&1; then
        echo "✅ Database secret created successfully by ESO"
        break
    fi
    echo "Waiting for ESO to create secret... ($timeout seconds remaining)"
    sleep 5
    timeout=$((timeout - 5))
done

if [ $timeout -le 0 ]; then
    echo "⚠️  ESO timeout - creating secret manually as fallback"
    kubectl create secret generic db-secret -n student-api \
      --from-literal=DB_USER=postgres \
      --from-literal=DB_PASSWORD=postgres \
      --dry-run=client -o yaml | kubectl apply -f -
fi

# Step 6: Deploy Database
echo "🗄️  Deploying PostgreSQL database..."
kubectl apply -f k8s/db/
wait_for_deployment "postgres-db" "student-api"

# Step 7: Deploy Application
echo "🚀 Deploying Student API application..."
kubectl apply -f k8s/app/
wait_for_deployment "student-api" "student-api"

# Step 8: Deploy Ingress
echo "🌐 Configuring Ingress..."
kubectl apply -f k8s/ingress/

echo ""
echo "✅ Deployment completed successfully!"
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
echo "# Create Student:"
echo 'curl -X POST http://localhost:8080/api/v1/students \'
echo '  -H "Content-Type: application/json" \'
echo '  -d '"'"'{'
echo '    "first_name": "John",'
echo '    "last_name": "Doe",'
echo '    "email": "john.doe@bournemouth.ac.uk",'
echo '    "student_id": "S12345678",'
echo '    "course": "Information Technology",'
echo '    "year_of_study": 2'
echo '  }'"'"

echo ""
echo "🔍 Useful Commands:"
echo "=================="
echo "# Check pods:"
echo "kubectl get pods -n student-api"
echo ""
echo "# Check logs:"
echo "kubectl logs -l app=student-api -n student-api"
echo ""
echo "# Check migration logs:"
echo "kubectl logs -l app=student-api -c migration -n student-api"
echo ""
echo "# Access database:"
echo "kubectl exec -it deployment/postgres-db -n student-api -- psql -U postgres -d student_db"