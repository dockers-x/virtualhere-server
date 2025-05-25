# VirtualHere USB Server Docker Image for AMD64/x86_64
FROM ubuntu:24.04

# Set working directory
WORKDIR /app

# Expose VirtualHere default port
EXPOSE 7575

# Set data volume
VOLUME ["/data"]

# Install required packages
RUN apt-get update && \
    apt-get install -y wget usbutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download x86_64 version of VirtualHere during build
RUN echo "Downloading VirtualHere x86_64 version..." && \
    wget -O /app/virtualhere https://www.virtualhere.com/sites/default/files/usbserver/vhusbdx86_64 && \
    chmod +x /app/virtualhere && \
    ls -la /app/virtualhere

# Copy startup script and set permissions
COPY start-virtualhere.sh /app/start-virtualhere.sh
RUN chmod +x /app/start-virtualhere.sh

# Run startup script
CMD ["/app/start-virtualhere.sh"]
