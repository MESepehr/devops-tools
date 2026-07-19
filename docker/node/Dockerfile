FROM node:24-alpine

# Install PM2 globally
# RUN npm install -g pm2

WORKDIR /app

# Copy package files first for better caching
COPY ./package.json ./package-lock.json* ./

# Install dependencies
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Copy all application files
COPY ./. .

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs && \
    chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port (change if your app uses a different port)
EXPOSE 3000

# Health check (optional)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/ || exit 1

# Start with PM2
CMD ["npm", "run", "serve"]