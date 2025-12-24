#!/bin/bash
set -e

TARGET_URL=${TARGET_URL:?TARGET_URL is required}
USERS=${USERS:-100}

for i in $(seq 1 $USERS); do
  curl -s "${TARGET_URL}/" > /dev/null &
done
wait
