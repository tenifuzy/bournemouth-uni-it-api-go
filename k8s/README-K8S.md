# Kubernetes Deployment Guide - Production Ready

This guide provides complete instructions for deploying the Bournemouth University IT Student API to Kubernetes with production-ready configurations including HashiCorp Vault, External Secrets Operator, and proper security practices.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                       │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                Namespace: student-api                   │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐ │ │
│  │  │   Ingress   │  │ LoadBalancer │  │   Student API   │ │ │
│  │  │             │  │   Service    │  │  (2 replicas)   │ │ │
│  │  └─────────────┘  └──────────────┘  └─────────────────┘ │ │
│  │         │                 │                   │         │ │
│  │         └─────────────────┼───────────────────┘         │ │
│  │                           │                             │ │
│  │  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐ │ │
│  │  │ ConfigMap   │  │ PostgreSQL   │  │ External Secrets│ │ │
│  │  │             │  │  Database    │  │   Operator      │ │ │
│  │  └─────────────┘  └──────────────┘  └─────────────────┘ │ │
│  │                           │                   │         │ │
│  │                           │         ┌─────────────────┐ │ │
│  │                           │         │  HashiCorp      │ │ │
│  │                           │         │     Vault       │ │ │
│  │                           │         └─────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

### Required Tools
- **Kubernetes cluster** (v1.20+)
- **kubectl** configured for your cluster
- **Helm** (v3.0+) for External Secrets Operator
- **Docker** (for building images)

### Cluster Requirements
- **Minimum 2 CPU cores** and **4GB RAM**
- **Persistent Volume** support
- **LoadBalancer** or **Ingress Controller** support

## 🚀 Quick Deployment

### Option 1: Automated Deployment (Recommended)

```bash
# Clone repository
git clone https://github.com/tenifuzy/bournemouth-uni-it-api-go.git
cd bournemouth-uni-it-api-go

# Make script executable
chmod +x k8s/deploy-all.sh

# Deploy everything
./k8s/deploy-all.sh
```

### Option 2: Manual Step-by-Step Deployment

#### Step 1: Create Namespace
```bash
kubectl apply -f k8s/namespaces/
```

#### Step 2: Deploy ConfigMaps
```bash
kubectl apply -f k8s/configmaps/
```

#### Step 3: Deploy HashiCorp Vault
```bash
kubectl apply -f k8s/vault/

# Wait for Vault to be ready
kubectl wait --for=condition=available --timeout=300s deployment/vault -n student-api
```

#### Step 4: Install External Secrets Operator
```bash
# Add Helm repository
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

# Install ESO
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets-system --create-namespace

# Wait for ESO to be ready
kubectl wait --for=condition=available --timeout=300s \
  deployment/external-secrets -n external-secrets-system
```

#### Step 5: Configure External Secrets
```bash
kubectl apply -f k8s/eso/

# Wait for secret creation
kubectl wait --for=condition=Ready --timeout=60s \
  externalsecret/db-credentials -n student-api
```

#### Step 6: Deploy Database
```bash
kubectl apply -f k8s/db/

# Wait for database to be ready
kubectl wait --for=condition=available --timeout=300s \
  deployment/postgres-db -n student-api
```

#### Step 7: Deploy Application
```bash
kubectl apply -f k8s/app/

# Wait for application to be ready
kubectl wait --for=condition=available --timeout=300s \
  deployment/student-api -n student-api
```

#### Step 8: Configure Ingress
```bash
kubectl apply -f k8s/ingress/
```

## 🔍 Verification

### Check Deployment Status
```bash
# Check all resources
kubectl get all -n student-api

# Check pods
kubectl get pods -n student-api -o wide

# Check services
kubectl get services -n student-api
```

### Verify Database Migration
```bash
# Check migration init container logs
kubectl logs -l app=student-api -c migration -n student-api

# Should show: "Migration completed or no changes needed"
```

### Verify Vault Integration
```bash
# Check if secret was created by ESO
kubectl get secret db-secret -n student-api -o yaml

# Check External Secret status
kubectl get externalsecret -n student-api
```

### Test API Endpoints

#### Using Port Forward (Local Testing)
```bash
# Forward port
kubectl port-forward svc/student-api-service 8080:8080 -n student-api

# Test health check
curl http://localhost:8080/healthcheck

# Test API
curl http://localhost:8080/api/v1/students
```

#### Using LoadBalancer (Production)
```bash
# Get external IP
kubectl get service student-api-loadbalancer -n student-api

# Test with external IP
EXTERNAL_IP=$(kubectl get service student-api-loadbalancer -n student-api \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl http://$EXTERNAL_IP:8080/healthcheck
curl http://$EXTERNAL_IP:8080/api/v1/students
```

## 🔧 Configuration Details

### Environment Variables (ConfigMap)
- `DB_HOST`: postgres-service
- `DB_PORT`: 5432
- `DB_NAME`: student_db
- `DB_SSL_MODE`: disable
- `SERVER_PORT`: 8080

### Secrets (Vault + ESO)
- `DB_USER`: postgres (stored in Vault)
- `DB_PASSWORD`: postgres (stored in Vault)

### Resource Limits
```yaml
# Application
requests: 128Mi memory, 100m CPU
limits: 256Mi memory, 200m CPU

# Database
requests: 256Mi memory, 250m CPU
limits: 512Mi memory, 500m CPU

# Vault
requests: 128Mi memory, 100m CPU
limits: 256Mi memory, 200m CPU
```

## 🗄️ Database Management

### Access Database
```bash
# Connect to PostgreSQL
kubectl exec -it deployment/postgres-db -n student-api -- \
  psql -U postgres -d student_db

# List tables
\dt

# View students
SELECT * FROM students;

# Exit
\q
```

### Manual Migration
```bash
# Run migration manually if needed
kubectl exec -it deployment/student-api -n student-api -- \
  /app/main migrate
```

## 🔐 Security Features

### HashiCorp Vault
- **Development mode** with root token (for demo)
- **KV v2 secrets engine** enabled
- **Database credentials** stored securely

### External Secrets Operator
- **Automatic secret synchronization** from Vault
- **15-second refresh interval**
- **Kubernetes-native secret management**

### Network Security
- **ClusterIP services** for internal communication
- **LoadBalancer** only for external API access
- **Namespace isolation**

## 📊 Monitoring and Logging

### View Logs
```bash
# Application logs
kubectl logs -l app=student-api -n student-api

# Database logs
kubectl logs -l app=postgres-db -n student-api

# Vault logs
kubectl logs -l app=vault -n student-api

# ESO logs
kubectl logs -l app.kubernetes.io/name=external-secrets -n external-secrets-system
```

### Health Checks
```bash
# Check pod health
kubectl get pods -n student-api

# Check service endpoints
kubectl get endpoints -n student-api

# Describe problematic pods
kubectl describe pod <pod-name> -n student-api
```

## 🔄 Scaling and Updates

### Scale Application
```bash
# Scale to 3 replicas
kubectl scale deployment student-api --replicas=3 -n student-api

# Check scaling
kubectl get pods -l app=student-api -n student-api
```

### Update Application
```bash
# Update image
kubectl set image deployment/student-api \
  student-api=tenifuzy01/v1:new-tag -n student-api

# Check rollout status
kubectl rollout status deployment/student-api -n student-api

# Rollback if needed
kubectl rollout undo deployment/student-api -n student-api
```

## 🧹 Cleanup

### Remove Application
```bash
# Delete all resources
kubectl delete namespace student-api

# Remove ESO (if no longer needed)
helm uninstall external-secrets -n external-secrets-system
kubectl delete namespace external-secrets-system
```

## 🛠️ Troubleshooting

### Common Issues

#### Pods Not Starting
```bash
# Check pod status
kubectl describe pod <pod-name> -n student-api

# Check events
kubectl get events -n student-api --sort-by=.metadata.creationTimestamp
```

#### Database Connection Issues
```bash
# Check database pod
kubectl logs -l app=postgres-db -n student-api

# Test connectivity from app pod
kubectl exec -it deployment/student-api -n student-api -- \
  nc -zv postgres-service 5432
```

#### Secret Not Created by ESO
```bash
# Check ESO logs
kubectl logs -l app.kubernetes.io/name=external-secrets -n external-secrets-system

# Check External Secret status
kubectl describe externalsecret db-credentials -n student-api

# Check Vault connectivity
kubectl exec -it deployment/vault -n student-api -- \
  vault kv get secret/db-credentials
```

#### Migration Failures
```bash
# Check init container logs
kubectl logs -l app=student-api -c migration -n student-api

# Run migration manually
kubectl exec -it deployment/student-api -n student-api -- \
  /app/main migrate
```

### Performance Issues
```bash
# Check resource usage
kubectl top pods -n student-api
kubectl top nodes

# Check resource limits
kubectl describe deployment student-api -n student-api
```

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [External Secrets Operator](https://external-secrets.io/)
- [HashiCorp Vault](https://www.vaultproject.io/)
- [Helm Documentation](https://helm.sh/docs/)

## 🎯 Production Considerations

### Security Hardening
- Replace Vault dev mode with production setup
- Use proper TLS certificates
- Implement RBAC policies
- Enable network policies

### High Availability
- Deploy Vault in HA mode
- Use multiple database replicas
- Configure pod disruption budgets
- Implement proper backup strategies

### Monitoring
- Add Prometheus metrics
- Configure alerting rules
- Implement distributed tracing
- Set up log aggregation