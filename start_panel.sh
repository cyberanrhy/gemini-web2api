#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="/tmp/panel.log"

echo "=== Gemini Proxy Control Panel ==="
echo ""

cd "$SCRIPT_DIR"

# Kill old panel
fuser -k 8083/tcp 2>/dev/null || true
sleep 0.3

# Start panel
echo "Starting panel on http://127.0.0.1:8083 ..."
python3 panel.py --port 8083 > "$LOG_FILE" 2>&1 &

# Wait for panel to be ready
for i in $(seq 1 10); do
    if curl -s -o /dev/null -w "" http://127.0.0.1:8083/ 2>/dev/null; then
        break
    fi
    sleep 1
done

echo "Panel is running."
echo "  Open: http://127.0.0.1:8083"
echo "  Logs: $LOG_FILE"

# Open browser
xdg-open "http://127.0.0.1:8083" 2>/dev/null || true

# Keep terminal open
read -p "Close this window to stop the panel..."
