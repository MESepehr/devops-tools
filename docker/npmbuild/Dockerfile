# Stage 1: Build
FROM node:22-slim AS builder
WORKDIR /app


# Copy package files first for better caching
COPY ./package.json ./package-lock.json* ./

# Install dependencies (including devDependencies for build)
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm install --frozen-lockfile --force

# Copy all files
COPY ./.env .
COPY ./. .

# Build the project
RUN npm run build
RUN rm node_modules -r