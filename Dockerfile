# Stage 1: Build/Install Speedtest CLI
FROM debian:stable-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies needed to add the repository and install speedtest
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Add Ookla repository and install speedtest
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash \
    && apt-get install -y --no-install-recommends speedtest

# Stage 2: Clean runtime image
FROM debian:stable-slim

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    iputils-ping \
    jq \
    python3 \
    ca-certificates \
    net-tools \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/python3 /usr/bin/python

# Copy the speedtest binary from the builder stage
COPY --from=builder /usr/bin/speedtest /usr/bin/speedtest

# Set up the application directory
WORKDIR /app

# Copy application files
COPY netcheck.sh internet_status_chart.sh docker-entrypoint.sh ./
COPY sample-scripts ./sample-scripts

# Copy web interface assets to log and also to web_assets for initialization on volume mount
COPY log ./log
COPY log ./web_assets

# Make scripts executable
RUN chmod +x netcheck.sh internet_status_chart.sh docker-entrypoint.sh

# Expose port 9000 for the web interface
EXPOSE 9000

# Use the entrypoint script to set up assets and launch netcheck.sh
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# Default parameters: enable the web interface
CMD ["-w"]
