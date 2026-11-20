#!/usr/bin/env bash
# Validate one batch of the proxy list.
set -uo pipefail

BATCH="${BATCH:?batch is required}"
BIN=".ci/cache/checker/check-${BATCH}"

# Restart cleanly if a stale worker is around.
pkill -f "checker/check-${BATCH}" 2>/dev/null || true
sleep 1

"$BIN" > check.log 2>&1 &
PID=$!
sleep 5
if ! kill -0 "$PID" 2>/dev/null; then
  echo "checker failed to start"
  tail -5 check.log 2>/dev/null || true
  exit 1
fi
echo "checker ready"

# Keep the batch running; refresh list counters every 30 minutes.
for i in $(seq 1 330); do
  sleep 60
  if [ $((i % 30)) -eq 0 ]; then
    bash .ci/update-stats.sh || true
  fi
  kill -0 "$PID" 2>/dev/null || break
done
echo "checker exited"
exit 1
