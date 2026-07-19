# Stage 1: Build
FROM node:24-alpine AS builder

WORKDIR /app

# Copy package files first for better caching
COPY ./package.json ./package-lock.json* ./

# Install dependencies, preferring the lockfile when it exists.
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Copy all files
COPY ./. .

# Build the project
RUN npm run build

# Stage 2: Production with PM2
FROM node:24-alpine

# Install PM2 globally
RUN npm install -g pm2

WORKDIR /app


RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 -G nodejs

COPY --from=builder --chown=nextjs:nodejs /app/package.json /app/package-lock.json ./
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules

USER nextjs

# Expose port
EXPOSE 3000

# Health check with PM2
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget -qO- http://localhost:3000/ >/dev/null || exit 1

# Start with PM2 (single process)
CMD ["pm2-runtime", "start", "npm", "--", "start"]
