#!/bin/bash

# Bournemouth University API Setup Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Update system
update_system() {
    print_status "Updating system packages..."
    sudo apt-get update -y
    sudo apt-get upgrade -y
    print_success "System updated"
}

# Install Docker
install_docker() {
    print_status "Installing Docker..."
    if command -v docker &> /dev/null; then
        print_success "Docker already installed"
        return
    fi
    
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    print_success "Docker installed"
}

# Install Docker Compose
install_docker_compose() {
    print_status "Installing Docker Compose..."
    if command -v docker-compose &> /dev/null; then
        print_success "Docker Compose already installed"
        return
    fi
    
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installed"
}

# Install Make
install_make() {
    print_status "Installing Make..."
    if command -v make &> /dev/null; then
        print_success "Make already installed"
        return
    fi
    
    sudo apt-get install -y build-essential
    print_success "Make installed"
}

# Install Go
install_go() {
    print_status "Installing Go..."
    if command -v go &> /dev/null; then
        print_success "Go already installed"
        return
    fi
    
    wget -q https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    rm go1.21.0.linux-amd64.tar.gz
    print_success "Go installed"
}

# Setup application
setup_application() {
    print_status "Setting up application..."
    cd /vagrant
    
    # Copy environment file
    if [ ! -f .env ]; then
        cp .env.example .env
        print_success "Environment file created"
    fi
    
    # Build and start services
    make vagrant-deploy
    print_success "Application deployed"
}

# Main setup function
main() {
    print_status "Starting Bournemouth University API setup..."
    
    update_system
    install_docker
    install_docker_compose
    install_make
    install_go
    setup_application
    
    print_success "Setup completed successfully!"
    echo ""
    print_status "Application URLs:"
    echo "  - Nginx Load Balancer: http://192.168.56.10:8080"
    echo "  - API Container 1: http://192.168.56.10:8081"
    echo "  - API Container 2: http://192.168.56.10:8082"
    echo "  - Health Check: http://192.168.56.10:8080/healthcheck"
}

main "$@"