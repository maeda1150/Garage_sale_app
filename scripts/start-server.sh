#!/usr/bin/env bash

cd /app

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

bundle exec rails server -p 3000 -b 0.0.0.0
