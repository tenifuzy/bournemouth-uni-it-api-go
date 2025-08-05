@echo off

REM Create Docker network
echo Creating Docker network...
docker network create app-network 2>nul

REM Stop and remove existing containers
echo Cleaning up existing containers...
docker stop postgres_db student_api 2>nul
docker rm postgres_db student_api 2>nul

REM Start PostgreSQL container
echo Starting PostgreSQL container...
docker run -d ^
  --name postgres_db ^
  --network app-network ^
  -e POSTGRES_DB=student_db ^
  -e POSTGRES_USER=postgres ^
  -e POSTGRES_PASSWORD=postgres ^
  -p 5432:5432 ^
  postgres:15-alpine

REM Wait for PostgreSQL to be ready
echo Waiting for PostgreSQL to start...
timeout /t 15 /nobreak >nul

REM Start application container
echo Starting application container...
docker run -d ^
  --name student_api ^
  --network app-network ^
  -e DB_HOST=postgres_db ^
  -e DB_PORT=5432 ^
  -e DB_USER=postgres ^
  -e DB_PASSWORD=postgres ^
  -e DB_NAME=student_db ^
  -e DB_SSL_MODE=disable ^
  -e SERVER_PORT=8080 ^
  -p 8080:8080 ^
  tenifuzy01/v1:latest

echo Application started!
echo API available at: http://localhost:8080
echo Health check: http://localhost:8080/healthcheck

pause