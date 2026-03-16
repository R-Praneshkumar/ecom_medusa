# ============================================
# Next.js Storefront - Production Dockerfile
# Clones source inside Docker - no Node.js needed on host
# ============================================

# Stage 1: Clone and install
FROM node:20-alpine AS deps
RUN apk add --no-cache git
WORKDIR /app
RUN git clone --depth 1 https://github.com/medusajs/nextjs-starter-medusa.git .
RUN npm install

# Stage 2: Build
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

COPY --from=deps /app ./

# Add standalone output to next config
RUN if [ -f next.config.mjs ]; then \
      sed -i '/const nextConfig/,/{/ s/{/{\n  output: "standalone",/' next.config.mjs; \
    elif [ -f next.config.js ]; then \
      sed -i '/const nextConfig/,/{/ s/{/{\n  output: "standalone",/' next.config.js; \
    elif [ -f next.config.ts ]; then \
      sed -i '/const nextConfig/,/{/ s/{/{\n  output: "standalone",/' next.config.ts; \
    fi

RUN npm run build

# Stage 3: Production
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
