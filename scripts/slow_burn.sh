#!/bin/bash
set -e

TARGET_URL=${TARGET_URL:?TARGET_URL is required}

for i in {1..30}; do
  for j in {1..20}; do
    curl -s "${TARGET_URL}/" > /dev/null &
  done
  sleep 30
done
