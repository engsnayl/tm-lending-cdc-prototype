#!/bin/bash
# Register Debezium SQL Server connector for the Transaction table
# Publishes change events to: sentinel.SentinelMock.dbo.Transaction

source .env 2>/dev/null || true

echo "Registering Transaction table connector..."

curl -s -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
  "name": "sentinel-transaction-connector",
  "config": {
    "connector.class": "io.debezium.connector.sqlserver.SqlServerConnector",
    "database.hostname": "sqlserver",
    "database.port": "1433",
    "database.user": "sa",
    "database.password": "'"${MSSQL_SA_PASSWORD:-Str0ngP@ssw0rd!}"'",
    "database.names": "SentinelMock",
    "topic.prefix": "sentinel",
    "table.include.list": "dbo.Transaction",
    "database.encrypt": "false",
    "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
    "schema.history.internal.kafka.topic": "schema-changes.transaction"
  }
}'

echo ""
echo "Transaction connector registered. Topic: sentinel.SentinelMock.dbo.Transaction"
