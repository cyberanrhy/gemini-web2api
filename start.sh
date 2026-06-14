#!/bin/bash
# Gemini Web -> OpenAI-compatible proxy
# Usage: ./start.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

fuser -k 8081/tcp 2>/dev/null
sleep 0.3
exec python3 gemini_web2api.py
