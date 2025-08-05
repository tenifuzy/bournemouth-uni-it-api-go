# Docker Run Commands

## Step 1: Create Network
```bash
docker network create app-network
```

## Step 2: Start PostgreSQL Container
```bash
docker run -d \
  --name postgres_db \
  --network app-network \
  -e POSTGRES_DB=student_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:15-alpine
```

## Step 3: Wait for Database (15 seconds)
```bash
sleep 15
```

## Step 4: Start Application Container
```bash
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

## Useful Commands

### Check container logs
```bash
docker logs student_api
docker logs postgres_db
```

### Stop containers
```bash
docker stop student_api postgres_db
```

### Remove containers
```bash
docker rm student_api postgres_db
```

### Remove network
```bash
docker network rm app-network
```

## One-liner for Linux/Mac
```bash
docker network create app-network && docker run -d --name postgres_db --network app-network -e POSTGRES_DB=student_db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:15-alpine && sleep 15 && docker run -d --name student_api --network app-network -e DB_HOST=postgres_db -e DB_PORT=5432 -e DB_USER=postgres -e DB_PASSWORD=postgres -e DB_NAME=student_db -e DB_SSL_MODE=disable -e SERVER_PORT=8080 -p 8080:8080 tenifuzy01/v1:latest
```