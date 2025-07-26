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
- **Git** (for cloning the repository)

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/bournemouth-uni-it-api-go.git
cd bournemouth-uni-it-api-go
```

### 2. Set Up Environment Variables
Copy the example environment file and configure your database settings:
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

### 3. Install Dependencies
```bash
go mod download
```

### 4. Start the API
```bash
go run main.go
```

The API will be available at: **http://localhost:8080**

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

## Development

### Adding New Features
1. Create feature branch: `git checkout -b feature/new-feature`
2. Make changes and add tests
3. Run tests: `go test ./tests -v`
4. Commit changes: `git commit -m "Add new feature"`
5. Push and create pull request

### Code Style
- Follow Go conventions and best practices
- Use `gofmt` for code formatting
- Add comments for exported functions
- Write unit tests for new features

## Troubleshooting

### Common Issues

**Database Connection Error:**
- Verify PostgreSQL is running
- Check database credentials in `.env` file
- Ensure database exists or API has permission to create it

**Migration Errors:**
- Check migration files in `migrations/` directory
- Verify database user has CREATE/ALTER permissions
- Check migration file naming convention

**Port Already in Use:**
- Change `SERVER_PORT` in `.env` file
- Kill process using the port: `lsof -ti:8080 | xargs kill`

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