# TM Lending CDC Prototype

A Change Data Capture (CDC) prototype that simulates how Tandem Bank's lending platform (Sentinel, built by Aryza) publishes data changes to Kafka using Debezium. This is a learning and demonstration environment — it replicates the Sentinel → Debezium → Kafka portion of the Transaction Monitoring pipeline for lending, allowing you to see exactly how database changes become streaming events.

## Architecture

```
┌─────────────────────┐         ┌──────────────┐         ┌──────────────┐
│   SQL Server 2022   │  CDC    │   Debezium   │  JSON   │    Apache    │
│   (Mock Sentinel)   │────────>│  (Kafka      │────────>│    Kafka     │
│                     │         │   Connect)   │         │              │
│  Agreement table    │         │  :8083       │         │  :9092       │
│  Transaction table  │         └──────────────┘         └──────┬───────┘
│  :1433              │                                         │
└─────────────────────┘                                         │
                                                         ┌──────┴───────┐
                                                         │   Kafka UI   │
                                                         │  (Browser)   │
                                                         │  :8080       │
                                                         └──────────────┘
```

**What's simulated**: SQL Server (Mock Sentinel) → Debezium → Kafka → Kafka UI

**What's NOT simulated**: Ledger, Identity, Lucinity (downstream consumers)

## Prerequisites

- Docker and Docker Compose
- ~4 GB free RAM (SQL Server alone needs 2 GB)
- `git` (to clone the repo)
- `curl` (included on most systems)

## Quick Start

```bash
# Clone the repo
git clone https://github.com/<your-username>/tm-lending-cdc-prototype.git
cd tm-lending-cdc-prototype

# Create your .env file (or use the defaults)
cp .env.example .env

# Start everything (Docker stack, database, CDC, connectors)
bash scripts/setup.sh

# Open Kafka UI in your browser
# http://localhost:8080
```

Setup takes 1-2 minutes. When complete, you'll have:
- SQL Server with the SentinelMock database, 4 test agreements, and CDC enabled
- Kafka running with two Debezium connectors watching the Agreement and Transaction tables
- Kafka UI accessible at [http://localhost:8080](http://localhost:8080)

## Running Test Events

Run all test events in sequence (with 5-second pauses between each):

```bash
docker compose exec sqlserver bash /test-events/run-all-events.sh
```

Or run individual events:

```bash
# Scheduled DD payment
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P 'Str0ngP@ssw0rd!' \
  -d SentinelMock -i /test-events/01-payment-received.sql -C
```

### Test Events

| Script | Event | Agreement | What to Look For |
|--------|-------|-----------|------------------|
| `01-payment-received.sql` | Scheduled DD payment | FRH0000291 | Transaction INSERT + Agreement UPDATE (balance decreases by £403.37) |
| `02-card-payment.sql` | Card payment | FRP0002871 | Same pattern but TransTypeID=32, PaymentMethod=8 |
| `03-lump-sum-payment.sql` | £5,000 overpayment | FRM0001544 | R1/R2 trigger: payment is 21x the expected £230 |
| `04-refund-issued.sql` | Customer refund | FRM0001544 | R5 trigger: TransTypeID=3, balance INCREASES |
| `05-account-settled.sql` | Final payment + settlement | FRH0000150 | R3 trigger: balance→0, SettledFlag 0→1, multiple Agreement UPDATEs |
| `06-account-opened.sql` | New agreement funded | FRH0000400 | R4 trigger: Agreement INSERT (PaymentProfile inserts are NOT on Kafka) |

## The Four Business Events

### Payment Received (R1/R2)
A scheduled or ad-hoc payment lands against an agreement. Sentinel inserts a Transaction row and updates the Agreement balance. The TM rules compare the payment amount against the expected amount (from Custom Profile or Payment Profile).

### Refund Issued (R5)
A refund is processed back to the customer. The Transaction is inserted with a refund type code and the Agreement balance **increases**. Any refund triggers an alert.

### Account Settled (R3)
The final payment brings the balance to zero. Sentinel updates the settlement fields (`AgreementSettledFlag`, `AgreementSettledDate`, `AgreementAutoStatus`). This may produce multiple Kafka events if the updates are in separate commits.

### Account Opened (R4)
A new agreement is funded and inserted into Sentinel. Only the Agreement INSERT appears on Kafka — Payment Profile and Custom Profile tables don't have CDC enabled.

## The Two CDC Streams

| Kafka Topic | Source Table | Trigger |
|-------------|-------------|---------|
| `sentinel.SentinelMock.dbo.Transaction` | `dbo.Transaction` | Every INSERT (payments, refunds) |
| `sentinel.SentinelMock.dbo.Agreement` | `dbo.Agreement` | Every INSERT or UPDATE (new accounts, balance changes, settlements) |

## What to Observe

1. **Two separate events per payment**: A single business event (e.g., "DD payment received") produces events on TWO different Kafka topics — a Transaction INSERT and an Agreement UPDATE. These arrive independently.

2. **Event correlation challenge**: The Transaction event and Agreement event share `AgreementNumber` / `TransAgreementNumber` but have different timestamps. Downstream consumers must correlate them.

3. **Settlement produces multiple updates**: The `05-account-settled.sql` script produces up to 3 Kafka events (1 Transaction INSERT + 2 Agreement UPDATEs), demonstrating why event ordering and correlation matter.

4. **Before/After in updates**: Agreement UPDATE events include both `before` and `after` states, so you can see exactly which fields changed (e.g., `AgreementCurrentBalanceNET` going from 403.37 to 0.00).

## Expected Payment Lookup Logic

To determine the "expected" payment amount for R1/R2 rules:

1. **Check CustomProfile first**: If a row exists for the agreement with `CPOnGoing = 1` and `CPDeleted = 0`, use `CPAmount`
2. **Fall back to PaymentProfile**: Sum all `PayProNetAmount` rows for the current payment period (includes Pay + Fee1 + Fee2 rows)

Example for FRH0000291:
- CustomProfile exists: `CPAmount = £403.37` → use this
- PaymentProfile would give: Fee1 (£4.97) + Fee2 (£15.77) + Pay (£382.63) = £403.37

Example for FRM0001544:
- No CustomProfile exists
- PaymentProfile: Fee1 (£3.50) + Fee2 (£11.50) + Pay (£215.00) = £230.00

## Helper Scripts

```bash
bash scripts/setup.sh          # Full setup (start stack, DB, CDC, connectors)
bash scripts/list-topics.sh    # List all Kafka topics
bash scripts/watch-topics.sh   # Watch both CDC topics in real time
bash scripts/read-topic.sh <topic>  # Read a specific topic
bash scripts/teardown.sh       # Stop and remove everything
```

## Running on AWS EC2

See [docs/EC2-SETUP.md](docs/EC2-SETUP.md) for a step-by-step guide to run this on a t3.large instance in eu-west-2 (London). Cost is approximately $0.08/hour on-demand.

**Terraform (recommended):** `cd terraform && terraform init && terraform apply` — provisions the instance, installs Docker, and runs setup automatically. See the [Terraform section](docs/EC2-SETUP.md#terraform-recommended) for details.

## Further Documentation

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — Component relationships and mapping to real Tandem architecture
- [docs/EVENTS.md](docs/EVENTS.md) — Detailed event specifications, write sequences, and edge cases
- [docs/EC2-SETUP.md](docs/EC2-SETUP.md) — AWS EC2 setup guide

## Teardown

```bash
bash scripts/teardown.sh
```

This removes all containers, networks, and volumes.
