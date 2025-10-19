# Kubernetes Deployment Guide
## Bournemouth University IT API with Vault & External Secrets Operator

This guide explains how to deploy the Bournemouth University IT API on Kubernetes with secure secret management using HashiCorp Vault and External Secrets Operator (ESO).

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │    Database     │    │     Vault       │
│   (2 replicas)  │    │  (PostgreSQL)   │    │  (Dev Mode)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   app-secret    │    │   db-secret     │    │ secret/database │
│   (from ESO)    │    │   (from ESO)    │    │ secret/app      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ▲                       ▲                       ▲
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │      ESO        │
                    │  (Sync Secrets) │
                    └─────────────────┘
```

## 🔄 Component Interaction Flow

### 1. **Vault** (Secret Storage)
- Stores sensitive data (database credentials, API keys)
- Runs in development mode with root token
- Accessible at: `http://vault-service.vault-system.svc.cluster.local:8200`

### 2. **External Secrets Operator (ESO)**
- Watches for `ExternalSecret` resources
- Authenticates with Vault using token
- Syncs secrets from Vault to Kubernetes secrets
- Refreshes secrets every 30 seconds

### 3. **SecretStore**
- Defines how ESO connects to Vault
- Specifies authentication method (token-based)
- Points to Vault server and secret path

### 4. **ExternalSecret**
- Defines which secrets to sync from Vault
- Maps Vault keys to Kubernetes secret keys
- Creates/updates target Kubernetes secrets

### 5. **Database (PostgreSQL)**
- Uses `db-secret` for credentials (synced from Vault)
- Credentials: `DB_USER`, `DB_PASSWORD`
- Persistent storage with PVC

### 6. **Application**
- Uses both `db-secret` and `app-secret`
- Init container runs database migrations
- Main container serves the API

## 📋 Prerequisites

- **Kubernetes cluster** (Minikube, EKS, etc.)
- **kubectl** configured
- **Docker** image: `tenifuzy01/v1:latest`

## 🚀 Deployment Steps

### Step 1: Deploy the Complete Stack
```bash
# Make script executable
chmod +x k8s/deploy-consolidated.sh

# Run deployment
./k8s/deploy-consolidated.sh
```

### Step 2: Verify Deployment
```bash
# Check all components
kubectl get all -n student-api
kubectl get all -n vault-system
kubectl get all -n external-secrets-system

# Check secrets
kubectl get externalsecret -n student-api
kubectl get secret db-secret app-secret -n student-api
```

### Step 3: Access the Application
```bash
# Via port forwarding
kubectl port-forward --address 0.0.0.0 svc/student-api-service 8081:8080 -n student-api

# Via NodePort
minikube ip  # Get IP, then access http://<ip>:30080

# Via LoadBalancer (if supported)
kubectl get svc student-api-loadbalancer -n student-api
```

## 🔧 Manual Deployment (Step by Step)

### 1. Deploy Vault
```bash
kubectl apply -f k8s/vault.yml
kubectl wait --for=condition=ready pod -l app=vault -n vault-system --timeout=300s
```

### 2. Initialize Vault with Secrets
```bash
# Get Vault pod name
VAULT_POD=$(kubectl get pod -l app=vault -n vault-system -o jsonpath='{.items[0].metadata.name}')

# Store database credentials
kubectl exec -it $VAULT_POD -n vault-system -- \
  vault kv put secret/database username=postgres password=postgres

# Store application secrets
kubectl exec -it $VAULT_POD -n vault-system -- \
  vault kv put secret/application api_key=test-key
```

### 3. Deploy External Secrets Operator
```bash
# Install CRDs
kubectl apply -f k8s/crds.yml
kubectl wait --for=condition=established --timeout=300s crd/secretstores.external-secrets.io
kubectl wait --for=condition=established --timeout=300s crd/externalsecrets.external-secrets.io

# Deploy ESO
kubectl apply -f k8s/eso.yml
kubectl wait --for=condition=ready pod -l app=external-secrets-operator -n external-secrets-system --timeout=300s
```

### 4. Deploy Database
```bash
kubectl apply -f k8s/database.yml
kubectl wait --for=condition=ready pod -l app=postgres-db -n student-api --timeout=300s
```

### 5. Deploy Application
```bash
kubectl apply -f k8s/application.yml
kubectl wait --for=condition=ready pod -l app=student-api -n student-api --timeout=300s
```

## 🔍 Secret Management Flow

### How Secrets Flow from Vault to Application:

1. **Vault Storage**:
   ```bash
   # Secrets stored in Vault
   secret/database -> {username: postgres, password: postgres}
   secret/application -> {api_key: test-key}
   ```

2. **ESO Configuration**:
   ```yaml
   # SecretStore connects to Vault
   spec:
     provider:
       vault:
         server: "http://vault-service.vault-system.svc.cluster.local:8200"
         auth:
           tokenSecretRef:
             name: "vault-token"
             key: "token"
   ```

3. **Secret Mapping**:
   ```yaml
   # ExternalSecret maps Vault keys to K8s secret keys
   data:
   - secretKey: DB_USER
     remoteRef:
       key: database
       property: username
   - secretKey: DB_PASSWORD
     remoteRef:
       key: database
       property: password
   ```

4. **Application Consumption**:
   ```yaml
   # Pods consume secrets as environment variables
   envFrom:
   - secretRef:
       name: db-secret  # Created by ESO
   - secretRef:
       name: app-secret # Created by ESO
   ```

## 📊 Monitoring and Troubleshooting

### Check ESO Status
```bash
# Check ExternalSecret status
kubectl describe externalsecret db-credentials -n student-api
kubectl describe externalsecret app-credentials -n student-api

# Check ESO operator logs
kubectl logs -l app=external-secrets-operator -n external-secrets-system
```

### Verify Secret Sync
```bash
# Check if secrets were created by ESO
kubectl get secret db-secret app-secret -n student-api -o yaml | grep "external-secrets"

# Check secret contents (base64 encoded)
kubectl get secret db-secret -n student-api -o jsonpath='{.data}'
```

### Test Vault Connectivity
```bash
# Test from within cluster
kubectl run vault-test --rm -i --tty --image=curlimages/curl -- \
  curl -s http://vault-service.vault-system.svc.cluster.local:8200/v1/sys/health
```

### Application Logs
```bash
# Check application logs
kubectl logs -l app=student-api -n student-api

# Check init container logs
kubectl logs -l app=student-api -c migration -n student-api
```

## 🌐 External Access

### Port Forwarding (Recommended)
```bash
# Forward to all interfaces for external access
kubectl port-forward --address 0.0.0.0 svc/student-api-service 8081:8080 -n student-api

# Access from outside
curl http://<your-ec2-ip>:8081/healthcheck
```

### NodePort Access
```bash
# Get Minikube IP
minikube ip

# Access via NodePort
curl http://<minikube-ip>:30080/healthcheck
```

## 🔧 Configuration Files

### Key Files Structure:
```
k8s/
├── vault.yml              # Vault deployment + init job
├── eso.yml                 # External Secrets Operator
├── crds.yml                # Custom Resource Definitions
├── database.yml            # PostgreSQL + ESO resources
├── application.yml         # API app + ESO resources
└── deploy-consolidated.sh  # Automated deployment script
```

### Environment Variables:
- **ConfigMap** (non-sensitive): `DB_HOST`, `DB_PORT`, `DB_NAME`, `SERVER_PORT`
- **Secrets** (sensitive): `DB_USER`, `DB_PASSWORD`, `API_KEY`

## 🧪 Testing the API

### Health Check
```bash
curl http://localhost:8081/healthcheck
```

### API Endpoints
```bash
# Get all students
curl http://localhost:8081/api/v1/students

# Create a student
curl -X POST http://localhost:8081/api/v1/students \
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

## 🔄 Secret Rotation

ESO automatically refreshes secrets every 30 seconds. To manually trigger:

```bash
# Update secret in Vault
kubectl exec -it $VAULT_POD -n vault-system -- \
  vault kv put secret/database username=postgres password=newpassword

# ESO will automatically sync the new secret within 30 seconds
# Restart pods to use new secrets
kubectl rollout restart deployment/student-api -n student-api
kubectl rollout restart deployment/postgres-db -n student-api
```

## 🛠️ Cleanup

```bash
# Delete all resources
kubectl delete -f k8s/application.yml
kubectl delete -f k8s/database.yml
kubectl delete -f k8s/eso.yml
kubectl delete -f k8s/vault.yml
kubectl delete -f k8s/crds.yml

# Delete namespaces
kubectl delete namespace student-api vault-system external-secrets-system
```

## 🎯 Key Benefits

1. **Security**: Secrets stored in Vault, not in Kubernetes manifests
2. **Automation**: ESO automatically syncs secrets
3. **Rotation**: Easy secret rotation without manual intervention
4. **Separation**: Clear separation between sensitive and non-sensitive config
5. **Scalability**: Multiple applications can share the same Vault instance

This architecture provides a production-ready secret management solution for Kubernetes applications.