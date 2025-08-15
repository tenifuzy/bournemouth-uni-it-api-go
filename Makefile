# Bournemouth University IT API Makefile

.PHONY: run build test clean deps migrate-up migrate-down db-start db-migrate docker-build docker-run docker-up docker-down docker-logs install-tools

# Default target
all: deps build

# Install dependencies
deps:
	go mod download
	go mod tidy

# Run the application
run:
	go run main.go

# Build the application
build:
	go build -o bin/api main.go

# Run tests
test:
	go test ./tests -v

# Run tests with coverage
test-coverage:
	go test ./tests -v -cover

# Clean build artifacts
clean:
	rm -rf bin/

# Format code
fmt:
	go fmt ./...

# Lint code (requires golangci-lint)
lint:
	golangci-lint run

# Create migration files
migrate-create:
	@read -p "Enter migration name: " name; \
	migrate create -ext sql -dir migrations $$name

# Run database migrations up
migrate-up:
	migrate -path migrations -database "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=$(DB_SSL_MODE)" up

# Run database migrations down
migrate-down:
	migrate -path migrations -database "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=$(DB_SSL_MODE)" down

# Start DB container
db-start:
	docker-compose up -d postgres

# Run DB DML migrations
db-migrate:
	docker-compose exec postgres psql -U postgres -d student_db -c "SELECT 'Migrations completed';"

# Build REST API docker image
docker-build:
	docker-compose build api

# Run REST API docker container
docker-run:
	docker-compose up -d api

# Start all services (DB + API)
docker-up:
	docker-compose up -d

# Stop all services
docker-down:
	docker-compose down

# View logs
docker-logs:
	docker-compose logs -f

# Install required tools
install-tools:
	@if [ "$$OS" = "Windows_NT" ]; then \
		echo "Run install-tools.bat as Administrator"; \
	else \
		chmod +x install-tools.sh && ./install-tools.sh; \
	fi

# Help
help:
	@echo "Available targets:"
	@echo "  run            - Run the application"
	@echo "  build          - Build the application"
	@echo "  test           - Run tests"
	@echo "  test-coverage  - Run tests with coverage"
	@echo "  deps           - Install dependencies"
	@echo "  clean          - Clean build artifacts"
	@echo "  fmt            - Format code"
	@echo "  lint           - Lint code"
	@echo "  migrate-up     - Run database migrations up"
	@echo "  migrate-down   - Run database migrations down"
	@echo "  db-start       - Start DB container"
	@echo "  db-migrate     - Run DB DML migrations"
	@echo "  docker-build   - Build REST API docker image"
	@echo "  docker-run     - Run REST API docker container"
	@echo "  docker-up      - Start all services (DB + API)"
	@echo "  docker-down    - Stop all services"
	@echo "  docker-logs    - View logs from all services"
	@echo "  install-tools  - Install required development tools"
	@echo "  help           - Show this help message"