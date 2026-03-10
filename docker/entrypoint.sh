#!/bin/bash
set -e

# Start SSH daemon (requires root)
/usr/sbin/sshd -p 2222

# Ensure persistent volume is writable by node user
chown -R node:node /paperclip 2>/dev/null || true

CONFIG_PATH="${PAPERCLIP_CONFIG:-/paperclip/instances/default/config.json}"

if [ ! -f "$CONFIG_PATH" ]; then
    echo "[entrypoint] First run - running onboard (creates config + bootstrap CEO + starts server)"
    exec su -s /bin/bash node -c "cd /app && pnpm paperclipai onboard --yes"
else
    echo "[entrypoint] Config exists - starting server"
    exec su -s /bin/bash node -c "cd /app && node --import ./server/node_modules/tsx/dist/loader.mjs server/dist/index.js"
fi