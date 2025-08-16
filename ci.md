name: CI Pipeline

on:
  push:
    paths:
      - '**.go'
      - 'go.mod'
      - 'go.sum'
      - 'Makefile'
      - 'Dockerfile'
      - 'docker-compose.yml'
      - 'migrations/**'
      - 'frontend/**'
  pull_request:
    paths:
      - '**.go'
      - 'go.mod'
      - 'go.sum'
      - 'Makefile'
      - 'Dockerfile'
      - 'docker-compose.yml'
      - 'migrations/**'
      - 'frontend/**'
  workflow_dispatch:

env:
  DOCKER_REGISTRY: docker.io
  DOCKER_IMAGE: bournemouth-uni-api

jobs:
  ci:
    runs-on: self-hosted
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: '1.21'

    - name: Install dependencies
      run: make deps

    - name: Build API
      run: make build

    - name: Run tests
      run: make test

    - name: Install golangci-lint
      run: |
        curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.54.2
        echo "$(go env GOPATH)/bin" >> $GITHUB_PATH

    - name: Run linting
      run: make lint

    - name: Docker login
      uses: docker/login-action@v3
      with:
        registry: ${{ env.DOCKER_REGISTRY }}
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Build and push Docker image
      run: |
        docker build -t ${{ env.DOCKER_REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}:${{ github.sha }} .
        docker build -t ${{ env.DOCKER_REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}:latest .
        docker push ${{ env.DOCKER_REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}:${{ github.sha }}
        docker push ${{ env.DOCKER_REGISTRY }}/${{ secrets.DOCKER_USERNAME }}/${{ env.DOCKER_IMAGE }}:latest
