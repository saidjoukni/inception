# 1. Base Image
FROM debian:bookworm

# 2. Install NGINX and OpenSSL
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# 3. Create a directory to store the SSL/TLS certificates
RUN mkdir -p /etc/nginx/ssl

# 4. Generate the SSL certificate using OpenSSL
RUN openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=MA/ST=Marrakech/L=Marrakech/O=1337/OU=student/CN=sjoukni.42.fr"

# 5. Create a folder for NGINX process to run properly
RUN mkdir -p /var/run/nginx

# 6. Copy the configuration file
COPY conf/nginx.conf /etc/nginx/nginx.conf

# 7. Start NGINX in the foreground (pid 1 )
CMD ["nginx", "-g", "daemon off;"]
