# Step 1: Choosing the Base Image
FROM debian:bookworm

# Step 2: Update apt and install mariadb-server
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Step 3: Copy the config file
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Step 4: Copy the setup.sh script file
COPY tools/setup.sh /

# Step 5: chmod setup.sh to 755
RUN chmod 755 /setup.sh

# Step 6: Run the script in the foreground
CMD ["bash", "/setup.sh"]
