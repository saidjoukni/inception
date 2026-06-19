# Step 1: Base Image
FROM debian:bookworm

# Step 2: Install vsftpd (FTP server)
RUN apt-get update && \
    apt-get install -y --no-install-recommends vsftpd && \
    rm -rf /var/lib/apt/lists/*

# Step 3: Copy the initialization script
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

# Step 4: Start the server
CMD ["/setup.sh"]