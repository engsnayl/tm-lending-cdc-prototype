#!/bin/bash
# One-command setup: start stack, wait for services, enable CDC, register connectors
# Usage: bash scripts/setup.sh

set -e
source .env 2>/dev/null || true

echo "============================================"
echo "  TM Lending CDC Prototype - Setup"
echo "============================================"
echo ""

echo "[1/6] Starting Docker Compose stack..."
docker compose up -d
echo ""

echo "[2/6] Waiting for SQL Server to be ready..."
until docker compose exec -T sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -Q "SELECT 1" -C -b &>/dev/null; do
    printf "."
    sleep 2
done
echo ""
echo "SQL Server is ready."
echo ""

echo "[3/6] Creating database and tables..."
docker compose exec -T sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -i /sql/01-create-tables.sql -C
echo ""

echo "[4/6] Seeding test data..."
docker compose exec -T sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -d SentinelMock -i /sql/02-seed-data.sql -C
echo ""

echo "[5/6] Enabling CDC on Agreement and Transaction tables..."
docker compose exec -T sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -d SentinelMock -i /sql/03-enable-cdc.sql -C
echo ""

echo "[6/6] Waiting for Kafka Connect to be ready..."
until curl -s http://localhost:8083/ &>/dev/null; do
    printf "."
    sleep 2
done
echo ""
echo "Kafka Connect is ready."
echo ""

echo "Registering Debezium CDC connector..."
bash connectors/register-connector.sh
echo ""

echo "============================================"
echo "  Setup complete!"
echo "============================================"
echo ""
echo "  Kafka UI:           http://localhost:8080"
echo "  Kafka Connect API:  http://localhost:8083"
echo "  SQL Server:         localhost:1433"
echo ""
echo "  Run test events:    bash test-events/run-all-events.sh"
echo "    (or run from inside the container):"
echo "    docker compose exec sqlserver bash /test-events/run-all-events.sh"
echo ""
echo "  Watch topics:       bash scripts/watch-topics.sh"
echo "  List topics:        bash scripts/list-topics.sh"
echo "  Teardown:           bash scripts/teardown.sh"
echo ""
