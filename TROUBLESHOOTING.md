# Troubleshooting Browser Access Issues

## Quick Checks

### 1. Is Docker Running?
```bash
docker --version
docker-compose --version
```

### 2. Are Containers Running?
```bash
docker-compose ps
# or
make docker-logs
```

### 3. Test API Endpoint
```bash
curl http://localhost:8080/test
# Should return: {"message":"Server is working","status":"ok"}
```

## Common Issues & Solutions

### Issue 1: "This site can't be reached" or Connection Refused

**Cause**: Docker containers not running

**Solution**:
```bash
# Start Docker Desktop first, then:
make docker-up
# or
docker-compose up -d
```

### Issue 2: "404 Not Found" when accessing root

**Cause**: Frontend files not found

**Solution**:
```bash
# Check if frontend/index.html exists
ls frontend/index.html

# If missing, ensure it's committed to git
git add frontend/index.html
git commit -m "Add frontend files"
```

### Issue 3: API works but frontend doesn't load

**Cause**: Static file serving issue

**Test**:
```bash
# Test API
curl http://localhost:8080/api/v1/students

# Test frontend
curl http://localhost:8080/
```

**Solution**: Rebuild containers
```bash
make docker-down
make docker-build
make docker-up
```

### Issue 4: Port 8080 already in use

**Solution**:
```bash
# Find what's using port 8080
netstat -ano | findstr :8080  # Windows
lsof -ti:8080                 # Linux/Mac

# Kill the process or change port in docker-compose.yml
```

## Step-by-Step Debugging

### 1. Start Fresh
```bash
make docker-down
make docker-up
make docker-logs
```

### 2. Check Each Service
```bash
# Test database
docker-compose exec postgres psql -U postgres -d student_db -c "SELECT 1;"

# Test API
curl http://localhost:8080/healthcheck

# Test frontend
curl -I http://localhost:8080/
```

### 3. Manual Container Check
```bash
# Enter API container
docker-compose exec api sh

# Check if files exist
ls -la /root/frontend/
cat /root/frontend/index.html
```

## Quick Fixes

### Reset Everything
```bash
docker-compose down -v
docker system prune -f
make docker-up
```

### Local Development (Bypass Docker)
```bash
# If Docker issues persist, run locally:
cp .env.example .env
# Edit .env with local database settings
go run main.go
# Access: http://localhost:8080
```

## Getting Help

If issues persist:
1. Run `make docker-logs` and check for errors
2. Ensure Docker Desktop is running and healthy
3. Try accessing http://localhost:8080/test first
4. Check Windows Firewall/antivirus blocking port 8080