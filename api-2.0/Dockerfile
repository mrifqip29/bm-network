# Base stage - Using Node 12 for compatibility with mixed Fabric SDK versions
FROM node:12-alpine

# Set working directory
WORKDIR /app

# Install build dependencies for native modules
RUN apk add python3 make g++

# Copy package files
COPY package*.json ./
COPY yarn.lock ./

# Install dependencies using yarn with ignore-engines flag
# (project has mixed fabric-client@1.4.17 and fabric-network@2.2.x)
RUN yarn install --production --ignore-engines --network-timeout 100000

# Copy application code
COPY . .

# Create necessary directories for wallets if they don't exist
RUN mkdir -p penangkar-wallet petani-wallet pengumpul-wallet pedagang-wallet

# Expose port
EXPOSE 4000

# Start the application
CMD ["node", "app.js"]

