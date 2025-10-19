@echo off
setlocal enabledelayedexpansion

echo 🚀 Deploying Bournemouth University IT Student API using Helm Charts
echo ====================================================================

REM Step 1: Deploy External Secrets Operator
echo 🔌 Deploying External Secrets Operator...
helm install external-secrets ./helm/external-secrets --create-namespace --wait --timeout=300s
if errorlevel 1 (
    echo ❌ Failed to deploy External Secrets Operator
    exit /b 1
)

REM Step 2: Deploy Vault
echo 🔐 Deploying HashiCorp Vault...
helm install vault ./helm/vault --namespace student-api --create-namespace --wait --timeout=300s
if errorlevel 1 (
    echo ❌ Failed to deploy Vault
    exit /b 1
)

REM Step 3: Deploy PostgreSQL
echo 🗄️  Deploying PostgreSQL database...
helm install postgresql ./helm/postgresql --namespace student-api --wait --timeout=300s
if errorlevel 1 (
    echo ❌ Failed to deploy PostgreSQL
    exit /b 1
)

REM Step 4: Deploy Student API
echo 🚀 Deploying Student API application...
helm install student-api ./helm/student-api --namespace student-api --wait --timeout=300s
if errorlevel 1 (
    echo ❌ Failed to deploy Student API
    exit /b 1
)

echo.
echo ✅ Helm deployment completed successfully!
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

pause