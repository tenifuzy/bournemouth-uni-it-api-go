#!/bin/bash

set -e

echo "🚀 Deploying Bournemouth University IT Student API to Kubernetes (Simplified)"
echo "============================================================================="

# Function to wait for deployment
wait_for_deployment() {
    local deployment=$1
    local namespace=$2
    echo "⏳ Waiting for deployment $deployment in namespace $namespace..."
    kubectl wait --for=condition=available --timeout=300s deployment/$deployment -n $namespace
}

# Step 1: Create namespace
echo "📁 Creating namespace..."
kubectl apply -f k8s/namespaces/

# Step 2: Deploy ConfigMaps
echo "⚙️  Creating ConfigMaps..."
kubectl apply -f k8s/configmaps/

# Step 3: Create database secret directly
echo "🔑 Creating database secret..."
kubectl create secret generic db-secret -n student-api \
  --from-literal=DB_USER=postgres \
  --from-literal=DB_PASSWORD=postgres \
  --dry-run=client -o yaml | kubectl apply -f -
echo "✅ Database secret created successfully"

# Step 4: Deploy Database
echo "🗄️  Deploying PostgreSQL database..."
kubectl apply -f k8s/db/
wait_for_deployment "postgres-db" "student-api"

# Step 5: Deploy Application
echo "🚀 Deploying Student API application..."
kubectl apply -f k8s/app/
wait_for_deployment "student-api" "student-api"

# Step 6: Deploy Ingress
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