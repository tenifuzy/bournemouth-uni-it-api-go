@echo off
setlocal enabledelayedexpansion

echo 🚀 Deploying Bournemouth University IT Student API to Kubernetes
echo ================================================================

REM Function to wait for deployment
:wait_for_deployment
set deployment=%1
set namespace=%2
echo ⏳ Waiting for deployment %deployment% in namespace %namespace%...
kubectl wait --for=condition=available --timeout=300s deployment/%deployment% -n %namespace%
if errorlevel 1 (
    echo ❌ Failed to wait for deployment %deployment%
    exit /b 1
)
goto :eof

REM Step 1: Create namespace
echo 📁 Creating namespace...
kubectl apply -f k8s/namespaces/
if errorlevel 1 (
    echo ❌ Failed to create namespace
    exit /b 1
)

REM Step 2: Deploy ConfigMaps
echo ⚙️  Creating ConfigMaps...
kubectl apply -f k8s/configmaps/
if errorlevel 1 (
    echo ❌ Failed to create ConfigMaps
    exit /b 1
)

REM Step 3: Deploy Vault
echo 🔐 Deploying HashiCorp Vault...
kubectl apply -f k8s/vault/
if errorlevel 1 (
    echo ❌ Failed to deploy Vault
    exit /b 1
)
call :wait_for_deployment vault student-api

REM Step 4: Wait for Vault initialization
echo 🔑 Waiting for Vault initialization...
timeout /t 30 /nobreak >nul
kubectl wait --for=condition=complete --timeout=300s job/vault-init -n student-api
if errorlevel 1 (
    echo ❌ Failed to initialize Vault
    exit /b 1
)

REM Step 5: Check External Secrets Operator
echo 🔌 Checking External Secrets Operator...
kubectl get crd externalsecrets.external-secrets.io >nul 2>&1
if errorlevel 1 (
    echo 📦 Installing External Secrets Operator...
    helm repo add external-secrets https://charts.external-secrets.io
    helm repo update
    helm install external-secrets external-secrets/external-secrets -n external-secrets-system --create-namespace
    
    REM Wait for ESO to be ready
    kubectl wait --for=condition=available --timeout=300s deployment/external-secrets -n external-secrets-system
    kubectl wait --for=condition=available --timeout=300s deployment/external-secrets-webhook -n external-secrets-system
    kubectl wait --for=condition=available --timeout=300s deployment/external-secrets-cert-controller -n external-secrets-system
)

REM Step 6: Deploy External Secrets configuration
echo 🔗 Configuring External Secrets...
kubectl apply -f k8s/eso/
if errorlevel 1 (
    echo ❌ Failed to configure External Secrets
    exit /b 1
)

REM Wait for secret to be created
echo ⏳ Waiting for database secret to be created by ESO...
set timeout=60
:wait_secret
kubectl get secret db-secret -n student-api >nul 2>&1
if not errorlevel 1 (
    echo ✅ Database secret created successfully
    goto :secret_ready
)
echo Waiting for secret creation... (!timeout! seconds remaining^)
timeout /t 5 /nobreak >nul
set /a timeout=timeout-5
if !timeout! gtr 0 goto :wait_secret

echo ❌ Timeout waiting for database secret creation
exit /b 1

:secret_ready

REM Step 7: Deploy Database
echo 🗄️  Deploying PostgreSQL database...
kubectl apply -f k8s/db/
if errorlevel 1 (
    echo ❌ Failed to deploy database
    exit /b 1
)
call :wait_for_deployment postgres-db student-api

REM Step 8: Deploy Application
echo 🚀 Deploying Student API application...
kubectl apply -f k8s/app/
if errorlevel 1 (
    echo ❌ Failed to deploy application
    exit /b 1
)
call :wait_for_deployment student-api student-api

REM Step 9: Deploy Ingress
echo 🌐 Configuring Ingress...
kubectl apply -f k8s/ingress/
if errorlevel 1 (
    echo ❌ Failed to configure Ingress
    exit /b 1
)

echo.
echo ✅ Deployment completed successfully!
echo.
echo 📋 Access Information:
echo =====================

REM Get service information
echo 🔍 Getting service information...
kubectl get services -n student-api

echo.
echo 🌐 Access URLs:
echo    Port Forward: kubectl port-forward svc/student-api-service 8080:8080 -n student-api
echo.

echo 🧪 Test Commands:
echo ================
echo # Health Check:
echo curl http://localhost:8080/healthcheck
echo.
echo # Get Students:
echo curl http://localhost:8080/api/v1/students
echo.

echo 🔍 Useful Commands:
echo ==================
echo # Check pods:
echo kubectl get pods -n student-api
echo.
echo # Check logs:
echo kubectl logs -l app=student-api -n student-api
echo.
echo # Check migration logs:
echo kubectl logs -l app=student-api -c migration -n student-api

pause