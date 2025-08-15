@echo off
REM Local CI Pipeline Runner for Windows
REM Simulates the GitHub Actions CI pipeline locally

echo Starting Local CI Pipeline...
echo ==================================

REM Check prerequisites
echo [INFO] Checking prerequisites...

where go >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Go is not installed
    exit /b 1
)
k
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed
    exit /b 1
)

where make >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Make is not installed
    exit /b 1
)

echo [SUCCESS] Prerequisites check passed

REM Stage 1: Install dependencies
echo [INFO] Stage 1: Installing dependencies...
make deps
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies
    exit /b 1
)
echo [SUCCESS] Dependencies installed

REM Stage 2: Build API
echo [INFO] Stage 2: Building API...
make build
if %errorlevel% neq 0 (
    echo [ERROR] Failed to build API
    exit /b 1
)
echo [SUCCESS] API built successfully

REM Stage 3: Run tests
echo [INFO] Stage 3: Running tests...
make test
if %errorlevel% neq 0 (
    echo [ERROR] Tests failed
    exit /b 1
)
echo [SUCCESS] Tests passed

REM Stage 4: Code linting
echo [INFO] Stage 4: Running code linting...
make lint
if %errorlevel% neq 0 (
    echo [WARNING] Linting failed or golangci-lint not installed
)

REM Stage 5: Docker operations
echo [INFO] Stage 5: Docker operations...

if "%DOCKER_USERNAME%"=="" (
    echo [WARNING] Docker credentials not provided. Building locally only.
    docker build -t bournemouth-uni-api:local .
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to build Docker image
        exit /b 1
    )
    echo [SUCCESS] Docker image built locally
) else (
    echo [INFO] Logging into Docker...
    echo %DOCKER_PASSWORD% | docker login -u %DOCKER_USERNAME% --password-stdin
    if %errorlevel% neq 0 (
        echo [ERROR] Docker login failed
        exit /b 1
    )
    
    echo [INFO] Building and pushing Docker images...
    docker build -t %DOCKER_USERNAME%/bournemouth-uni-api:latest .
    docker push %DOCKER_USERNAME%/bournemouth-uni-api:latest
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to build or push Docker images
        exit /b 1
    )
    echo [SUCCESS] Docker images built and pushed successfully
)

echo ==================================
echo [SUCCESS] CI Pipeline completed successfully!
echo.
echo Summary:
echo   - Dependencies installed
echo   - API built
echo   - Tests passed
echo   - Linting completed
echo   - Docker operations completed
echo.
echo To run with Docker credentials:
echo set DOCKER_USERNAME=your_username
echo set DOCKER_PASSWORD=your_password
echo run-ci.bat
pause