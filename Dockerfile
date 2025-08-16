# Build stage of building a Go application using Docker
# This Dockerfile uses a multi-stage build to create a lightweight final image.
# The first stage builds the Go application, and the second stage creates a minimal image with the binary.
# The final image is based on Alpine Linux for a smaller footprint.
# The application listens on port 8080 and includes migrations.
# Ensure that the Go application is built with CGO disabled for compatibility.
# The final image includes necessary CA certificates for HTTPS requests.
# The binary is copied from the builder stage, along with any necessary migrations.
# The application is set to run in the root directory of the final image.
# The Dockerfile is designed to be efficient and secure, minimizing the size of the final image.
# The application is built with Go version 1.21 on Alpine Linux. 
# The final image is based on the latest Alpine Linux version.
# The application is expected to run on port 8080, which is exposed in the final   
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates
WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/main .
COPY --from=builder /app/migrations ./migrations

# Expose port
EXPOSE 8080

# Run the binary
CMD ["./main"]