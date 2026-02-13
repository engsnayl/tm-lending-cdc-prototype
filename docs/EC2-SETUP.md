# Running on AWS EC2

Step-by-step guide for running the CDC prototype on an AWS EC2 instance.

> **Important**: Use a personal AWS account, not a company account.

## Terraform (Recommended)

The fastest way to get running. Terraform provisions the instance, installs Docker, clones the repo, and runs `setup.sh` automatically — you SSH in and it's ready.

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- AWS credentials configured (`aws configure` or environment variables)
- Your public IP (find it at https://checkip.amazonaws.com)

### Steps

```bash
cd terraform

# Create your tfvars file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — set allowed_ip to your IP

terraform init
terraform plan      # Review what will be created
terraform apply     # Provision everything (takes ~5 minutes)
```

Terraform outputs your SSH command and Kafka UI URL when it finishes:

```
ssh_command  = "ssh -i ./cdc-prototype-key.pem ec2-user@3.10.x.x"
kafka_ui_url = "http://3.10.x.x:8080"
```

Wait a few minutes for cloud-init to complete, then SSH in and check:

```bash
# Check if setup finished
cat ~/setup-complete.txt

# Verify containers are running
cd tm-lending-cdc-prototype && docker compose ps
```

### Teardown

```bash
terraform destroy   # Removes instance, security group, and key pair
```

---

## Manual Setup

The steps below walk through manual EC2 setup if you prefer not to use Terraform.

## 1. Launch an EC2 Instance

- **Region**: eu-west-2 (London)
- **Instance type**: t3.large (2 vCPU, 8 GB RAM)
- **AMI**: Amazon Linux 2023 or Ubuntu 24.04 LTS
- **Storage**: 30 GB gp3 (default 8 GB is not enough for Docker images)
- **Key pair**: Create or select an existing SSH key pair

## 2. Configure Security Group

Create or modify a security group with these inbound rules:

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22 | TCP | Your IP | SSH access |
| 8080 | TCP | Your IP | Kafka UI (web browser) |
| 8083 | TCP | Your IP | Kafka Connect REST API (optional) |
| 1433 | TCP | Your IP | SQL Server (optional, for SSMS access) |

> Only open ports to **your IP address**, not `0.0.0.0/0`.

## 3. SSH Into the Instance

```bash
ssh -i your-key.pem ec2-user@<EC2-PUBLIC-IP>
# or for Ubuntu:
ssh -i your-key.pem ubuntu@<EC2-PUBLIC-IP>
```

## 4. Install Docker and Docker Compose

### Amazon Linux 2023

```bash
sudo dnf update -y
sudo dnf install -y docker git
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install Docker Compose plugin
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Log out and back in for group membership to take effect
exit
```

### Ubuntu 24.04

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose-v2 git
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Log out and back in
exit
```

## 5. Clone and Run

```bash
ssh -i your-key.pem ec2-user@<EC2-PUBLIC-IP>

git clone https://github.com/<your-username>/tm-lending-cdc-prototype.git
cd tm-lending-cdc-prototype

# Create .env file
cp .env.example .env
# Edit .env if you want to change the SA password
# nano .env

# Run setup
bash scripts/setup.sh
```

## 6. Access Kafka UI

Open your browser and navigate to:

```
http://<EC2-PUBLIC-IP>:8080
```

You should see the Kafka UI with the `sentinel-cdc` cluster.

## 7. Run Test Events

From the SSH session:

```bash
# Run all events with pauses
docker compose exec sqlserver bash /test-events/run-all-events.sh

# Or run individual events
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P 'Str0ngP@ssw0rd!' \
  -d SentinelMock -i /test-events/01-payment-received.sql -C
```

Watch the events appear in Kafka UI in your browser.

## 8. Cost Notes

| Resource | Cost |
|----------|------|
| t3.large on-demand | ~$0.0832/hr (~$2.00/day) |
| 30 GB gp3 storage | ~$2.40/month |

**To save money**:
- **Stop the instance** when not using it (you only pay for storage when stopped)
- Use a **spot instance** for ~60-70% savings if you don't mind potential interruption
- **Terminate** the instance entirely when done with the prototype

```bash
# Stop the Docker stack before stopping the instance
bash scripts/teardown.sh
```

Then stop the EC2 instance from the AWS Console or CLI:

```bash
aws ec2 stop-instances --instance-ids <INSTANCE-ID> --region eu-west-2
```

## 9. Troubleshooting

### Docker daemon not running
```bash
sudo systemctl start docker
```

### Permission denied on Docker
```bash
sudo usermod -aG docker $USER
# Log out and back in
```

### SQL Server not starting (out of memory)
The t3.large (8 GB) should be sufficient. If using a smaller instance, SQL Server 2022 requires at least 2 GB RAM. Check with:
```bash
docker compose logs sqlserver
```

### Kafka Connect not registering connectors
Wait 30-60 seconds after startup, then retry:
```bash
curl http://localhost:8083/connectors
bash connectors/register-transaction-connector.sh
bash connectors/register-agreement-connector.sh
```
