#!/bin/bash

# Local CI Pipeline Runner
# Simulates the GitHub Actions CI pipeline locally

set -e

echo "🚀 Starting Local CI Pipeline..."
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check prerequisites
print_status "Checking prerequisites..."

if ! command -v go &> /dev/null; then
    print_error "Go is not installed"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed"
    exit 1
fi

if ! command -v make &> /dev/null; then
    print_error "Make is not installed"
    exit 1
fi

print_success "Prerequisites check passed"

# Stage 1: Install dependencies
print_status "Stage 1: Installing dependencies..."
if make deps; then
    print_success "Dependencies installed"
else
    print_error "Failed to install dependencies"
    exit 1
fi

# Stage 2: Build API
print_status "Stage 2: Building API..."
if make build; then
    print_success "API built successfully"
else
    print_error "Failed to build API"
    exit 1
fi

# Stage 3: Run tests
print_status "Stage 3: Running tests..."
if make test; then
    print_success "Tests passed"
else
    print_error "Tests failed"
    exit 1
fi

# Stage 4: Code linting
print_status "Stage 4: Running code linting..."
if make lint; then
    print_success "Linting passed"
else
    print_warning "Linting failed or golangci-lint not installed"
fi

# Stage 5: Docker operations
print_status "Stage 5: Docker operations..."

# Check if Docker credentials are provided
if [ -z "$DOCKER_USERNAME" ] || [ -z "$DOCKER_PASSWORD" ]; then
    print_warning "Docker credentials not provided. Skipping Docker login and push."
    print_warning "Set DOCKER_USERNAME and DOCKER_PASSWORD environment variables to enable Docker operations."
    
    # Just build locally
    print_status "Building Docker image locally..."
    if docker build -t bournemouth-uni-api:local .; then
        print_success "Docker image built locally"
    else
        print_error "Failed to build Docker image"
        exit 1
    fi
else
    # Docker login
    print_status "Logging into Docker..."
    if echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin; then
        print_success "Docker login successful"
    else
        print_error "Docker login failed"
        exit 1
    fi
    
    # Build and push
    IMAGE_TAG=$(git rev-parse --short HEAD 2>/dev/null || echo "local")
    DOCKER_IMAGE="$DOCKER_USERNAME/bournemouth-uni-api"
    
    print_status "Building and pushing Docker images..."
    
    if docker build -t "$DOCKER_IMAGE:$IMAGE_TAG" . && \
       docker build -t "$DOCKER_IMAGE:latest" . && \
       docker push "$DOCKER_IMAGE:$IMAGE_TAG" && \
       docker push "$DOCKER_IMAGE:latest"; then
        print_success "Docker images built and pushed successfully"
    else
        print_error "Failed to build or push Docker images"
        exit 1
    fi
fi

echo "=================================="
print_success "🎉 CI Pipeline completed successfully!"
echo ""
print_status "Summary:"
echo "  ✅ Dependencies installed"
echo "  ✅ API built"
echo "  ✅ Tests passed"
echo "  ✅ Linting completed"
echo "  ✅ Docker operations completed"
echo ""
print_status "To run with Docker credentials:"
print_status "DOCKER_USERNAME=your_username DOCKER_PASSWORD=your_password ./run-ci.sh"