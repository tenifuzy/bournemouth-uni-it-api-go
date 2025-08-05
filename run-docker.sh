#!/bin/bash

echo "Starting PostgreSQL container..."
docker run -d \
  --name postgres_db \
  -e POSTGRES_DB=student_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:15-alpine

echo "Waiting for PostgreSQL to be ready..."
sleep 10

echo "Starting application container..."
docker run --rm \
  --name student_api \
  --link postgres_db:postgres \
  -e DB_HOST=postgres \
  -e DB_PORT=5432 \
  -e DB_USER=postgres \
  -e DB_PASSWORD=postgres \
  -e DB_NAME=student_db \
  -e DB_SSL_MODE=disable \
  -e SERVER_PORT=8080 \
  -p 8080:8080 \
  tenifuzy01/v1:latest