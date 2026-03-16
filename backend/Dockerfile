# ============================================
# Medusa v2 Backend - Single Stage (reliable)
# ============================================
FROM node:20-alpine

RUN apk add --no-cache python3 make g++ curl

WORKDIR /app

COPY package.json ./
RUN npm install

COPY . .

ENV NODE_ENV=production
ENV PORT=9000

EXPOSE 9000

CMD ["sh", "-c", "npx medusa db:migrate && npx medusa start"]
