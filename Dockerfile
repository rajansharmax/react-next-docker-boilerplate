# Stage 1: Node.js for building React/Next.js app
FROM node:lts-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git

# Copy package files and install dependencies
COPY package*.json yarn.lock ./

RUN yarn install --frozen-lockfile

# Copy all project files
COPY . .

# Build the application
RUN yarn build

# Stage 2: Production-ready Node.js server for Next.js
FROM node:lts-alpine AS runner

WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache tini

# Copy necessary files from the builder stage
COPY --from=builder /app/.next /app/.next
COPY --from=builder /app/public /app/public
COPY --from=builder /app/package*.json /app/

# Install production dependencies
RUN yarn install --frozen-lockfile --production

# Set environment variables
ENV NODE_ENV production
ENV PORT 3000

# Expose the application port
EXPOSE 3000

# Use Tini to handle processes more efficiently
ENTRYPOINT ["/sbin/tini", "--"]

# Start the application
CMD ["yarn", "start"]
