# ============================================
# Medusa v2 Backend - Production Dockerfile
# Optimized for 1-core VPS (multi-stage build)
# ============================================

# Stage 1: Install dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json yarn.lock* package-lock.json* ./
RUN if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
    elif [ -f package-lock.json ]; then npm ci; \
    else npm install; fi

# Stage 2: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npx medusa build

# Stage 3: Production
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=9000

RUN addgroup --system --gid 1001 medusa && \
    adduser --system --uid 1001 medusa

# Copy built application
COPY --from=builder --chown=medusa:medusa /app/.medusa ./.medusa
COPY --from=builder --chown=medusa:medusa /app/node_modules ./node_modules
COPY --from=builder --chown=medusa:medusa /app/package.json ./package.json
COPY --from=builder --chown=medusa:medusa /app/medusa-config.* ./
COPY --from=builder --chown=medusa:medusa /app/src ./src

# Create uploads directory
RUN mkdir -p /app/uploads && chown medusa:medusa /app/uploads

USER medusa

EXPOSE 9000

# Run migrations, seed, then start
CMD ["sh", "-c", "npx medusa db:migrate && npx medusa start"]
