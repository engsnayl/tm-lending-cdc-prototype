#!/bin/bash
# Watch both CDC Kafka topics for change events in real time
# Displays Transaction and Agreement events as they arrive
# Press Ctrl+C to stop

echo "============================================"
echo "  Watching CDC Kafka Topics"
echo "  Press Ctrl+C to stop"
echo "============================================"
echo ""
echo "Listening on:"
echo "  - sentinel.SentinelMock.dbo.Transaction"
echo "  - sentinel.SentinelMock.dbo.Agreement"
echo ""

docker compose exec kafka kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --whitelist "sentinel\.SentinelMock\.dbo\.(Transaction|Agreement)" \
    --from-beginning \
    --property print.key=true \
    --property key.separator="  |  "
