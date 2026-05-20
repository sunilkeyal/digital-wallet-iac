# Deployment Guide - OCI Free Tier (Docker + OCIR)

Deploy the Digital Wallet application to Oracle Cloud Infrastructure using Docker containers stored in OCI Container Registry (OCIR).

## Prerequisites

- Oracle Cloud Free Tier account
- Terraform CLI >= 1.5.0
- OCI CLI configured with API keys
- SSH key pair
- Docker locally (for testing)
- OCIR Auth Token (generate via OCI Console)

## Step 1: Configure OCI CLI

```bash
oci setup config
# Follow prompts to create API key at ~/.oci/config
```

## Step 2: Gather Required Info

```bash
oci iam compartment list --query 'data[0]."compartment-id"' --raw-output
oci iam region list --query 'data[*].name' --raw-output
oci os ns get  # Object Storage Namespace (also used for OCIR)
```

## Step 3: Configure Terraform

```bash
cd digital-wallet-iac
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
tenancy_ocid       = "ocid1.tenancy.oc1..aaaa..."
compartment_ocid   = "ocid1.tenancy.oc1..aaaa..."
region             = "us-ashburn-1"
ssh_public_key     = "ssh-ed25519 AAAA..."
jwt_secret         = "your-32-char-min-secret-here-1234567890"
app_admin_password = "secure-admin-password"
```

## Step 4: Deploy Infrastructure

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Step 5: Build and Push Docker Images to OCIR

### Get OCIR details

```bash
# Object Storage Namespace (from step 2)
OCI_NS="your-object-storage-ns"

# Region (from step 2)
OCI_REGION="us-ashburn-1"

# OCIR username format: <namespace>/<oci-username>
OCI_DOCKER_USER="$OCI_NS/john.doe@example.com"
```

### Login to OCIR

Generate an Auth Token from OCI Console (user avatar → My profile → Auth Tokens → Generate token).

```bash
docker login $OCI_REGION.ocir.io --username "$OCI_DOCKER_USER"
# Enter your Auth Token when prompted
```

### Build and push backend

```bash
docker build -t digital-wallet-backend ../digital-wallet-backend
docker tag digital-wallet-backend $OCI_REGION.ocir.io/$OCI_NS/digital-wallet-backend:latest
docker push $OCI_REGION.ocir.io/$OCI_NS/digital-wallet-backend:latest
```

### Build and push frontend

```bash
docker build -t digital-wallet-frontend \
  --build-arg VITE_API_BASE_URL=/api \
  ../digital-wallet-ui
docker tag digital-wallet-frontend $OCI_REGION.ocir.io/$OCI_NS/digital-wallet-frontend:latest
docker push $OCI_REGION.ocir.io/$OCI_NS/digital-wallet-frontend:latest
```

## Step 6: Deploy to VM

```bash
VM_IP=$(terraform output -raw vm_public_ip)

# Write .env with OCIR image references
ssh opc@$VM_IP "cat > /opt/digital-wallet/.env << 'EOF'
JWT_SECRET=your-32-char-min-secret-here-1234567890
JWT_EXPIRATION=86400000
APP_ADMIN_USERNAME=admin
APP_ADMIN_PASSWORD=secure-admin-password
APP_ADMIN_EMAIL=admin@digitalwallet.com
OCI_REGION=us-ashburn-1
OCI_NAMESPACE=your-ns
BACKEND_IMAGE=us-ashburn-1.ocir.io/your-ns/digital-wallet-backend:latest
FRONTEND_IMAGE=us-ashburn-1.ocir.io/your-ns/digital-wallet-frontend:latest
EOF"

# Deploy (providing OCIR credentials for docker login)
ssh opc@$VM_IP \
  "OCI_DOCKER_USERNAME='your-ns/john.doe@example.com' \
   OCI_AUTH_TOKEN='your-auth-token' \
   sudo -E /opt/digital-wallet/deploy.sh"
```

## Step 7: Verify

```bash
LB_IP=$(terraform output -raw load_balancer_public_ip)
curl http://$LB_IP/health    # Should return 200
curl -I http://$LB_IP/       # Should return 200
```

## Docker Setup on the VM

The VM runs three containers managed by Docker Compose at `/opt/digital-wallet/`:

| Container | Image | Port |
|---|---|---|
| `digital-wallet-frontend` | `<region>.ocir.io/<ns>/digital-wallet-frontend` | 80 |
| `digital-wallet-backend` | `<region>.ocir.io/<ns>/digital-wallet-backend` | 8080 |
| `digital-wallet-mongodb` | `mongo:7` | 27017 |

## Local Development with Docker

From the project root:

```bash
cp .env.example .env
# Edit .env with your secrets

docker compose up -d
# App:   http://localhost
# API:   http://localhost/api
# Mongo: mongodb://localhost:27017

docker compose down -v  # Clean up including volumes
```

## Troubleshooting

**OCIR docker login fails**: Verify your Auth Token is still valid and the username format is `<namespace>/<oci-username>`.

**Containers not starting**: Run `sudo docker compose -f /opt/digital-wallet/docker-compose.yml logs` on the VM.

**Backend can't connect to MongoDB**: Verify `mongodb` container is healthy. Check `SPRING_DATA_MONGODB_URI=mongodb://mongodb:27017/digital-wallet`.

**Load Balancer health check failing**: Verify `frontend` container is running with `sudo docker ps`. Check `sudo docker compose logs frontend`.

## Cleanup

```bash
cd digital-wallet-iac
terraform destroy -auto-approve
```

OCIR images must be deleted separately via OCI Console: Developer Services → Container Registry → delete repos.
