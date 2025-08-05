#!/bin/bash

echo "Cleaning up..."
docker stop postgres_db student_api 2>/dev/null || true
docker rm postgres_db student_api 2>/dev/null || true
docker network rm app-network 2>/dev/null || true

echo "Creating network..."
docker network create app-network

echo "Starting PostgreSQL on port 5433 (to avoid conflicts)..."
docker run -d \
  --name postgres_db \
  --network app-network \
  -e POSTGRES_DB=student_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5433:5432 \
  postgres:15-alpine

echo "Waiting for PostgreSQL to be ready..."
until docker exec postgres_db pg_isready -U postgres >/dev/null 2>&1; do
  echo "PostgreSQL is starting up..."
  sleep 3
done
echo "PostgreSQL is ready!"

echo "Starting application..."
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

echo "Done! Application should be running at http://localhost:8080"
echo "PostgreSQL is accessible on localhost:5433"
echo "Check logs with: docker logs student_api"