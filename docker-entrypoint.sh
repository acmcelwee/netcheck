#!/bin/bash
set -e

# If the log directory is mounted and lacks the web interface files, copy them over.
if [ ! -f "/app/log/index.html" ]; then
    echo "Initializing web interface assets in /app/log..."
    # Copy assets but do not overwrite any existing connection.log if it exists
    cp -rp /app/web_assets/* /app/log/
fi

# Execute the main application
exec "/app/netcheck.sh" "$@"
