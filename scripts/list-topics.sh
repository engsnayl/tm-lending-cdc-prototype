#!/bin/bash
# List all Kafka topics in the cluster

echo "Kafka Topics:"
echo "============="

docker compose exec kafka kafka-topics \
    --bootstrap-server localhost:9092 \
    --list
