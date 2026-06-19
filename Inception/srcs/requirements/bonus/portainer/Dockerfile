FROM debian:bookworm

ARG PORTAINER_VERSION=2.39.3

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates tar wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/portainer /data && \
    wget -O /tmp/portainer.tar.gz "https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-linux-amd64.tar.gz" && \
    tar -xzf /tmp/portainer.tar.gz -C /opt/portainer --strip-components=1 && \
    rm -f /tmp/portainer.tar.gz && \
    chmod +x /opt/portainer/portainer

WORKDIR /opt/portainer

EXPOSE 9000

CMD ["/opt/portainer/portainer", "--http-enabled", "--bind", ":9000", "-H", "unix:///var/run/docker.sock"]
