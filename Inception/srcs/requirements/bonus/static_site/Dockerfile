# Step 1: Base Image
FROM debian:bookworm

# Step 2: Install Nginx instead of PHP
RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx && \
    rm -rf /var/lib/apt/lists/*

# Step 3: Copy a basic custom Nginx config file
COPY conf/nginx.conf /etc/nginx/sites-available/default

# Step 4: Copy your static HTML/CSS files
COPY tools/ /var/www/static/

# Step 5: Expose the internal static-site port
EXPOSE 8000

# Step 6: Start Nginx in the foreground (PID 1)
CMD ["nginx", "-g", "daemon off;"]
