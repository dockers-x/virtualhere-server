#!/bin/bash
#
# VirtualHere startup script for single architecture binary

set -e

echo "*** Starting VirtualHere USB Server..."

# List USB devices for debugging
echo "*** Current USB devices:"
if ! lsusb; then
    echo "Warning: Unable to list USB devices. Ensure container has proper USB access permissions"
fi

# Prepare data directory
mkdir -p /data
cd /data

# Clean up old temporary files
echo "*** Cleaning up temporary files..."
find . -name '*bus_usb_*' -delete 2>/dev/null || true

# Check if VirtualHere binary exists
if [ ! -f "/app/virtualhere" ]; then
    echo "Error: VirtualHere binary not found at /app/virtualhere"
    exit 1
fi

# Display binary information
echo "*** VirtualHere binary information:"
/app/virtualhere -h 2>&1 | head -3 || echo "Unable to get version information"

# Start VirtualHere server
echo "*** Starting VirtualHere server..."
echo "Working directory: $(pwd)"
echo "Listening on port: 7575"
echo "Architecture: $(uname -m)"

# Use exec to make VirtualHere the main process (PID 1)
exec /app/virtualhere
