# Bournemouth University IT Student API

A comprehensive RESTful API for managing Bournemouth University IT students built with Go and Gin framework, featuring multiple deployment options including Docker, Vagrant, and CI/CD pipelines.

## 🚀 Features

- ✅ **CRUD operations** for student records
- ✅ **API versioning** (v1)
- ✅ **Database migrations** with PostgreSQL
- ✅ **Environment-based configuration**
- ✅ **Request logging middleware**
- ✅ **Health check endpoint**
- ✅ **Comprehensive unit tests**
- ✅ **Web interface** for student management
- ✅ **Load balancing** with Nginx
- ✅ **Containerized deployment**
- ✅ **Vagrant virtualization**
- ✅ **CI/CD pipeline** with GitHub Actions

## 📋 Prerequisites

### For Local Development
- **Go 1.21** or higher
- **PostgreSQL 12** or higher
- **Git** for cloning the repository

### For Docker Deployment
- **Docker** 20.10+ and **Docker Compose** v2
- **Make** (optional, for convenience commands)

### For Vagrant Deployment
- **Vagrant** 2.3+ installed
- **VirtualBox** 6.1+ installed
- At least **4GB RAM** available for the VM

## 🏗️ Architecture

### Standard Deployment
- **1 API container** on port 8080
- **1 PostgreSQL container** on port 5433
- **Web interface** served at root path

### Vagrant Deployment (Load Balanced)
- **2 API containers** on ports 8081, 8082
- **1 PostgreSQL container** with persistent data
- **1 Nginx load balancer** on port 8080
- **Ubuntu 24.04 VM** with 2GB RAM, 2 CPUs

## 🚀 Quick Start Guide

### Option 1: Docker Deployment (Recommended)

#### Method A: Using Makefile
```bash
git clone https://github.com/yourusername/bournemouth-uni-it-api-go.git
cd bournemouth-uni-it-api-go
make docker-up
```

#### Method B: Using Docker Compose
```bash
git clone https://github.com/yourusername/bournemouth-uni-it-api-go.git
cd bournemouth-uni-it-api-go
docker compose up -d
```

#### Method C: Manual Docker Commands
```bash
# 1. Create Docker network
docker network create app-network

# 2. Start PostgreSQL container
docker run -d \
  --name postgres_db \
  --network app-network \
  -e POSTGRES_DB=student_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5433:5432 \
  postgres:15-alpine

# 3. Wait for PostgreSQL to be ready
until docker exec postgres_db pg_isready -U postgres >/dev/null 2>&1; do
  echo "Waiting for PostgreSQL..."
  sleep 3
done

# 4. Start the application
docker run -d \
  --name student_api \
  --network app-network \
  -e DB_HOST=postgres_db \
  -e DB_PORT=5432 \
  -e DB_USER=postgres \
  -e DB_PASSWORD=postgres \
  -e DB_NAME=student_db \
  -e DB_SSL_MODE=disable \
  -e SERVER_PORT=8080 \
  -p 8080:8080 \
  tenifuzy01/v1:latest
```

**Access Points:**
- **Web Interface**: http://localhost:8080
- **API**: http://localhost:8080/api/v1/students
- **Health Check**: http://localhost:8080/healthcheck
- **PostgreSQL**: localhost:5433

### Option 2: Vagrant Deployment (Load Balanced)

#### Prerequisites Check
```bash
# Verify installations
vagrant --version
VBoxManage --version
```

#### Deploy with Vagrant
```bash
# Clone and start
git clone https://github.com/yourusername/bournemouth-uni-it-api-go.git
cd bournemouth-uni-it-api-go

# Start Vagrant environment (this will take 5-10 minutes)
vagrant up
```

#### Vagrant Management
```bash
# Check status
vagrant status
make vagrant-status

# SSH into VM
vagrant ssh

# Inside VM - manage application
cd /vagrant
make vagrant-logs
docker ps

# Exit VM
exit

# Stop VM (from host)
vagrant halt

# Destroy VM
vagrant destroy
```

**Access Points:**
- **Load Balanced API**: http://localhost:8080
- **Direct API 1**: http://localhost:8081
- **Direct API 2**: http://localhost:8082

### Option 3: Local Development

#### 1. Environment Setup
```bash
git clone https://github.com/yourusername/bournemouth-uni-it-api-go.git
cd bournemouth-uni-it-api-go

# Set up environment variables
cp .env.example .env
```

#### 2. Configure Database
Edit `.env` file:
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password_here
DB_NAME=student_db
DB_SSL_MODE=disable
SERVER_PORT=8080
```

#### 3. Install Dependencies and Run
```bash
# Install Go dependencies
go mod download

# Start PostgreSQL (if not using Docker)
docker compose up postgres -d

# Start the API
go run main.go
```

## 📖 API Documentation

### Base URL
```
http://localhost:8080
```

### Health Check
```http
GET /healthcheck
```
**Response:**
```json
{
  "status": "ok",
  "message": "API is running"
}
```

### Student Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/students` | Get all students |
| GET | `/api/v1/students/:id` | Get student by ID |
| POST | `/api/v1/students` | Create new student |
| PUT | `/api/v1/students/:id` | Update existing student |
| DELETE | `/api/v1/students/:id` | Delete student |

### Student Model
```json
{
  "id": 1,
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@bournemouth.ac.uk",
  "student_id": "S12345678",
  "course": "Information Technology",
  "year_of_study": 2,
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

### Example API Calls

#### Create a Student
```bash
curl -X POST http://localhost:8080/api/v1/students \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "John",
    "last_name": "Doe",
    "email": "john.doe@bournemouth.ac.uk",
    "student_id": "S12345678",
    "course": "Information Technology",
    "year_of_study": 2
  }'
```

#### Get All Students
```bash
curl http://localhost:8080/api/v1/students
```

#### Update a Student
```bash
curl -X PUT http://localhost:8080/api/v1/students/1 \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Jane",
    "last_name": "Smith",
    "email": "jane.smith@bournemouth.ac.uk",
    "student_id": "S12345678",
    "course": "Information Technology",
    "year_of_study": 3
  }'
```

## 🧪 Testing

### Run Unit Tests
```bash
# Using Make
make test

# Direct Go command
go test ./tests -v
```

### Run Tests with Coverage
```bash
make test-coverage
```

### Load Balancer Testing (Vagrant only)
```bash
# Test load balancing
for i in {1..10}; do
  curl -s http://localhost:8080/healthcheck
done

# Check which containers handled requests
vagrant ssh -c "cd /vagrant && docker logs student_api_1 --tail 5"
vagrant ssh -c "cd /vagrant && docker logs student_api_2 --tail 5"
```

## 🗄️ Database Management

### Automatic Migrations
The API automatically runs database migrations on startup. The student table will be created if it doesn't exist.

### Manual Database Access

#### Docker Deployment
```bash
# Access PostgreSQL container
docker exec -it postgres_db psql -U postgres -d student_db

# From host (if psql installed)
psql -h localhost -p 5433 -U postgres -d student_db
```

#### Vagrant Deployment
```bash
# SSH into VM first
vagrant ssh

# Then access database
docker exec -it postgres_db psql -U postgres -d student_db
```

### Database Commands
```sql
-- List tables
\dt

-- View all students
SELECT * FROM students;

-- Exit
\q
```

## 🛠️ Development Commands

### Makefile Commands

#### Docker Operations
```bash
make docker-up      # Start all services
make docker-down    # Stop all services
make docker-logs    # View logs
make docker-build   # Build Docker image
make docker-clean   # Clean up containers and images
```

#### Vagrant Operations
```bash
make vagrant-up       # Start Vagrant VM
make vagrant-status   # Check VM and application status
make vagrant-logs     # View application logs
make vagrant-halt     # Stop Vagrant VM
make vagrant-destroy  # Destroy Vagrant VM
```

#### Development
```bash
make build          # Build application locally
make run            # Run application locally
make test           # Run unit tests
make fmt            # Format Go code
make deps           # Install dependencies
make help           # Show all available commands
```

## 📁 Project Structure
```
bournemouth-uni-it-api-go/
├── .github/workflows/     # CI/CD pipeline
├── config/               # Configuration management
├── db/                   # Database connection and migrations
├── frontend/             # Web interface files
├── handlers/             # HTTP request handlers
├── middleware/           # Custom middleware
├── migrations/           # Database migration files
├── models/               # Data models and repository interfaces
├── postman/              # Postman collection for API testing
├── router/               # Route definitions
├── tests/                # Unit tests
├── vagrant/              # Vagrant provisioning scripts
├── docker-compose.yml    # Standard Docker Compose
├── docker-compose.vagrant.yml  # Vagrant Docker Compose
├── Dockerfile            # Container build instructions
├── Vagrantfile           # VM configuration
├── Makefile              # Build and deployment commands
├── go.mod                # Go module dependencies
├── main.go               # Application entry point
└── README.md             # This file
```

## 🔧 Troubleshooting

### Docker Issues

**Container Exits:**
```bash
# Check logs
make docker-logs

# Restart services
make docker-down && make docker-up
```

**Port Conflicts:**
```bash
# Stop services
make docker-down

# Kill processes using ports
sudo lsof -ti:8080 | xargs sudo kill -9

# Restart
make docker-up
```

**Database Connection Error:**
```bash
# Check container status
docker ps

# Restart database
docker compose up postgres -d

# Check logs
docker logs postgres_db
```

### Vagrant Issues

**VM Won't Start:**
```bash
# Check VirtualBox
VBoxManage list vms

# Destroy and recreate
vagrant destroy -f
vagrant up
```

**VirtualBox Host-Only Network Error:**
1. Run VirtualBox as Administrator
2. Go to: File → Host Network Manager
3. Create new Host-Only adapter
4. Try `vagrant up` again

**Application Not Accessible:**
```bash
# Check VM status
vagrant status

# Check containers inside VM
vagrant ssh -c "docker ps"

# Restart deployment
vagrant ssh -c "cd /vagrant && make vagrant-deploy"
```

### General Issues

**Build Failures:**
```bash
# Clean and rebuild
make clean
make build

# Update dependencies
make deps
```

**Permission Issues (Linux/Mac):**
```bash
# Make scripts executable
chmod +x *.sh
chmod +x vagrant/*.sh
```

## 🚀 CI/CD Pipeline

The project includes GitHub Actions workflows:

### Continuous Integration
- **Triggers**: Push to main/develop, Pull Requests
- **Tests**: Unit tests with PostgreSQL service
- **Build**: Docker image build and push
- **Lint**: Code quality checks (currently disabled)

### Deployment
- **Triggers**: Release creation
- **Actions**: Deploy to production server via SSH

### Setup GitHub Secrets
```
DOCKER_USERNAME - Docker Hub username
DOCKER_PASSWORD - Docker Hub password
HOST           - Production server IP
USERNAME       - SSH username
SSH_KEY        - Private SSH key
```

## 🤝 Contributing

1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/new-feature`
3. **Make changes and add tests**
4. **Test locally**: `make test`
5. **Test with Docker**: `make docker-up`
6. **Test with Vagrant**: `make vagrant-up`
7. **Commit changes**: `git commit -m "Add new feature"`
8. **Push and create Pull Request**

### Development Workflow
```bash
# Setup development environment
make dev-setup

# Make changes to code
# ...

# Test changes
make test
make docker-up

# Format code
make fmt

# Commit changes
git add .
git commit -m "Your commit message"
git push origin feature-branch
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support or questions:
- **Create an issue** in the GitHub repository
- **Check troubleshooting** section above
- **Review logs** using `make docker-logs` or `make vagrant-logs`

## 🎯 Quick Reference

### Essential Commands
```bash
# Standard deployment
make docker-up

# Vagrant deployment
vagrant up

# View logs
make docker-logs        # Standard
make vagrant-logs       # Vagrant

# Stop services
make docker-down        # Standard
vagrant halt           # Vagrant

# Access database
docker exec -it postgres_db psql -U postgres -d student_db
```

### Access URLs
- **Standard**: http://localhost:8080
- **Vagrant Load Balanced**: http://localhost:8080
- **Vagrant API 1**: http://localhost:8081
- **Vagrant API 2**: http://localhost:8082
- **Health Check**: http://localhost:8080/healthcheck
- **API Endpoints**: http://localhost:8080/api/v1/students