# Bournemouth University IT API Makefile

.PHONY: run build test clean deps migrate-up migrate-down

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
	@echo "  help           - Show this help message"