#\!/bin/bash
set -e
/usr/sbin/sshd -p 2222
exec node --import ./server/node_modules/tsx/dist/loader.mjs server/dist/index.js

