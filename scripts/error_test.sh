#!/bin/bash
set -e

TARGET_URL=${TARGET_URL:?TARGET_URL is required}
DURATION=${DURATION:-900}   # default 15 min

END=$((SECONDS + DURATION))
while [ $SECONDS -lt $END ]; do
  curl -s -o /dev/null "${TARGET_URL}/error" || true
done
