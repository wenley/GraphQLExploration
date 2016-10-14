#!/bin/bash

QUERY='{ hello }'

ruby app/server.rb &
sleep 1

curl -X POST -d "$QUERY" \
  http://localhost:4567/
echo
sleep 1

kill $(jobs -p)
sleep 1

echo "Done!"
