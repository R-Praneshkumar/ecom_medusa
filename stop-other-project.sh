#!/bin/bash
# ============================================
# Stop other running projects on VPS
# Run: chmod +x stop-other-project.sh && sudo ./stop-other-project.sh
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "=========================================="
echo "  Scanning for running services..."
echo "=========================================="
echo ""

# Show what's using resources
echo -e "${CYAN}[Docker Containers]${NC}"
if command -v docker &> /dev/null; then
    CONTAINERS=$(docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null)
    if [ -n "$CONTAINERS" ]; then
        echo "$CONTAINERS"
        echo ""
        read -p "Stop ALL Docker containers? (y/n): " STOP_DOCKER
        if [ "$STOP_DOCKER" = "y" ]; then
            docker stop $(docker ps -q) 2>/dev/null || true
            echo -e "${GREEN}[OK]${NC} All containers stopped"
        fi
    else
        echo "No running containers"
    fi
else
    echo "Docker not installed"
fi

echo ""
echo -e "${CYAN}[PM2 Processes]${NC}"
if command -v pm2 &> /dev/null; then
    pm2 list
    echo ""
    read -p "Stop ALL PM2 processes? (y/n): " STOP_PM2
    if [ "$STOP_PM2" = "y" ]; then
        pm2 stop all 2>/dev/null || true
        echo -e "${GREEN}[OK]${NC} All PM2 processes stopped"
    fi
else
    echo "PM2 not installed"
fi

echo ""
echo -e "${CYAN}[Ports in use (80, 443, 3000, 5432, 6379, 8000, 9000)]${NC}"
ss -tlnp | grep -E ':(80|443|3000|5432|6379|8000|9000) ' || echo "No conflicts on required ports"

echo ""
echo -e "${CYAN}[Memory Usage]${NC}"
free -h

echo ""
echo -e "${CYAN}[Disk Usage]${NC}"
df -h /

echo ""
echo "=========================================="
echo -e "${GREEN}  Done! Your VPS is ready for Medusa.${NC}"
echo "  Run: sudo ./deploy.sh yourdomain.com"
echo "=========================================="
