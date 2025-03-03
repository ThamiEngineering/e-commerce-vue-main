FROM node:18-alpine AS deps

WORKDIR /app

COPY package*.json ./
RUN [ -f package-lock.json ] || npm install --package-lock-only
RUN npm ci

FROM node:18-alpine AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

FROM node:18-alpine AS runner

WORKDIR /app

RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001 -G nodejs

COPY --from=builder --chown=nodeuser:nodejs /app/package*.json ./
COPY --from=builder --chown=nodeuser:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodeuser:nodejs /app/src ./src

ENV PORT=3000
ENV NODE_ENV=production

USER nodeuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/api/health || exit 1

CMD ["node", "src/app.js"]