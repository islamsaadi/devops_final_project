# Use the official Node.js runtime as the base image
# Using Node.js 18 LTS for stability and security
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Copy package.json and package-lock.json (if available) first
# This allows Docker to cache the npm install step if dependencies haven't changed
COPY package*.json ./

# Install dependencies
# Using npm ci for faster, reliable, reproducible builds
RUN npm ci && \
    npm cache clean --force

# Copy the rest of the application code
COPY . .

# Change ownership of the app directory to the nodejs user
RUN chown -R nextjs:nodejs /app

# Switch to non-root user
USER nextjs

# Create a directory for logs (if the app writes logs to files)
RUN mkdir -p /app/logs

# Expose the port the app runs on
# Default is 8080, but can be overridden via SERVER_PORT env var
EXPOSE 8080

# Start the application
CMD ["node", "server.js"]
