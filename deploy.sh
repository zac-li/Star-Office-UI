#!/bin/bash
# Star Office deploy script: restart Flask + restore all state
set -e
cd "$(dirname "$0")"

echo "🔄 Stopping Flask..."
pkill -f "backend/app.py" 2>/dev/null || true
sleep 1

echo "🚀 Starting Flask on port 18801..."
source .venv/bin/activate
STAR_BACKEND_PORT=18801 nohup python3 backend/app.py > /tmp/star-office.log 2>&1 &
sleep 2

echo "🔑 Restoring join keys..."
cp join-keys.sample.json join-keys.json 2>/dev/null || true

echo "🧪 Restoring Walter state..."
curl -s -X POST "http://127.0.0.1:18801/set_state" \
  -H "Content-Type: application/json" \
  -d '{"state":"orchestrating","detail":""}' > /dev/null

echo "👥 Re-registering agents + pushing state..."
SCRIPTS_DIR="/Users/zacli/Code/gray-matter-technologies/skills/admins/star-office-checkin/scripts"
/usr/bin/python3 "$SCRIPTS_DIR/activity-check.py"

echo "📊 Pushing token data..."
/usr/bin/python3 "$SCRIPTS_DIR/token-snapshot.py"

echo "✅ Deploy complete"
