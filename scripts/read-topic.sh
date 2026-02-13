#!/bin/bash
# Read messages from a specific Kafka topic
# Usage: bash scripts/read-topic.sh <topic-name>
#
# Examples:
#   bash scripts/read-topic.sh sentinel.SentinelMock.dbo.Transaction
#   bash scripts/read-topic.sh sentinel.SentinelMock.dbo.Agreement

if [ -z "$1" ]; then
    echo "Usage: bash scripts/read-topic.sh <topic-name>"
    echo ""
    echo "Available CDC topics:"
    echo "  sentinel.SentinelMock.dbo.Transaction"
    echo "  sentinel.SentinelMock.dbo.Agreement"
    echo ""
    echo "List all topics: bash scripts/list-topics.sh"
    exit 1
fi

TOPIC=$1

echo "Reading topic: $TOPIC"
echo "Press Ctrl+C to stop"
echo "=========================="

docker compose exec kafka kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --topic "$TOPIC" \
    --from-beginning \
    --property print.key=true \
    --property key.separator="  |  "
