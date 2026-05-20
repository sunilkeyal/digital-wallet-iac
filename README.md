# Digital Wallet - Oracle Cloud Infrastructure (Free Tier)

Terraform configuration to deploy the Digital Wallet application to Oracle Cloud Infrastructure using Always Free resources — **\$0/month**.

## Architecture

```
User Browser
     |
     v
[OCI Flexible Load Balancer (10 Mbps)]  <-- HTTP, free tier
     |                                      1 LB free per tenancy
     | port 80
     v
[Ampere A1.Flex VM (4 OCPU, 24 GB)]    <-- Docker Host
     |                                      Always Free: 4 OCPUs, 24 GB RAM
     | ┌──────────────────────────────┐
     │ │ frontend (Nginx, port 80)    │
     │ │   /api/* -> backend:8080     │
     │ │   /* -> static SPA files     │
     │ ├──────────────────────────────┤
     │ │ backend (Spring Boot, 8080)  │
     │ ├──────────────────────────────┤
     │ │ mongodb (mongo:7, 27017)     │
     │ └──────────────────────────────┘
```

All three services run as Docker containers on a single Ampere A1.Flex instance. Docker images are stored in **OCI Container Registry (OCIR)** and pulled during CI/CD deployment.

## Resources Provisioned

| Resource | Shape / Config | Always Free Limit |
|---|---|---|
| VCN | 10.0.0.0/16 | 2 VCNs per tenancy |
| Public Subnet | 10.0.1.0/24 | Included with VCN |
| Internet Gateway | 1 | Included with VCN |
| Security List | HTTP(80), SSH(22) | Included with VCN |
| Network Security Group | Compute ingress/egress rules | Included with VCN |
| Compute Instance | VM.Standard.A1.Flex (4 OCPU, 24 GB, 47 GB boot) | 4 OCPUs, 24 GB RAM, 200 GB storage |
| Flexible Load Balancer | 10 Mbps | 1 LB free per tenancy |
| Object Storage Bucket | Standard, NoPublicAccess | 20 GB total across tiers |

## Prerequisites

1. **Oracle Cloud Free Tier account** ([signup](https://signup.cloud.oracle.com))
2. **Terraform** >= 1.5.0
3. **OCI CLI** configured with API keys
4. **SSH key pair** for VM access
5. **Docker** locally (for testing build)
6. **OCIR Auth Token** — generated from OCI Console (user avatar → My profile → Auth Tokens → Generate token)

## Quick Start

### 1. Collect OCIDs and namespace

```bash
oci iam compartment list --query 'data[0]."compartment-id"' --raw-output
oci iam region list --query 'data[*].name' --raw-output
oci os ns get  # Get object storage namespace for OCIR
```

### 2. Configure Terraform

```bash
cd digital-wallet-iac
cp terraform.tfvars.example terraform.tfvars
# Edit with your OCIDs, SSH key, JWT secret, admin password
```

### 3. Provision infrastructure

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 4. Build and push Docker images to OCIR

```bash
# Login to OCIR
docker login ${OCI_REGION}.ocir.io --username ${OBJECT_STORAGE_NS}/${OCI_USERNAME}
# (enter your Auth Token as password)

# Build and push backend
docker build -t digital-wallet-backend ./digital-wallet-backend
docker tag digital-wallet-backend ${REGION}.ocir.io/${NS}/digital-wallet-backend:latest
docker push ${REGION}.ocir.io/${NS}/digital-wallet-backend:latest

# Build and push frontend
docker build -t digital-wallet-frontend --build-arg VITE_API_BASE_URL=/api ./digital-wallet-ui
docker tag digital-wallet-frontend ${REGION}.ocir.io/${NS}/digital-wallet-frontend:latest
docker push ${REGION}.ocir.io/${NS}/digital-wallet-frontend:latest
```

### 5. Deploy on the VM

```bash
VM_IP=$(terraform output -raw vm_public_ip)

ssh opc@$VM_IP "cat > /opt/digital-wallet/.env << 'EOF'
JWT_SECRET=your-secret
JWT_EXPIRATION=86400000
APP_ADMIN_USERNAME=admin
APP_ADMIN_PASSWORD=your-password
APP_ADMIN_EMAIL=admin@digitalwallet.com
OCI_REGION=us-ashburn-1
OCI_NAMESPACE=your-object-storage-ns
BACKEND_IMAGE=us-ashburn-1.ocir.io/your-ns/digital-wallet-backend:latest
FRONTEND_IMAGE=us-ashburn-1.ocir.io/your-ns/digital-wallet-frontend:latest
EOF"

ssh opc@$VM_IP "OCI_DOCKER_USERNAME='your-ns/your-email' OCI_AUTH_TOKEN='your-token' sudo -E /opt/digital-wallet/deploy.sh"
```

### 6. Access

```bash
terraform output application_url
# http://<load-balancer-ip>
```

## Docker Images

All images are stored in **OCI Container Registry (OCIR)**:

| Image | OCIR URL | Base | Purpose |
|---|---|---|---|
| Backend | `<region>.ocir.io/<ns>/digital-wallet-backend` | `eclipse-temurin:25-jre` | Spring Boot REST API on port 8080 |
| Frontend | `<region>.ocir.io/<ns>/digital-wallet-frontend` | `nginx:alpine` | Serves React SPA, proxies `/api` to backend |

Build locally:
```bash
docker build -t digital-wallet-backend ./digital-wallet-backend
docker build -t digital-wallet-frontend --build-arg VITE_API_BASE_URL=/api ./digital-wallet-ui
```

Run locally with Docker Compose (from project root):
```bash
cp .env.example .env  # Edit with your secrets
docker compose up -d
# Frontend: http://localhost:80
# Backend:  http://localhost:8080/api
# MongoDB:  mongodb://localhost:27017
```

## Cost Breakdown

| Service | Plan | Cost |
|---|---|---|
| Compute | VM.Standard.A1.Flex (Always Free) | \$0 |
| Load Balancer | Flexible 10 Mbps (Always Free) | \$0 |
| Object Storage + OCIR | Standard + Container Registry (always free) | \$0 |
| VCN / Networking | Included | \$0 |
| Terraform Cloud | Free tier | \$0 |
| **Total** | | **\$0/month** |

## CI/CD Pipeline

The GitHub Actions workflow (`deploy-infra.yml`) has three stages:

1. **build-and-push** — Builds backend + frontend Docker images and pushes to OCIR
2. **deploy-infra** — Provisions/updates OCI infrastructure via Terraform
3. **deploy-apps** — SSHs into VM, writes `.env` with OCIR image tags + OCIR auth, runs `deploy.sh`

### Required GitHub Secrets

| Secret | Description |
|---|---|
| `OCI_TENANCY_OCID` | Tenancy OCID |
| `OCI_COMPARTMENT_OCID` | Compartment OCID (usually tenancy OCID) |
| `OCI_SSH_PUBLIC_KEY` | SSH public key for VM |
| `OCI_SSH_PRIVATE_KEY` | SSH private key for CI/CD deployment |
| `OCI_DOCKER_USERNAME` | OCIR username: `<object-storage-ns>/<oci-username>` |
| `OCI_AUTH_TOKEN` | Auth token generated in OCI Console for your user |
| `JWT_SECRET` | JWT signing secret (min 32 chars) |
| `APP_ADMIN_PASSWORD` | Admin user password |
| `TFE_TOKEN` | Terraform Cloud API token |

### Required GitHub Variables

| Variable | Description |
|---|---|
| `OCI_REGION` | OCI home region (e.g. `us-ashburn-1`) |
| `OCI_OBJECT_STORAGE_NAMESPACE` | OCI object storage namespace (get via `oci os ns get`) |

### Finding your OCIR username and namespace

```bash
# Object Storage Namespace
oci os ns get

# OCIR Docker username format: <namespace>/<oci-username>
# e.g. "axbcyz123abc/john.doe@example.com"
```

## Limitations

- **Compute reboot**: OCI may reclaim or reboot Always Free instances during maintenance
- **Load Balancer**: 10 Mbps bandwidth limit
- **Storage**: 200 GB total boot + block volume across all Always Free instances
- **Cold starts**: VM may need ~2 minutes to fully boot after provisioning
- **Always Free**: Resources must be in your **home region**

## Cleanup

```bash
cd digital-wallet-iac
terraform destroy -auto-approve
```

Images in OCIR must be deleted separately via OCI Console or CLI.
