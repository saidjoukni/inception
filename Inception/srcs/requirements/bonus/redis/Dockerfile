# Step 1: Base Image
FROM debian:bookworm
# Use the allowed Debian base image.

# Step 2: Install Redis
RUN apt-get update && \
    apt-get install -y --no-install-recommends redis-server && \
    rm -rf /var/lib/apt/lists/*
# Install the Redis server package cleanly and remove the cache to reduce image size.

# Step 3: Start Redis with flags
CMD ["redis-server", "--bind", "0.0.0.0", "--protected-mode", "no"]
# Start the server directly. 
# '--bind 0.0.0.0' allows connections from the Docker network.
# '--protected-mode no' allows access without a password (safe here since it's isolated in our internal network).