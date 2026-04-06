# Multi-stage build for tourism website
# Stage 1: Build (optional for static files, but good practice)
FROM node:18-alpine AS builder
WORKDIR /build
COPY website/ .

# Stage 2: Production - Serve with Nginx
FROM nginx:alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Copy website files
COPY --from=builder /build/ .

# Copy Nginx config for serving the static site
COPY nginx.website.conf /etc/nginx/nginx.conf

# Create health check endpoint
RUN echo '<!DOCTYPE html><html><body>OK</body></html>' > healthcheck.html

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=5s \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1/healthcheck.html || exit 1

# Run Nginx
CMD ["nginx", "-g", "daemon off;"]
