#!/bin/bash
# Register a single Debezium SQL Server connector for both tables
# Publishes change events to:
#   - sentinel.SentinelMock.dbo.Transaction
#   - sentinel.SentinelMock.dbo.Agreement
#
# A single connector avoids JMX MBean name conflicts that occur when
# two connectors share the same topic.prefix on the same Connect worker.

source .env 2>/dev/null || true
PASSWORD="${MSSQL_SA_PASSWORD:-Str0ngP@ssw0rd!}"

echo "Registering Debezium CDC connector (Agreement + Transaction)..."

curl -s -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d "{
  \"name\": \"sentinel-cdc-connector\",
  \"config\": {
    \"connector.class\": \"io.debezium.connector.sqlserver.SqlServerConnector\",
    \"database.hostname\": \"sqlserver\",
    \"database.port\": \"1433\",
    \"database.user\": \"sa\",
    \"database.password\": \"${PASSWORD}\",
    \"database.names\": \"SentinelMock\",
    \"topic.prefix\": \"sentinel\",
    \"table.include.list\": \"dbo.Transaction,dbo.Agreement\",
    \"database.encrypt\": \"false\",
    \"schema.history.internal.kafka.bootstrap.servers\": \"kafka:9092\",
    \"schema.history.internal.kafka.topic\": \"schema-changes.sentinel\"
  }
}"

echo ""
echo "CDC connector registered. Topics:"
echo "  - sentinel.SentinelMock.dbo.Transaction"
echo "  - sentinel.SentinelMock.dbo.Agreement"
