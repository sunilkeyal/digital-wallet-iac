# Deployment Guide — Digital Wallet (Free Tier)

**Estimated cost: $0/month**

## Prerequisites

- **Azure CLI** — https://aka.ms/installazurecliwindows
- **Terraform** ≥ 1.5 — https://www.terraform.io/downloads
- **Node.js** (for building the UI and using SWA CLI)
- **An Azure subscription**

## Step-by-step

### 1. Authenticate

```powershell
az login
az account set --subscription "your-subscription-id"
```

### 2. Deploy Infrastructure

```powershell
cd digital-wallet-iac
cp terraform.tfvars.example terraform.tfvars

terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan

# Note the output URLs
terraform output
```

### 3. Deploy the UI to Static Web Apps

```powershell
cd ../digital-wallet-ui

# Build the React app
npm run build

# Install the Static Web Apps CLI
npm install -g @azure/static-web-apps-cli

# Get the SWA name from terraform output
$swaName = (terraform -chdir=../digital-wallet-iac output -raw frontend_static_app_name)

# Deploy
swa deploy ./dist --app-name $swaName
```

### 4. Deploy the Backend

```powershell
cd ../digital-wallet-backend
./gradlew build

$appService = (terraform -chdir=../digital-wallet-iac output -raw backend_app_name)

az webapp deployment source config-zip `
  --resource-group digital-wallet-rg `
  --name $appService `
  --src build/libs/*.jar
```

### 5. Cleanup

```powershell
cd ../digital-wallet-iac
terraform destroy
```
