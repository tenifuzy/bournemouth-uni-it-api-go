#!/bin/bash

# Test Load Balancer Script
echo "Testing Bournemouth University API Load Balancer"
echo "================================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test URLs
NGINX_URL="http://localhost:8080"
API1_URL="http://localhost:8081"
API2_URL="http://localhost:8082"

test_endpoint() {
    local url=$1
    local name=$2
    
    echo -e "${BLUE}Testing $name...${NC}"
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url/healthcheck")
    
    if [ "$response" = "200" ]; then
        echo -e "${GREEN}✓ $name: HTTP $response${NC}"
    else
        echo -e "${RED}✗ $name: HTTP $response${NC}"
    fi
}

# Test individual services
echo "Testing individual services:"
test_endpoint "$API1_URL" "API Container 1"
test_endpoint "$API2_URL" "API Container 2"
test_endpoint "$NGINX_URL" "Nginx Load Balancer"

echo ""
echo "Testing load balancing (10 requests):"
echo "======================================"

for i in {1..10}; do
    response=$(curl -s "$NGINX_URL/healthcheck")
    echo "Request $i: $response"
    sleep 0.5
done

echo ""
echo "Testing API endpoints through load balancer:"
echo "==========================================="

# Test GET students
echo -e "${BLUE}GET /api/v1/students${NC}"
curl -s "$NGINX_URL/api/v1/students" | head -c 100
echo ""

# Test health check
echo -e "${BLUE}GET /healthcheck${NC}"
curl -s "$NGINX_URL/healthcheck"
echo ""

echo ""
echo -e "${GREEN}Load balancer testing completed!${NC}"