# Architecture

## Component Diagram

```
┌─────────────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   SQL Server 2022   │     │   Debezium    │     │    Apache    │     │   Kafka UI   │
│   (Mock Sentinel)   │────>│ (Kafka Connect│────>│    Kafka     │<────│  (Browser)   │
│                     │ CDC │  Connector)   │     │              │     │              │
│  - Agreement table  │     │              │     │  Topics:      │     │  localhost:   │
│  - Transaction table│     │  localhost:   │     │  - sentinel.  │     │    8080      │
│                     │     │    8083       │     │    ...dbo.    │     │              │
│  localhost:1433     │     │              │     │    Transaction│     └──────────────┘
└─────────────────────┘     └──────────────┘     │  - sentinel.  │
                                                  │    ...dbo.    │
                                                  │    Agreement  │
                                                  │              │
                                                  │  localhost:   │
                                                  │   9092/29092  │
                                                  └──────────────┘
```

## How It Maps to the Real Tandem Architecture

| Prototype Component | Real Component | Notes |
|---------------------|----------------|-------|
| SQL Server 2022 (SentinelMock) | Aryza Sentinel (SQL Server) | Real system has 269 columns on Agreement, 55 on Transaction. We mock the TM-relevant subset. |
| Debezium SQL Server Connector | Debezium (same tool) | Matt Champion is using the same Debezium connector in production. |
| Apache Kafka | Apache Kafka | Same pattern: one topic per table. Topic naming: `sentinel.SentinelMock.dbo.<TableName>` |
| Kafka UI | N/A | Dev convenience tool. Production uses different monitoring. |

## What's NOT Simulated

The downstream pipeline after Kafka is not part of this prototype:

```
Kafka ──> Ledger ──> Identity ──> Lucinity (TM Platform)
          ^^^^^     ^^^^^^^^     ^^^^^^^^
          NOT       NOT          NOT
          SIMULATED SIMULATED    SIMULATED
```

- **Ledger**: Assembles transaction events with enrichment data (expected payment amounts, payment profiles)
- **Identity**: Resolves `AgreementCustomerNumber` and `AgreementBorrowers` to global customer identities
- **Lucinity**: The Transaction Monitoring platform that evaluates rules (R1-R7)

## Data Flow

1. **Test SQL scripts** simulate what the real Sentinel application does when processing a payment, refund, or settlement
2. **SQL Server CDC** captures row-level changes to the Agreement and Transaction tables using the transaction log
3. **Debezium** reads the CDC change tables and publishes structured JSON events to Kafka topics
4. **Kafka** stores the events in topics, one per table
5. **Kafka UI** provides a browser-based view of the topics and messages

## CDC Mechanism

SQL Server CDC works by:
1. SQL Server Agent runs a capture job that reads the transaction log
2. Changes are written to CDC change tables (`cdc.dbo_Agreement_CT`, `cdc.dbo_Transaction_CT`)
3. Debezium polls these change tables and publishes events to Kafka
4. Each event includes `before` and `after` states for updates, or just `after` for inserts

## Debezium Event Structure

Each Kafka message from Debezium contains:

```json
{
  "schema": { ... },
  "payload": {
    "before": null,           // null for INSERTs, previous state for UPDATEs
    "after": { ... },         // new row state
    "source": {
      "connector": "sqlserver",
      "db": "SentinelMock",
      "schema": "dbo",
      "table": "Transaction",
      "change_lsn": "...",
      "commit_lsn": "..."
    },
    "op": "c",                // c=create, u=update, d=delete, r=read (snapshot)
    "ts_ms": 1234567890
  }
}
```

## Connector Configuration

Two separate Debezium connectors are registered:

1. **sentinel-transaction-connector**: Watches `dbo.Transaction`, publishes to `sentinel.SentinelMock.dbo.Transaction`
2. **sentinel-agreement-connector**: Watches `dbo.Agreement`, publishes to `sentinel.SentinelMock.dbo.Agreement`

Using separate connectors per table allows independent scaling, monitoring, and failure isolation.

## Network Topology

All services run in a single Docker Compose network:

- **Internal**: Services communicate via Docker DNS (e.g., `kafka:9092`, `sqlserver:1433`)
- **External**: Host machine accesses via mapped ports (`localhost:8080` for Kafka UI, `localhost:8083` for Connect API, `localhost:1433` for SQL Server)
