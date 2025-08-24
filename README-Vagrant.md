# Vagrant Deployment Guide

## Prerequisites

- **Vagrant** 2.3+ installed
- **VirtualBox** 6.1+ installed
- At least 4GB RAM available for the VM

## Quick Start

1. **Start the Vagrant environment:**
```bash
vagrant up
```

2. **Access the application:**
- **Load Balanced API**: http://localhost:8080
- **Direct API 1**: http://localhost:8081  
- **Direct API 2**: http://localhost:8082

## Architecture

The Vagrant setup creates:
- **1 Ubuntu 24.04 VM** with 2GB RAM, 2 CPUs
- **2 API containers** (student_api_1, student_api_2) on ports 8081, 8082
- **1 PostgreSQL container** with persistent data
- **1 Nginx container** on port 8080 for load balancing

## Vagrant Commands

```bash
# Start the VM and deploy application
vagrant up

# SSH into the VM
vagrant ssh

# Stop the VM
vagrant halt

# Destroy the VM
vagrant destroy

# Reload VM with new configuration
vagrant reload

# Re-run provisioning
vagrant provision
```

## Inside the VM

Once you SSH into the VM (`vagrant ssh`), you can use:

```bash
# View application logs
cd /vagrant
make vagrant-logs

# Stop the application
make vagrant-stop

# Restart the application
make vagrant-deploy

# Check container status
docker ps

# View individual container logs
docker logs student_api_1
docker logs student_api_2
docker logs nginx_lb
```

## Load Balancer Testing

Test the load balancing by making multiple requests:

```bash
# From your host machine
curl http://localhost:8080/healthcheck
curl http://localhost:8080/api/v1/students

# Check which container handled the request in logs
vagrant ssh -c "cd /vagrant && docker logs student_api_1 --tail 5"
vagrant ssh -c "cd /vagrant && docker logs student_api_2 --tail 5"
```

## Troubleshooting

**VM won't start:**
- Ensure VirtualBox is installed and running
- Check available system resources (RAM/CPU)
- Try `vagrant destroy && vagrant up`

**VirtualBox Host-Only Network Error:**
- Run VirtualBox as Administrator
- In VirtualBox: File → Host Network Manager → Create new adapter
- Or disable private network in Vagrantfile (already done)
- Alternative: Use `config.vm.network "private_network", type: "dhcp"`

**Application not accessible:**
- Check if containers are running: `vagrant ssh -c "docker ps"`
- View logs: `vagrant ssh -c "cd /vagrant && make vagrant-logs"`
- Restart deployment: `vagrant ssh -c "cd /vagrant && make vagrant-deploy"`

**Port conflicts:**
- Ensure ports 8080, 8081, 8082 are not in use on host
- Modify port mappings in Vagrantfile if needed

## File Structure

```
vagrant/
├── provision.sh      # Dependency installation script
└── nginx.conf        # Nginx load balancer configuration

docker-compose.vagrant.yml  # Multi-container setup
Vagrantfile                  # VM configuration
```

## Customization

**Change VM resources:**
Edit `Vagrantfile`:
```ruby
vb.memory = "4096"  # 4GB RAM
vb.cpus = 4         # 4 CPUs
```

**Add more API containers:**
Edit `docker-compose.vagrant.yml` and add app3, app4, etc.

**Modify load balancer:**
Edit `vagrant/nginx.conf` to change balancing strategy or add health checks.