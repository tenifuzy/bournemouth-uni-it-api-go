# Kubernetes Deployment Guide

## 📋 Overview

This directory contains Kubernetes manifests to deploy the Bournemouth University IT API across a 3-node cluster:

- **Node A** (`type=application`): Student API application
- **Node B** (`type=database`): PostgreSQL database  
- **Node C** (`type=dependent_services`): Nginx load balancer + observability stack

## 🚀 Quick Deployment

### 1. Build and Deploy Everything
```bash
# Make deployment script executable
chmod +x k8s/deploy-all.sh

# Deploy all services
./k8s/deploy-all.sh
```

### 2. Access the Application
```bash
# Get service URLs
minikube service list

# Access application via load balancer
minikube service nginx-service

# Access application directly
minikube service student-api-nodeport

# Access observability tools
minikube service prometheus-service
minikube service grafana-service
```

## 📁 File Structure

```
k8s/
├── database-deployment.yml      # PostgreSQL on Node B
├── application-deployment.yml   # Student API on Node A  
├── nginx-deployment.yml         # Load balancer on Node C
├── observability-deployment.yml # Prometheus/Grafana on Node C
├── deploy-all.sh               # Deployment script
└── README.md                   # This file
```

## 🔧 Manual Deployment

### Step 1: Build Docker Image
```bash
# Set Minikube Docker environment
eval $(minikube docker-env)

# Build image
docker build -t bournemouth-uni-api:latest .
```

### Step 2: Deploy Database (Node B)
```bash
kubectl apply -f k8s/database-deployment.yml

# Wait for database to be ready
kubectl wait --for=condition=available --timeout=300s deployment/postgres-db
```

### Step 3: Deploy Application (Node A)
```bash
kubectl apply -f k8s/application-deployment.yml

# Wait for application to be ready
kubectl wait --for=condition=available --timeout=300s deployment/student-api
```

### Step 4: Deploy Load Balancer (Node C)
```bash
kubectl apply -f k8s/nginx-deployment.yml

# Wait for nginx to be ready
kubectl wait --for=condition=available --timeout=300s deployment/nginx-lb
```

### Step 5: Deploy Observability Stack (Node C)
```bash
kubectl apply -f k8s/observability-deployment.yml

# Wait for services to be ready
kubectl wait --for=condition=available --timeout=300s deployment/prometheus
kubectl wait --for=condition=available --timeout=300s deployment/grafana
```

## 🧪 Testing

### Check Pod Placement
```bash
# Verify pods are on correct nodes
kubectl get pods -o wide

# Should show:
# postgres-db-xxx     -> minikube-m02 (database node)
# student-api-xxx     -> minikube (application node)
# nginx-lb-xxx        -> minikube-m03 (dependent_services node)
# prometheus-xxx      -> minikube-m03 (dependent_services node)
# grafana-xxx         -> minikube-m03 (dependent_services node)
```

### Test API Endpoints
```bash
# Get nginx service URL
NGINX_URL=$(minikube service nginx-service --url)

# Test health check
curl $NGINX_URL/healthcheck

# Test API endpoints
curl $NGINX_URL/api/v1/students

# Create a student
curl -X POST $NGINX_URL/api/v1/students \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "John",
    "last_name": "Doe", 
    "email": "john.doe@bournemouth.ac.uk",
    "student_id": "S12345678",
    "course": "Information Technology",
    "year_of_study": 2
  }'
```

## 📊 Monitoring

### Access Grafana
```bash
# Get Grafana URL
minikube service grafana-service

# Login credentials:
# Username: admin
# Password: admin123
```

### Access Prometheus
```bash
# Get Prometheus URL
minikube service prometheus-service
```

## 🛠️ Management Commands

### View Resources
```bash
# Check all pods
kubectl get pods -o wide

# Check services
kubectl get services

# Check deployments
kubectl get deployments

# Check nodes and labels
kubectl get nodes --show-labels
```

### Scale Application
```bash
# Scale API to 3 replicas
kubectl scale deployment student-api --replicas=3

# Check scaling
kubectl get pods -l app=student-api
```

### View Logs
```bash
# Application logs
kubectl logs -l app=student-api

# Database logs
kubectl logs -l app=postgres-db

# Nginx logs
kubectl logs -l app=nginx-lb
```

### Debug Issues
```bash
# Describe pod
kubectl describe pod <pod-name>

# Get events
kubectl get events --sort-by=.metadata.creationTimestamp

# Check resource usage
kubectl top pods
kubectl top nodes
```

## 🧹 Cleanup

### Delete All Resources
```bash
# Delete all deployments
kubectl delete -f k8s/

# Or delete individually
kubectl delete -f k8s/database-deployment.yml
kubectl delete -f k8s/application-deployment.yml
kubectl delete -f k8s/nginx-deployment.yml
kubectl delete -f k8s/observability-deployment.yml
```

### Reset Minikube
```bash
# Stop cluster
minikube stop

# Delete cluster
minikube delete

# Start fresh cluster
minikube start --nodes 3 --driver=docker
```

## 🔧 Customization

### Change Resource Limits
Edit the `resources` section in deployment files:
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Add More Services
Create new deployment files following the same pattern and add appropriate `nodeSelector` labels.

### Modify Load Balancer
Edit the `nginx.conf` in `nginx-deployment.yml` ConfigMap to change load balancing behavior.

## 🎯 Access URLs Summary

After deployment, access your services at:

- **Application (Load Balanced)**: `minikube service nginx-service --url`
- **Application (Direct)**: `minikube service student-api-nodeport --url`  
- **Prometheus**: `minikube service prometheus-service --url`
- **Grafana**: `minikube service grafana-service --url`

Your Kubernetes deployment is now ready! 🚀