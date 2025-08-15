#!/bin/bash

# Install required tools for Bournemouth University IT API

install_go() {
    if command -v go &> /dev/null; then
        echo "Go is already installed: $(go version)"
        return
    fi
    
    echo "Installing Go..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        wget -q https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
        sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        rm go1.21.0.linux-amd64.tar.gz
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install go
    fi
    echo "Go installed successfully"
}

install_docker() {
    if command -v docker &> /dev/null; then
        echo "Docker is already installed: $(docker --version)"
        return
    fi
    
    echo "Installing Docker..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install --cask docker
    fi
    echo "Docker installed successfully"
}

install_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        echo "Docker Compose is already installed: $(docker-compose --version)"
        return
    fi
    
    echo "Installing Docker Compose..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install docker-compose
    fi
    echo "Docker Compose installed successfully"
}

install_migrate() {
    if command -v migrate &> /dev/null; then
        echo "Migrate is already installed: $(migrate -version)"
        return
    fi
    
    echo "Installing golang-migrate..."
    go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
    echo "Migrate installed successfully"
}

install_make() {
    if command -v make &> /dev/null; then
        echo "Make is already installed: $(make --version | head -1)"
        return
    fi
    
    echo "Installing Make..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y build-essential
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        xcode-select --install
    fi
    echo "Make installed successfully"
}

main() {
    echo "Installing required tools for Bournemouth University IT API..."
    echo "=================================================="
    
    install_make
    install_go
    install_docker
    install_docker_compose
    install_migrate
    
    echo "=================================================="
    echo "Installation completed!"
    echo ""
    echo "Please restart your terminal or run: source ~/.bashrc"
    echo ""
    echo "To get started:"
    echo "  make docker-up    # Start the application"
    echo "  make help         # Show all available commands"
}

main "$@"