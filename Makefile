.PHONY: help build run test clean docker-build docker-up docker-down docker-logs db-start db-migrate fmt deps lint ci-local vagrant-up vagrant-deploy vagrant-status

# Variables
APP_NAME=student_api
DOCKER_IMAGE=tenifuzy01/v1:latest
POSTGRES_CONTAINER=postgres_db

# Default target
help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Vagrant commands:"
	@echo "  vagrant-up       - Start Vagrant VM"
	@echo "  vagrant-deploy   - Deploy application in Vagrant"
	@echo "  vagrant-status   - Check Vagrant and application status"

# Local development
build: ## Build the application locally
	go build -o main .

run: ## Run the application locally (requires local PostgreSQL)
	go run main.go

test: ## Run unit tests
	go test ./tests -v

test-coverage: ## Run tests with coverage
	go test ./tests -v -cover

fmt: ## Format Go code
	go fmt ./...

deps: ## Install dependencies
	go mod download
	go mod tidy

lint: ## Run code linting
	@echo "Linting disabled - formatting issues need manual fix"
	# golangci-lint run

clean: ## Clean build artifacts
	rm -f main

# Docker operations
docker-build: ## Build Docker image
	docker build -t $(DOCKER_IMAGE) .

docker-up: ## Start all services with Docker Compose
	docker compose down -v 2>/dev/null || true
	docker compose build
	docker compose up -d
	@echo "Waiting for services to start..."
	@sleep 15
	@echo "Services started! Check with: docker compose ps"

docker-down: ## Stop all services
	docker compose down

docker-logs: ## View logs from all services
	docker compose logs -f

docker-restart: ## Restart all services
	docker compose restart

# Database operations
db-start: ## Start only PostgreSQL container
	docker compose up postgres -d

db-stop: ## Stop PostgreSQL container
	docker compose stop postgres

db-migrate: ## Run database migrations (requires running database)
	@echo "Migrations are automatically run when the application starts"

# Development workflow
dev-setup: ## Set up development environment
	cp .env.example .env
	go mod download

dev-restart: docker-down docker-build docker-up ## Rebuild and restart everything

# Cleanup
docker-clean: ## Remove containers and images
	docker compose down -v
	docker rmi $(DOCKER_IMAGE) 2>/dev/null || true

docker-force-clean: ## Force remove all containers and networks
	docker stop postgres_db student_api 2>/dev/null || true
	docker rm postgres_db student_api 2>/dev/null || true
	docker network rm app-network 2>/dev/null || true
	docker compose down -v 2>/dev/null || true

# Quick commands
up: docker-up ## Alias for docker-up
down: docker-down ## Alias for docker-down
logs: docker-logs ## Alias for docker-logs

# Vagrant commands
vagrant-build: ## Build Docker image for Vagrant
	docker build -t tenifuzy01/v1:latest .

vagrant-deploy: ## Deploy application in Vagrant
	docker-compose -f docker-compose.vagrant.yml down || true
	docker-compose -f docker-compose.vagrant.yml build
	docker-compose -f docker-compose.vagrant.yml up -d
	@echo "Application deployed! Access at http://localhost:8080"

vagrant-logs: ## View Vagrant deployment logs
	docker-compose -f docker-compose.vagrant.yml logs -f

vagrant-stop: ## Stop Vagrant deployment
	docker-compose -f docker-compose.vagrant.yml down

ci-local: ## Run CI pipeline locally
	@if [ "$$OS" = "Windows_NT" ]; then \
		.\run-ci.bat; \
	else \
		chmod +x run-ci.sh && ./run-ci.sh; \
	fi

# Vagrant targets
vagrant-up: ## Start Vagrant VM
	vagrant up

vagrant-deploy: ## Deploy application in Vagrant
	docker compose down -v || true
	docker compose build
	docker compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 30
	@echo "Application deployed successfully!"

vagrant-status: ## Check Vagrant and application status
	vagrant status
	docker compose ps
	@echo "Testing endpoints..."
	@curl -s http://localhost:8080/healthcheck || echo "Nginx not ready"
	@curl -s http://localhost:8081/healthcheck || echo "API1 not ready"
	@curl -s http://localhost:8082/healthcheck || echo "API2 not ready"

vagrant-halt: ## Stop Vagrant VM
	vagrant halt

vagrant-ssh: ## SSH into Vagrant VM
	vagrant ssh

vagrant-destroy: ## Destroy Vagrant VM
	vagrant destroy -f