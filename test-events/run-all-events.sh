#!/bin/bash
# Run all test events in sequence with pauses between them
# Execute from the repo root: bash test-events/run-all-events.sh

set -e
source .env 2>/dev/null || true

SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
CONN="-S sqlserver -U sa -P ${MSSQL_SA_PASSWORD:-Str0ngP@ssw0rd!} -d SentinelMock -C"

echo "=== Running all test events ==="
echo "Watch Kafka topics in another terminal: bash scripts/watch-topics.sh"
echo ""

for script in /test-events/0*.sql; do
    echo "==========================================="
    echo "--- Executing: $(basename $script) ---"
    echo "==========================================="
    $SQLCMD $CONN -i "$script"
    echo ""
    echo "Waiting 5 seconds for Debezium to capture changes..."
    sleep 5
    echo ""
done

echo "=== All events complete. Check Kafka topics. ==="
echo "Kafka UI: http://localhost:8080"
