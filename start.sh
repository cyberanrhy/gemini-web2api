#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

if [ ! -f config.json ]; then
  cp config.json.example config.json
  echo "Created config.json from config.json.example — review it before running."
fi

if [ ! -f cookie.txt ]; then
  echo "ERROR: cookie.txt not found."
  echo "1. Log in to https://gemini.google.com/app in Firefox"
  echo "2. Install 'cookies.txt' extension and export cookies"
  echo "3. Save the file as: $DIR/cookie.txt"
  echo "Then run: bash start.sh"
  exit 1
fi

echo "Starting Gemini proxy on http://0.0.0.0:8081 ..."
fuser -k 8081/tcp 2>/dev/null
sleep 0.3
exec python3 gemini_web2api.py
