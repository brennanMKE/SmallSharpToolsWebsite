#!/bin/bash
# Serve site/ locally and open it: http://localhost:${PORT:-8000}
set -euo pipefail
cd "$(dirname "$0")/../site"
PORT="${PORT:-8000}"
( sleep 1; open "http://localhost:$PORT/" ) &
exec python3 -m http.server "$PORT" --bind 127.0.0.1
