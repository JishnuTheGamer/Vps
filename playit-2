#!/usr/bin/env bash
set -euo pipefail

BIN="./playit-linux-amd64"
NAME="playit"   # pm2 process name
URL="https://github.com/playit-cloud/playit-agent/releases/download/v0.16.3/playit-linux-amd64"

have_pm2() { command -v pm2 >/dev/null 2>&1; }

ensure_pm2() {
  if ! have_pm2; then
    echo "PM2 not found, installing globally with npm i -g pm2..."
    npm i -g pm2
  fi
}

start_with_pm2() {
  ensure_pm2

  # If a PM2 process with this name exists, stop it first
  if pm2 describe "$NAME" >/dev/null 2>&1; then
    echo "PM2 process '$NAME' already exists, stopping it first..."
    pm2 stop "$NAME" || true
  fi

  echo "Starting Playit under PM2 as '$NAME'..."
  pm2 start "$BIN" --name "$NAME"
  pm2 save
  echo "Playit is now running under PM2 as '$NAME'."
}

# 1) If the binary already exists, just start with PM2 (no waiting)
if [[ -f "$BIN" ]]; then
  echo "Binary exists; starting under PM2..."
  start_with_pm2
  exit 0
fi

# 2) First-time setup: download and make executable
echo "Downloading playit agent..."
wget -q "$URL" -O "$BIN"
chmod +x "$BIN"

echo "Starting Playit once and waiting for tunnel to be running..."
LOGFILE="$(mktemp)"
echo "Logging Playit output to: $LOGFILE"

# Show Playit output (so you can see link & status) AND log it
"$BIN" 2>&1 | tee "$LOGFILE" &
PID=$!

connected=0

# 3) Wait up to 300 seconds for 'tunnel running' to appear in logs
#    Example line:
#    playit (v0.16.3): 1763281545790 tunnel running, 0 tunnels registered
for i in {1..300}; do
  sleep 1
  if grep -q "tunnel running" "$LOGFILE"; then
    connected=1
    break
  fi
done

# 4) Stop the temporary Playit process
if ps -p "$PID" >/dev/null 2>&1; then
  kill "$PID" || true
  sleep 1
fi

if [[ $connected -eq 1 ]]; then
  echo "Detected 'tunnel running' in Playit logs. Switching to PM2..."
else
  echo "Did not see 'tunnel running' within timeout; switching to PM2 anyway."
fi

# 5) Start Playit under PM2 (with install + stop-if-running + start)
start_with_pm2
