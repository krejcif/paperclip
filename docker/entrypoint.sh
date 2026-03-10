#!/bin/bash
set -e

# Start SSH daemon
/usr/sbin/sshd -p 2222

CONFIG_PATH="${PAPERCLIP_CONFIG:-/paperclip/instances/default/config.json}"

if [ ! -f "$CONFIG_PATH" ]; then
    echo "[entrypoint] First run - running onboard (creates config + bootstrap CEO + starts server)"
    cd /app
    exec pnpm paperclipai onboard --yes
else
    echo "[entrypoint] Config exists - starting server"
    cd /app
    exec node --import ./server/node_modules/tsx/dist/loader.mjs server/dist/index.js
fi
