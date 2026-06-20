#!/bin/bash
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "=== Gemini Web2API Proxy ==="
echo ""

if [ ! -f cookie.txt ]; then
  echo "ERROR: cookie.txt not found."
  echo "1. Log in to https://gemini.google.com/app in Firefox"
  echo "2. Install 'cookies.txt' extension and export cookies"
  echo "3. Save the file as: $DIR/cookie.txt"
  read -p "Press Enter to exit..."
  exit 1
fi

fuser -k 8081/tcp 2>/dev/null
sleep 0.3

echo "Starting Gemini proxy on http://0.0.0.0:8081 ..."
echo "Close this window to stop the server."
echo ""
exec python3 gemini_web2api.py --config config.json --cookie-file cookie.txt
