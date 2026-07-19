# Stage 1: Build
FROM node:22.0.0-alpine AS builder

WORKDIR /app

# Copy package files first for better caching
COPY ./package.json ./package-lock.json* ./

# Install packages
RUN npm install --force

# Copy all files
COPY ./. .

# Build the project
RUN npm run build

# Stage 2: Production with Nginx
FROM nginx:alpine

# Copy built files from builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Copy custom nginx configuration if needed
# COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]