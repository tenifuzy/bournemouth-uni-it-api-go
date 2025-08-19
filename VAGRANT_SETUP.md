# Vagrant Setup Guide

## Prerequisites

1. **VirtualBox** - Download from https://www.virtualbox.org/
2. **Vagrant** - Download from https://www.vagrantup.com/

## Quick Start

### 1. Start Vagrant VM
```bash
make vagrant-up
# or
vagrant up
```

### 2. Check Status
```bash
make vagrant-status
# or
vagrant status
```

### 3. Access Application
- **Nginx Load Balancer**: http://localhost:8080
- **API Container 1**: http://localhost:8081  
- **API Container 2**: http://localhost:8082
- **Health Check**: http://localhost:8080/healthcheck

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Vagrant VM (Ubuntu)                      │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                Docker Network                           │ │
│  │                                                         │ │
│  │  ┌─────────┐    ┌─────────┐    ┌─────────┐             │ │
│  │  │  API1   │    │  API2   │    │ Nginx   │             │ │
│  │  │ :8080   │    │ :8080   │    │ :8080   │             │ │
│  │  └─────────┘    └─────────┘    └─────────┘             │ │
│  │       │              │              │                  │ │
│  │       └──────────────┼──────────────┘                  │ │
│  │                      │                                 │ │
│  │                 ┌─────────┐                            │ │
│  │                 │PostgreSQL│                           │ │
│  │                 │  :5432   │                           │ │
│  │                 └─────────┘                            │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
         │              │              │
    Port 8080      Port 8081      Port 8082
    (Nginx LB)     (API1)         (API2)
```

## Services

### Nginx Load Balancer
- **Port**: 8080
- **Function**: Load balances between API1 and API2
- **Config**: `nginx/nginx.conf`

### API Containers
- **API1**: Port 8081 (internal 8080)
- **API2**: Port 8082 (internal 8080)
- **Function**: Handle student management requests

### PostgreSQL Database
- **Port**: 5432
- **Database**: student_db
- **Credentials**: postgres/postgres

## Testing Load Balancing

### Using curl
```bash
# Test load balancer
curl http://localhost:8080/healthcheck

# Test individual APIs
curl http://localhost:8081/healthcheck
curl http://localhost:8082/healthcheck

# Test API endpoints through load balancer
curl http://localhost:8080/api/v1/students
```

### Using Postman
1. Import collection from `postman/bournemouth_uni_it_api.json`
2. Update base URL to `http://localhost:8080`
3. Test all endpoints - requests will be load balanced

## Vagrant Commands

```bash
# Start VM
vagrant up

# SSH into VM
vagrant ssh

# Stop VM
vagrant halt

# Destroy VM
vagrant destroy

# Reload VM with new config
vagrant reload

# Check VM status
vagrant status
```

## Troubleshooting

### VM Issues
```bash
# Check VM status
vagrant status

# View VM logs
vagrant up --debug

# Restart VM
vagrant reload
```

### Container Issues
```bash
# SSH into VM
vagrant ssh

# Check containers
docker-compose ps

# View logs
docker-compose logs nginx
docker-compose logs api1
docker-compose logs api2

# Restart services
docker-compose restart
```

### Port Conflicts
If ports are already in use:
1. Stop conflicting services
2. Or modify ports in Vagrantfile
3. Run `vagrant reload`

## Development Workflow

1. Make code changes on host machine
2. Files are synced to VM automatically
3. Rebuild and restart:
   ```bash
   vagrant ssh
   cd /vagrant
   make vagrant-deploy
   ```

## Cleanup

```bash
# Stop and remove VM
vagrant destroy -f

# Clean up VirtualBox
# (Optional) Remove VM from VirtualBox GUI
```