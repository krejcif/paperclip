#\!/bin/bash
set -e

# Start SSH daemon
/usr/sbin/sshd -p 2222

# Start paperclip server in background
node --import ./server/node_modules/tsx/dist/loader.mjs server/dist/index.js &
SERVER_PID=$\!

# Wait for config file to be created by the server (up to 30s)
CONFIG_PATH="${PAPERCLIP_CONFIG:-/paperclip/instances/default/config.json}"
echo "[entrypoint] Waiting for config at $CONFIG_PATH..."
for i in $(seq 1 30); do
  if [ -f "$CONFIG_PATH" ]; then
    echo "[entrypoint] Config found after ${i}s"
    break
  fi
  sleep 1
done

# Run bootstrap if no admin exists yet
if [ -f "$CONFIG_PATH" ]; then
  echo "[entrypoint] Running bootstrap-ceo..."
  cd /app && pnpm paperclipai auth bootstrap-ceo --base-url "${PAPERCLIP_PUBLIC_URL:-http://localhost:3100}" 2>&1 || true
else
  echo "[entrypoint] WARNING: Config not found, skipping bootstrap"
fi

# Keep server running in foreground
wait $SERVER_PID

