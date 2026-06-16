# Stage 1: Build
FROM node:20.0.0 AS builder

WORKDIR /app

# Copy package files first for better caching
COPY ./package.json ./package-lock.json* ./

# Install dependencies, preferring the lockfile when it exists.
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Copy all files
COPY ./.env .
COPY ./. .

# Build the project
RUN npm run build
