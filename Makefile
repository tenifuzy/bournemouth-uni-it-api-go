.PHONY: help build run test clean docker-build docker-up docker-down docker-logs db-start db-migrate fmt

# Variables
APP_NAME=student_api
DOCKER_IMAGE=tenifuzy01/v1:latest
POSTGRES_CONTAINER=postgres_db

# Default target
help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

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

clean: ## Clean build artifacts
	rm -f main

# Docker operations
docker-build: ## Build Docker image
	docker build -t $(DOCKER_IMAGE) .

docker-up: ## Start all services with Docker Compose
	docker stop postgres_db student_api 2>/dev/null || true
	docker rm postgres_db student_api 2>/dev/null || true
	docker compose up -d

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