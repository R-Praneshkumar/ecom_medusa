#!/bin/bash
# ============================================
# VPS Initial Setup - Run this FIRST on VPS
# Creates all project files directly on server
# ============================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "=========================================="
echo "  Creating Medusa project on VPS..."
echo "=========================================="
echo ""

# Create project directory
mkdir -p /root/medusa/{backend,storefront,nginx/conf.d,scripts}
cd /root/medusa

echo -e "${CYAN}[1/6]${NC} Creating docker-compose.yml..."
cat > docker-compose.yml << 'DOCKEREOF'
services:
  postgres:
    image: postgres:15-alpine
    restart: always
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    command:
      - "postgres"
      - "-c"
      - "shared_buffers=256MB"
      - "-c"
      - "effective_cache_size=512MB"
      - "-c"
      - "work_mem=4MB"
      - "-c"
      - "max_connections=50"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - medusa_network

  redis:
    image: redis:7-alpine
    restart: always
    command: redis-server --maxmemory 64mb --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - medusa_network

  medusa:
    build:
      context: ./backend
      dockerfile: Dockerfile
    restart: always
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - JWT_SECRET=${JWT_SECRET}
      - COOKIE_SECRET=${COOKIE_SECRET}
      - STORE_CORS=${STORE_CORS}
      - ADMIN_CORS=${ADMIN_CORS}
      - AUTH_CORS=${AUTH_CORS}
      - MEDUSA_WORKER_MODE=${MEDUSA_WORKER_MODE:-shared}
      - PORT=9000
      - NODE_ENV=production
      - NODE_OPTIONS=--max-old-space-size=512
    ports:
      - "9000:9000"
    volumes:
      - medusa_uploads:/app/uploads
    networks:
      - medusa_network

  storefront:
    build:
      context: ./storefront
      dockerfile: Dockerfile
      args:
        - NEXT_PUBLIC_MEDUSA_BACKEND_URL=${NEXT_PUBLIC_MEDUSA_BACKEND_URL}
        - NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=${NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY}
        - NEXT_PUBLIC_DEFAULT_REGION=${NEXT_PUBLIC_DEFAULT_REGION:-us}
        - REVALIDATE_SECRET=${REVALIDATE_SECRET}
    restart: always
    depends_on:
      - medusa
    environment:
      - NEXT_PUBLIC_MEDUSA_BACKEND_URL=${NEXT_PUBLIC_MEDUSA_BACKEND_URL}
      - NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=${NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY}
      - NEXT_PUBLIC_DEFAULT_REGION=${NEXT_PUBLIC_DEFAULT_REGION:-us}
      - REVALIDATE_SECRET=${REVALIDATE_SECRET}
      - NODE_OPTIONS=--max-old-space-size=256
    ports:
      - "8000:8000"
    networks:
      - medusa_network

  nginx:
    image: nginx:alpine
    restart: always
    depends_on:
      - medusa
      - storefront
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - certbot_etc:/etc/letsencrypt:ro
      - certbot_var:/var/lib/letsencrypt
      - certbot_www:/var/www/certbot:ro
    networks:
      - medusa_network

  certbot:
    image: certbot/certbot
    volumes:
      - certbot_etc:/etc/letsencrypt
      - certbot_var:/var/lib/letsencrypt
      - certbot_www:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'"
    networks:
      - medusa_network

volumes:
  postgres_data:
  redis_data:
  medusa_uploads:
  certbot_etc:
  certbot_var:
  certbot_www:

networks:
  medusa_network:
    driver: bridge
DOCKEREOF

echo -e "${CYAN}[2/6]${NC} Creating Nginx config..."
cat > nginx/nginx.conf << 'NGINXEOF'
worker_processes 1;
worker_rlimit_nofile 2048;

events {
    worker_connections 1024;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 4;
    gzip_min_length 256;
    gzip_types text/plain text/css text/javascript application/json application/javascript application/xml image/svg+xml;

    limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=api:10m rate=5r/s;

    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=static_cache:10m max_size=500m inactive=60m;

    include /etc/nginx/conf.d/*.conf;
}
NGINXEOF

cat > nginx/conf.d/default.conf << 'SITEEOF'
upstream medusa_backend {
    server medusa:9000;
}

upstream storefront {
    server storefront:8000;
}

server {
    listen 80;
    server_name DOMAIN_PLACEHOLDER;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location /app {
        limit_req zone=general burst=20 nodelay;
        proxy_pass http://medusa_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /store {
        limit_req zone=api burst=10 nodelay;
        proxy_pass http://medusa_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /admin {
        limit_req zone=api burst=10 nodelay;
        proxy_pass http://medusa_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /auth {
        limit_req zone=api burst=10 nodelay;
        proxy_pass http://medusa_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /hooks {
        limit_req zone=api burst=10 nodelay;
        proxy_pass http://medusa_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /health {
        proxy_pass http://medusa_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }

    location /_next/static {
        proxy_pass http://storefront;
        proxy_cache static_cache;
        proxy_cache_valid 200 60m;
        add_header X-Cache-Status $upstream_cache_status;
        expires 30d;
    }

    location / {
        limit_req zone=general burst=20 nodelay;
        proxy_pass http://storefront;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
SITEEOF

echo -e "${CYAN}[3/6]${NC} Creating backend Dockerfile..."
cat > backend/Dockerfile << 'BACKEOF'
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json yarn.lock* package-lock.json* ./
RUN if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
    elif [ -f package-lock.json ]; then npm ci; \
    else npm install; fi

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npx medusa build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=9000
RUN addgroup --system --gid 1001 medusa && \
    adduser --system --uid 1001 medusa
COPY --from=builder --chown=medusa:medusa /app/.medusa ./.medusa
COPY --from=builder --chown=medusa:medusa /app/node_modules ./node_modules
COPY --from=builder --chown=medusa:medusa /app/package.json ./package.json
COPY --from=builder --chown=medusa:medusa /app/medusa-config.* ./
COPY --from=builder --chown=medusa:medusa /app/src ./src
RUN mkdir -p /app/uploads && chown medusa:medusa /app/uploads
USER medusa
EXPOSE 9000
CMD ["sh", "-c", "npx medusa db:migrate && npx medusa start"]
BACKEOF

cat > backend/.dockerignore << 'DIEOF'
node_modules
.medusa
.git
.env
.env.*
npm-debug.log
.DS_Store
DIEOF

echo -e "${CYAN}[4/6]${NC} Creating storefront Dockerfile..."
cat > storefront/Dockerfile << 'FRONTEOF'
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json yarn.lock* package-lock.json* ./
RUN if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
    elif [ -f package-lock.json ]; then npm ci; \
    else npm install; fi

FROM node:20-alpine AS builder
WORKDIR /app
ARG NEXT_PUBLIC_MEDUSA_BACKEND_URL
ARG NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY
ARG NEXT_PUBLIC_DEFAULT_REGION=us
ARG REVALIDATE_SECRET
ENV NEXT_PUBLIC_MEDUSA_BACKEND_URL=${NEXT_PUBLIC_MEDUSA_BACKEND_URL}
ENV NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=${NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY}
ENV NEXT_PUBLIC_DEFAULT_REGION=${NEXT_PUBLIC_DEFAULT_REGION}
ENV REVALIDATE_SECRET=${REVALIDATE_SECRET}
ENV NEXT_TELEMETRY_DISABLED=1
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=8000
ENV HOSTNAME="0.0.0.0"
RUN addgroup --system --gid 1001 nextjs && \
    adduser --system --uid 1001 nextjs
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nextjs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nextjs /app/.next/static ./.next/static
USER nextjs
EXPOSE 8000
CMD ["node", "server.js"]
FRONTEOF

cat > storefront/.dockerignore << 'DIEOF2'
node_modules
.next
.git
.env
.env.*
npm-debug.log
.DS_Store
DIEOF2

echo -e "${CYAN}[5/6]${NC} Creating deploy script..."
cat > deploy.sh << 'DEPLOYEOF'
#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_step() { echo -e "${CYAN}[STEP]${NC} $1"; }
print_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_err() { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
echo "=========================================="
echo "  Medusa E-Commerce Deploy"
echo "=========================================="
echo ""

if [ "$EUID" -ne 0 ]; then
    print_err "Run as root: sudo ./deploy.sh"
    exit 1
fi

if [ -z "$1" ]; then
    read -p "Enter your domain (e.g. mystore.com): " DOMAIN
else
    DOMAIN=$1
fi

read -p "Admin email [admin@${DOMAIN}]: " ADMIN_EMAIL
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@${DOMAIN}}

read -sp "Admin password: " ADMIN_PASSWORD
echo ""
ADMIN_PASSWORD=${ADMIN_PASSWORD:-supersecret123}

# Install Docker
print_step "1/7 - Installing Docker..."
if command -v docker &> /dev/null; then
    print_ok "Docker exists"
else
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker && systemctl start docker
    print_ok "Docker installed"
fi
if ! docker compose version &> /dev/null; then
    apt-get update && apt-get install -y docker-compose-plugin
fi

# Swap
print_step "2/7 - Setting up swap..."
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile && chmod 600 /swapfile
    mkswap /swapfile && swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    sysctl vm.swappiness=10
    print_ok "2GB swap created"
else
    print_ok "Swap exists"
fi

# Secrets
print_step "3/7 - Generating secrets..."
JWT_SECRET=$(openssl rand -hex 32)
COOKIE_SECRET=$(openssl rand -hex 32)
POSTGRES_PASSWORD=$(openssl rand -hex 16)
REVALIDATE_SECRET=$(openssl rand -hex 16)

# .env
print_step "4/7 - Creating .env..."
cat > .env << ENVVEOF
DOMAIN=${DOMAIN}
ADMIN_EMAIL=${ADMIN_EMAIL}
POSTGRES_USER=medusa
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=medusa_db
DATABASE_URL=postgres://medusa:${POSTGRES_PASSWORD}@postgres:5432/medusa_db
REDIS_URL=redis://redis:6379
JWT_SECRET=${JWT_SECRET}
COOKIE_SECRET=${COOKIE_SECRET}
STORE_CORS=http://${DOMAIN},https://${DOMAIN}
ADMIN_CORS=http://${DOMAIN},https://${DOMAIN}
AUTH_CORS=http://${DOMAIN},https://${DOMAIN}
MEDUSA_BACKEND_URL=http://${DOMAIN}
MEDUSA_WORKER_MODE=shared
PORT=9000
NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://${DOMAIN}
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=temp_key
NEXT_PUBLIC_DEFAULT_REGION=us
REVALIDATE_SECRET=${REVALIDATE_SECRET}
ACME_EMAIL=${ADMIN_EMAIL}
ENVVEOF
print_ok ".env created"

# Nginx domain
print_step "5/7 - Configuring domain..."
sed -i "s/DOMAIN_PLACEHOLDER/${DOMAIN}/g" nginx/conf.d/default.conf
print_ok "Nginx set to ${DOMAIN}"

# Clone source code
print_step "6/7 - Getting Medusa source code..."

if [ ! -f backend/package.json ]; then
    print_step "Scaffolding backend with create-medusa-app..."
    # Install Node.js if not present
    if ! command -v node &> /dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
        print_ok "Node.js $(node --version) installed"
    fi

    cd /root/medusa
    npx --yes create-medusa-app@latest temp-backend --skip-db --no-browser -y 2>/dev/null || true

    if [ -d "temp-backend" ]; then
        cp -r temp-backend/* backend/ 2>/dev/null || true
        cp -r temp-backend/.[!.]* backend/ 2>/dev/null || true
        rm -rf temp-backend
    fi
    print_ok "Backend ready"
fi

if [ ! -f storefront/package.json ]; then
    print_step "Cloning storefront..."
    git clone --depth 1 https://github.com/medusajs/nextjs-starter-medusa.git temp-store
    cp -r temp-store/* storefront/ 2>/dev/null || true
    cp -r temp-store/.[!.]* storefront/ 2>/dev/null || true
    rm -rf temp-store

    # Enable standalone output for Docker
    if [ -f storefront/next.config.js ]; then
        grep -q "output:" storefront/next.config.js || \
            sed -i '/const nextConfig/,/{/ s/{/{\n  output: "standalone",/' storefront/next.config.js
    elif [ -f storefront/next.config.mjs ]; then
        grep -q "output:" storefront/next.config.mjs || \
            sed -i '/const nextConfig/,/{/ s/{/{\n  output: "standalone",/' storefront/next.config.mjs
    elif [ -f storefront/next.config.ts ]; then
        grep -q "output:" storefront/next.config.ts || \
            sed -i '/const nextConfig/,/{/ s/{/{\n  output: "standalone",/' storefront/next.config.ts
    fi
    print_ok "Storefront ready"
fi

# Build and start
print_step "7/7 - Building & starting (3-8 min on 1 core)..."
docker compose down 2>/dev/null || true
docker compose up -d --build

print_step "Waiting for backend..."
MAX=180; W=0
until curl -sf http://localhost:9000/health > /dev/null 2>&1; do
    sleep 5; W=$((W+5))
    [ $W -ge $MAX ] && { print_warn "Timeout. Check: docker compose logs medusa"; break; }
    echo -n "."
done
echo ""

# Create admin
docker compose exec -T medusa npx medusa user -e "${ADMIN_EMAIL}" -p "${ADMIN_PASSWORD}" 2>/dev/null || true

echo ""
echo "=========================================="
echo -e "${GREEN}  DEPLOYED!${NC}"
echo "=========================================="
echo ""
echo "  Store:  http://${DOMAIN}"
echo "  Admin:  http://${DOMAIN}/app"
echo "  Login:  ${ADMIN_EMAIL}"
echo ""
echo "  NEXT STEPS:"
echo "  1. Login to admin → Settings → Regions → Create region"
echo "  2. Settings → API Keys → Create publishable key"
echo "  3. Update .env: NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_xxx"
echo "  4. Rebuild: docker compose up -d --build storefront"
echo ""
echo "  For SSL: Run after DNS is pointed to this server:"
echo "  docker compose run --rm certbot certonly --webroot --webroot-path=/var/www/certbot --email ${ADMIN_EMAIL} --agree-tos -d ${DOMAIN}"
echo "  Then restart: docker compose restart nginx"
echo ""
DEPLOYEOF

chmod +x deploy.sh

echo -e "${CYAN}[6/6]${NC} Making scripts executable..."
chmod +x deploy.sh

echo ""
echo -e "${GREEN}=========================================="
echo "  All files created!"
echo "  Now run: sudo ./deploy.sh yourdomain.com"
echo "==========================================${NC}"
