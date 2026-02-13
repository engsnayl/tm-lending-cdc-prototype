#!/bin/bash
# Register Debezium SQL Server connector for the Agreement table
# Publishes change events to: sentinel.SentinelMock.dbo.Agreement

source .env 2>/dev/null || true

echo "Registering Agreement table connector..."

curl -s -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
  "name": "sentinel-agreement-connector",
  "config": {
    "connector.class": "io.debezium.connector.sqlserver.SqlServerConnector",
    "database.hostname": "sqlserver",
    "database.port": "1433",
    "database.user": "sa",
    "database.password": "'"${MSSQL_SA_PASSWORD:-Str0ngP@ssw0rd!}"'",
    "database.names": "SentinelMock",
    "topic.prefix": "sentinel",
    "table.include.list": "dbo.Agreement",
    "database.encrypt": "false",
    "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
    "schema.history.internal.kafka.topic": "schema-changes.agreement"
  }
}'

echo ""
echo "Agreement connector registered. Topic: sentinel.SentinelMock.dbo.Agreement"
