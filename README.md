# Bournemouth University IT Student API

A RESTful API for managing Bournemouth University IT students built with Go and Gin framework.

## Features

- ✅ CRUD operations for student records
- ✅ API versioning (v1)
- ✅ Database migrations with PostgreSQL
- ✅ Environment-based configuration
- ✅ Request logging middleware
- ✅ Health check endpoint
- ✅ Comprehensive unit tests
- ✅ Postman collection for API testing

## Prerequisites

- **Go 1.21** or higher
- **PostgreSQL 12** or higher
- **Docker** (for containerized deployment)
- **Git** (for cloning the repository)

## Quick Start

### Option 1: Using Makefile (Recommended)

```bash
git clone https://github.com/yourusername/bournemouth-uni-it-api-go.git
cd bournemouth-uni-it-api-go
make docker-up
```

**Access the Application:**
- **Web Interface**: http://localhost:8080
- **API**: http://localhost:8080/api/v1/students
- **Health Check**: http://localhost:8080/healthcheck

### Option 2: Using Docker Compose

```bash
git clone https://github.com/yourusername/bournemouth-uni-it-api-go.git
cd bournemouth-uni-it-api-go
docker compose up -d
```

### Option 3: Manual Docker Commands
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

#### Access the Application
- **API**: http://localhost:8080/api/v1/students
- **Health Check**: http://localhost:8080/healthcheck
- **PostgreSQL**: localhost:5433

### Option 4: Local Development

1. **Clone the Repository**
```bash
git clone https://github.com/yourusername/bournemouth-uni-it-api-go.git
cd bournemouth-uni-it-api-go
```

2. **Set Up Environment Variables**
```bash
cp .env.example .env
```

Edit `.env` file with your database credentials:
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password_here
DB_NAME=student_db
DB_SSL_MODE=disable
SERVER_PORT=8080
```

3. **Install Dependencies**
```bash
go mod download
```

4. **Start PostgreSQL** (if not using Docker)
```bash
docker compose up postgres -d
```

5. **Start the API**
```bash
go run main.go
```

The application will be available at: **http://localhost:8080**

## API Documentation

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

### Example Requests

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

## Testing

### Run Unit Tests
```bash
go test ./tests -v
```

### Run Tests with Coverage
```bash
go test ./tests -v -cover
```

## Database

### Automatic Migrations
The API automatically runs database migrations on startup. The student table will be created if it doesn't exist.

### Manual Migration Commands
If you need to run migrations manually:
```bash
# Install migrate tool
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Run migrations
migrate -path migrations -database "postgres://username:password@localhost:5432/student_db?sslmode=disable" up
```

## Project Structure
```
bournemouth-uni-it-api-go/
├── config/           # Configuration management
├── db/              # Database connection and migrations
├── handlers/        # HTTP request handlers
├── middleware/      # Custom middleware (logging, etc.)
├── migrations/      # Database migration files
├── models/          # Data models and repository interfaces
├── postman/         # Postman collection for API testing
├── router/          # Route definitions
├── tests/           # Unit tests
├── .env.example     # Environment variables template
├── .gitignore       # Git ignore rules
├── go.mod           # Go module dependencies
├── main.go          # Application entry point
└── README.md        # This file
```

## Postman Collection

Import the Postman collection from `postman/bournemouth_uni_it_api.json` to test all API endpoints with pre-configured requests.

## Makefile Commands

### Quick Operations
```bash
# Start everything
make docker-up

# Stop everything
make docker-down

# View logs
make docker-logs

# Rebuild and restart
make docker-down && make docker-build && make docker-up
```

### Step-by-Step Development
```bash
# Start database only
make db-start

# Run migrations
make db-migrate

# Build API image
make docker-build

# Run API container
make docker-run
```

### Development Commands
```bash
# Run tests
make test

# Format code
make fmt

# Build locally
make build

# Run locally (requires local PostgreSQL)
make run

# Show all available commands
make help
```

## Docker Commands (Alternative)

### Using Docker Run

#### Quick Start Script
```bash
# Make script executable and run
chmod +x run-no-port-conflict.sh
./run-no-port-conflict.sh
```

#### Manual Commands
```bash
# Create network
docker network create app-network

# Start PostgreSQL
docker run -d --name postgres_db --network app-network \
  -e POSTGRES_DB=student_db -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres -p 5433:5432 postgres:15-alpine

# Start application
docker run -d --name student_api --network app-network \
  -e DB_HOST=postgres_db -e DB_PORT=5432 -e DB_USER=postgres \
  -e DB_PASSWORD=postgres -e DB_NAME=student_db \
  -e DB_SSL_MODE=disable -e SERVER_PORT=8080 \
  -p 8080:8080 tenifuzy01/v1:latest
```

#### Container Management
```bash
# View running containers
docker ps

# View logs
docker logs student_api
docker logs postgres_db

# Stop containers
docker stop student_api postgres_db

# Remove containers
docker rm student_api postgres_db

# Remove network
docker network rm app-network
```

### Database Access
```bash
# Access PostgreSQL container directly
docker exec -it postgres_db psql -U postgres -d student_db

# Access from host (if psql is installed)
psql -h localhost -p 5433 -U postgres -d student_db
```

## Development

### Adding New Features
1. Create feature branch: `git checkout -b feature/new-feature`
2. Make changes and add tests
3. Test locally: `make test`
4. Test with Docker: `make docker-down && make docker-build && make docker-up`
5. Commit changes: `git commit -m "Add new feature"`
6. Push and create pull request

### Docker Development
```bash
# Rebuild image after code changes
make docker-build

# Clean up and restart
make docker-down && make docker-up

# View logs during development
make docker-logs
```

### Code Style
- Follow Go conventions and best practices
- Use `gofmt` for code formatting
- Add comments for exported functions
- Write unit tests for new features

## Troubleshooting

### Common Issues

**Docker Container Exits:**
- Check logs: `make docker-logs`
- Ensure PostgreSQL is running: `make db-start`
- Restart services: `make docker-down && make docker-up`

**Port Already in Use:**
- Stop services: `make docker-down`
- Kill existing processes: `sudo lsof -ti:8080 | xargs sudo kill -9`
- Restart: `make docker-up`

**Database Connection Error:**
- Check logs: `make docker-logs`
- Restart database: `make db-start`
- Test migrations: `make db-migrate`
- Rebuild everything: `make docker-down && make docker-build && make docker-up`

**Migration Errors:**
- Check migration files in `migrations/` directory
- Test migrations: `make db-migrate`
- Verify database user has CREATE/ALTER permissions

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support or questions, please create an issue in the GitHub repository.