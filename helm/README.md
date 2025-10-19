# Helm Charts for Bournemouth University IT Student API

This directory contains Helm charts for deploying the complete Student API stack using Kubernetes package management.

## 📦 Chart Overview

### Available Charts

| Chart | Description | Version | Dependencies |
|-------|-------------|---------|--------------|
| `student-api` | Main REST API application | 1.0.0 | PostgreSQL, Vault secrets |
| `postgresql` | PostgreSQL database | 1.0.0 | Persistent storage |
| `vault` | HashiCorp Vault for secrets | 1.0.0 | None |
| `external-secrets` | External Secrets Operator | 1.0.0 | Vault integration |

## 🚀 Quick Deployment

### Prerequisites
```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
kubectl version --client
```

### Deploy All Services
```bash
# Linux/Mac
chmod +x deploy-all-helm.sh
./deploy-all-helm.sh

# Windows
deploy-all-helm.bat
```

## 📋 Individual Chart Deployment

### 1. External Secrets Operator
```bash
helm install external-secrets ./external-secrets \
  --create-namespace \
  --wait --timeout=300s
```

### 2. HashiCorp Vault
```bash
helm install vault ./vault \
  --namespace student-api \
  --create-namespace \
  --wait --timeout=300s
```

### 3. PostgreSQL Database
```bash
helm install postgresql ./postgresql \
  --namespace student-api \
  --wait --timeout=300s
```

### 4. Student API Application
```bash
helm install student-api ./student-api \
  --namespace student-api \
  --wait --timeout=300s
```

## ⚙️ Configuration

### Student API Configuration
Edit `student-api/values.yaml`:
```yaml
app:
  replicas: 3                    # Scale to 3 replicas
  image:
    tag: v2.0                    # Use specific version
service:
  type: NodePort                 # Change service type
  loadBalancer:
    enabled: false               # Disable LoadBalancer
ingress:
  enabled: true                  # Enable Ingress
  host: api.example.com          # Custom domain
resources:
  limits:
    memory: "512Mi"              # Increase memory limit
    cpu: "500m"                  # Increase CPU limit
```

### PostgreSQL Configuration
Edit `postgresql/values.yaml`:
```yaml
postgresql:
  persistence:
    size: 5Gi                    # Increase storage
  resources:
    limits:
      memory: "1Gi"              # Increase memory
      cpu: "1000m"               # Increase CPU
  database:
    password: "secure-password"   # Change password
```

### Vault Configuration
Edit `vault/values.yaml`:
```yaml
vault:
  dev:
    enabled: false               # Disable dev mode for production
  nodeSelector:
    type: security               # Use security nodes
```

## 🔧 Helm Management Commands

### List Releases
```bash
# All namespaces
helm list --all-namespaces

# Specific namespace
helm list -n student-api
```

### Check Release Status
```bash
helm status student-api -n student-api
helm status postgresql -n student-api
helm status vault -n student-api
helm status external-secrets -n external-secrets-system
```

### Upgrade Releases
```bash
# Upgrade with new values
helm upgrade student-api ./student-api \
  --set app.replicas=3 \
  --namespace student-api

# Upgrade with values file
helm upgrade student-api ./student-api \
  --values custom-values.yaml \
  --namespace student-api
```

### Rollback Releases
```bash
# View release history
helm history student-api -n student-api

# Rollback to previous version
helm rollback student-api -n student-api

# Rollback to specific revision
helm rollback student-api 2 -n student-api
```

### Uninstall Releases
```bash
# Individual releases
helm uninstall student-api -n student-api
helm uninstall postgresql -n student-api
helm uninstall vault -n student-api
helm uninstall external-secrets -n external-secrets-system

# Clean up namespaces
kubectl delete namespace student-api
kubectl delete namespace external-secrets-system
```

## 🧪 Testing and Validation

### Dry Run Deployment
```bash
# Preview changes without applying
helm install student-api ./student-api \
  --dry-run --debug \
  --namespace student-api
```

### Template Validation
```bash
# Render templates locally
helm template student-api ./student-api \
  --namespace student-api
```

### Release Testing
```bash
# Run chart tests (if available)
helm test student-api -n student-api
```

## 📊 Monitoring and Debugging

### View Release Manifests
```bash
# Get all manifests for a release
helm get manifest student-api -n student-api

# Get release values
helm get values student-api -n student-api

# Get release notes
helm get notes student-api -n student-api
```

### Debug Issues
```bash
# Check pod status
kubectl get pods -n student-api

# View pod logs
kubectl logs -l app=student-api -n student-api

# Describe problematic resources
kubectl describe deployment student-api -n student-api
```

## 🔄 Custom Values Examples

### Production Values (`production-values.yaml`)
```yaml
# student-api production configuration
app:
  replicas: 3
  image:
    tag: stable
    pullPolicy: Always
  
service:
  type: ClusterIP
  loadBalancer:
    enabled: true

ingress:
  enabled: true
  host: api.bournemouth.ac.uk
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod

resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "512Mi"
    cpu: "500m"

nodeSelector:
  node-type: application
  environment: production
```

### Development Values (`dev-values.yaml`)
```yaml
# student-api development configuration
app:
  replicas: 1
  image:
    tag: latest
    pullPolicy: Always

service:
  type: NodePort
  loadBalancer:
    enabled: false

ingress:
  enabled: false

resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

### Deploy with Custom Values
```bash
# Production deployment
helm install student-api ./student-api \
  --values production-values.yaml \
  --namespace student-api-prod \
  --create-namespace

# Development deployment
helm install student-api-dev ./student-api \
  --values dev-values.yaml \
  --namespace student-api-dev \
  --create-namespace
```

## 🏗️ Chart Development

### Chart Structure
```
student-api/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default configuration
├── templates/          # Kubernetes manifest templates
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── ingress.yaml
│   └── namespace.yaml
└── README.md          # Chart documentation
```

### Template Functions
```yaml
# Common template patterns used in charts
metadata:
  name: {{ .Values.app.name }}
  namespace: {{ .Values.namespace }}
  labels:
    app: {{ .Values.app.name }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}

# Conditional resources
{{- if .Values.ingress.enabled }}
# Ingress resource here
{{- end }}

# Resource limits
resources:
  {{- toYaml .Values.resources | nindent 10 }}

# Node selector
{{- if .Values.nodeSelector }}
nodeSelector:
  {{- toYaml .Values.nodeSelector | nindent 8 }}
{{- end }}
```

## 🔐 Security Best Practices

### Secret Management
- Use External Secrets Operator for sensitive data
- Never hardcode secrets in values.yaml
- Use Kubernetes secrets for runtime credentials
- Rotate secrets regularly

### RBAC Configuration
- Implement least-privilege access
- Use service accounts for applications
- Separate namespaces for different environments
- Regular RBAC audits

### Network Policies
```yaml
# Example network policy for student-api
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: student-api-netpol
  namespace: student-api
spec:
  podSelector:
    matchLabels:
      app: student-api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgres-db
    ports:
    - protocol: TCP
      port: 5432
```

## 📚 Additional Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Helm Template Guide](https://helm.sh/docs/chart_template_guide/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 🎯 Next Steps

1. **Production Readiness**: Configure proper resource limits, health checks, and monitoring
2. **CI/CD Integration**: Integrate Helm deployments into your CI/CD pipeline
3. **Chart Repository**: Publish charts to a Helm repository for sharing
4. **Monitoring**: Add Prometheus metrics and Grafana dashboards
5. **Backup Strategy**: Implement database backup and disaster recovery