# Multi-stage build for Node.js application

# Stage 1: Build
FROM node:18-alpine AS builder

WORKDIR /app

COPY app/package*.json ./

RUN npm ci --omit=dev

# Stage 2: Runtime
FROM node:18-alpine

# Set metadata
LABEL maintainer="DevOps Team"
LABEL description="Enterprise-grade DevOps Demo Application"

WORKDIR /app

# Copy only necessary files from builder
COPY --from=builder /app/node_modules ./node_modules
COPY app/server-enhanced.js ./server.js
COPY app/.env.example ./.env.example

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Expose port
EXPOSE 3000

# Set environment
ENV NODE_ENV=production
ENV PORT=3000

# Non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

USER nodejs

# Start application
CMD ["node", "server.js"]
