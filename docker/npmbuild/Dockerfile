# Stage 1: Build
FROM node:20.0.0 AS builder

# Copy package files first for better caching
COPY ./package.json ./package-lock.json* ./

# Install dependencies (including devDependencies for build)
RUN npm install --frozen-lockfile --force

# Copy all files
COPY ./.env .
COPY ./. .

# Build the project
RUN npm run build
