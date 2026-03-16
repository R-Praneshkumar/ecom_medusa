#!/bin/bash
# ============================================
# Medusa E-Commerce - Quick Init & Deploy
# Just run: bash init.sh
# ============================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "=========================================="
echo "  Medusa E-Commerce - Quick Deploy"
echo "=========================================="
echo ""

# Get VPS IP automatically
VPS_IP=$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
echo -e "${CYAN}Detected IP:${NC} ${VPS_IP}"
echo ""

read -p "Use domain name? (leave empty to use IP ${VPS_IP}): " DOMAIN
DOMAIN=${DOMAIN:-$VPS_IP}

read -p "Admin email [admin@medusa.com]: " ADMIN_EMAIL
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@medusa.com}

read -sp "Admin password [supersecret]: " ADMIN_PASS
echo ""
ADMIN_PASS=${ADMIN_PASS:-supersecret}

# Generate secrets
JWT_SECRET=$(openssl rand -hex 32)
COOKIE_SECRET=$(openssl rand -hex 32)
PG_PASS=$(openssl rand -hex 16)
REVAL_SECRET=$(openssl rand -hex 16)

# Create .env
echo -e "${CYAN}[1/4]${NC} Creating .env..."
cat > .env << ENVEOF
POSTGRES_USER=medusa
POSTGRES_PASSWORD=${PG_PASS}
POSTGRES_DB=medusa_db
DATABASE_URL=postgres://medusa:${PG_PASS}@postgres:5432/medusa_db
REDIS_URL=redis://redis:6379
JWT_SECRET=${JWT_SECRET}
COOKIE_SECRET=${COOKIE_SECRET}
STORE_CORS=http://${DOMAIN},http://${DOMAIN}:8000
ADMIN_CORS=http://${DOMAIN},http://${DOMAIN}:9000
AUTH_CORS=http://${DOMAIN},http://${DOMAIN}:8000
NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://${DOMAIN}
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=temp_key
NEXT_PUBLIC_DEFAULT_REGION=us
REVALIDATE_SECRET=${REVAL_SECRET}
ENVEOF
echo -e "${GREEN}[OK]${NC} .env created"

# Update nginx domain
echo -e "${CYAN}[2/4]${NC} Configuring Nginx..."
# Reset nginx config from git before replacing domain
git checkout -- nginx/conf.d/default.conf 2>/dev/null || true
sed -i "s/DOMAIN_PLACEHOLDER/${DOMAIN}/g" nginx/conf.d/default.conf
echo -e "${GREEN}[OK]${NC} Nginx configured for ${DOMAIN}"

# Build and start
echo -e "${CYAN}[3/4]${NC} Building Docker images (5-10 min on 1 core)..."
docker compose up -d --build

echo -e "${CYAN}[4/4]${NC} Waiting for Medusa to start..."
echo "This may take 2-3 minutes..."
sleep 30

MAX=300
W=30
until curl -sf http://localhost:9000/health > /dev/null 2>&1; do
    sleep 10
    W=$((W+10))
    if [ $W -ge $MAX ]; then
        echo -e "${YELLOW}[WARN]${NC} Still starting... check: docker compose logs medusa"
        break
    fi
    echo -n "."
done
echo ""

# Create admin user
echo "Creating admin user..."
docker compose exec -T medusa npx medusa user -e "${ADMIN_EMAIL}" -p "${ADMIN_PASS}" 2>/dev/null || true

echo ""
echo "=========================================="
echo -e "${GREEN}  DEPLOYED!${NC}"
echo "=========================================="
echo ""
echo "  Storefront:  http://${DOMAIN}"
echo "  Admin Panel: http://${DOMAIN}/app"
echo "  Backend API: http://${DOMAIN}:9000"
echo "  Admin Login: ${ADMIN_EMAIL}"
echo ""
echo "  NEXT STEPS:"
echo "  1. Go to http://${DOMAIN}/app"
echo "  2. Login with your email/password"
echo "  3. Settings > Regions > Create region"
echo "  4. Settings > API Keys > Publishable key"
echo "  5. Update .env with the key"
echo "  6. docker compose up -d --build storefront"
echo ""
echo "  COMMANDS:"
echo "  Logs:    docker compose logs -f"
echo "  Stop:    docker compose down"
echo "  Restart: docker compose restart"
echo "  Seed:    docker compose exec medusa npx medusa exec ./src/scripts/seed.ts"
echo ""
