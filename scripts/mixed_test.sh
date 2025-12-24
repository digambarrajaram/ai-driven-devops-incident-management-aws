#!/bin/bash
set -e

TARGET_URL=${TARGET_URL:?TARGET_URL is required}
REQUESTS=${REQUESTS:-200}

for i in $(seq 1 $REQUESTS); do
  curl -s "${TARGET_URL}/error" > /dev/null &
  curl -s "${TARGET_URL}/" > /dev/null &
done
wait
