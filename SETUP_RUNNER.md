# Self-Hosted GitHub Runner Setup

## Prerequisites

1. **AWS EC2 Instance** (or local machine)
   - Ubuntu 20.04+ or Windows Server
   - Minimum 2 CPU, 4GB RAM
   - Docker installed
   - Go 1.21+ installed

## Setup Steps

### 1. Create GitHub Runner

1. Go to your repository → Settings → Actions → Runners
2. Click "New self-hosted runner"
3. Select your OS (Linux/Windows)
4. Follow the download and configuration commands

### 2. Install Dependencies (Linux)

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Go
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# Install Make
sudo apt install build-essential -y
```

### 3. Configure Runner

```bash
# Download runner (replace with your repo URL)
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# Configure runner (use token from GitHub)
./config.sh --url https://github.com/yourusername/bournemouth-uni-it-api-go --token YOUR_TOKEN

# Install as service
sudo ./svc.sh install
sudo ./svc.sh start
```

### 4. Set GitHub Secrets

Go to repository → Settings → Secrets and variables → Actions

Add these secrets:
- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub password/token

## Verify Setup

1. Push code changes to trigger the pipeline
2. Check Actions tab for running workflows
3. Verify Docker images are pushed to Docker Hub

## Troubleshooting

**Runner offline:**
```bash
sudo ./svc.sh status
sudo ./svc.sh start
```

**Docker permission denied:**
```bash
sudo usermod -aG docker $USER
newgrp docker
```

**Go not found:**
```bash
export PATH=$PATH:/usr/local/go/bin
go version
```