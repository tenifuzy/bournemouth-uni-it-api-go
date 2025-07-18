# Bournemouth University IT Student API

A RESTful API for managing Bournemouth University IT students built with Go and Gin.

## Features

- CRUD operations for student records
- API versioning
- Database migrations
- Environment-based configuration
- Logging middleware
- Health check endpoint
- Unit tests
- Postman collection

## Prerequisites

- Go 1.21 or higher
- PostgreSQL database

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/bournemouth-uni-it-api-go.git
   cd bournemouth-uni-it-api-go
   ```

2. Install dependencies:
   ```
   go mod download
   ```

3. Set up environment variables (or use the provided .env file):
   ```
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=postgres
   DB_NAME=student_db
   DB_SSL_MODE=disable
   SERVER_PORT=8080
   ```

## Running the API

1. Start the API:
   ```
   go run main.go
   ```

2. The API will be available at `http://localhost:8080`

## API Endpoints

### Health Check
- `GET /healthcheck` - Check if the API is running

### Student Endpoints
- `GET /api/v1/students` - Get all students
- `GET /api/v1/students/:id` - Get a student by ID
- `POST /api/v1/students` - Create a new student
- `PUT /api/v1/students/:id` - Update an existing student
- `DELETE /api/v1/students/:id` - Delete a student

## Student Model

```json
{
  "id": 1,
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@example.com",
  "student_id": "S12345",
  "course": "Information Technology",
  "year_of_study": 2,
  "created_at": "2023-06-01T12:00:00Z",
  "updated_at": "2023-06-01T12:00:00Z"
}
```

## Running Tests

```
go test ./tests -v
```

## Postman Collection

A Postman collection is provided in the `postman` directory for testing the API endpoints.

## Database Migrations

The API uses the golang-migrate library to manage database migrations. Migrations are automatically run when the API starts.

## License

This project is licensed under the MIT License - see the LICENSE file for details.