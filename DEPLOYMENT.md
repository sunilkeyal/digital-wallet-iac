# Deployment Guide — Digital Wallet (Free Tier)

## Prerequisites

- **Azure CLI** — https://aka.ms/installazurecliwindows
- **Terraform** ≥ 1.5 — https://www.terraform.io/downloads
- **An Azure subscription** with permissions to create resources

## Estimated Monthly Cost: ~$1–2

Everything runs on free-tier or minimal-cost resources. See [README](./README.md) for the breakdown.

## Step-by-step

### 1. Authenticate to Azure

```powershell
az login
az account set --subscription "your-subscription-id"
```

### 2. Configure Variables

```powershell
cd digital-wallet-iac
cp terraform.tfvars.example terraform.tfvars
# Edit prefix, region, etc.
```

### 3. Deploy

```powershell
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### 4. Retrieve Outputs

```powershell
terraform output
```

### 5. Deploy the UI

```powershell
cd ../digital-wallet-ui
npm run build

$storageAccount = "your-storage-account-name"
az storage blob upload-batch -s ./dist -d '$web' --account-name $storageAccount
```

### 6. Deploy the Backend

```powershell
cd ../digital-wallet-backend
./gradlew build

$appService = "your-app-service-name"
az webapp deployment source config-zip `
  --resource-group digital-wallet-rg `
  --name $appService `
  --src build/libs/*.jar
```

## Free Tier Limitations

| Limitation | Impact | Mitigation |
|-----------|--------|------------|
| App Service F1: 60 CPU min/day | Spring Boot cold start uses ~30–60s | Avoid frequent restarts; upgrade to B1 ($54.75/mo) if needed |
| App Service F1: 1 GB RAM | Should be fine for Spring Boot with ~256–512 MB footprint | Monitor in App Insights |
| App Service F1: No always-on | App goes idle after ~20 min inactivity, cold start on next request | Acceptable for dev/demo; set up synthetic ping |
| Cosmos DB free tier: 1000 RU/s | Limits throughput | Sufficient for dev; check Azure Portal for throttling |
| Cosmos DB free tier: Public access | Database accessible from internet | Connection string is the auth boundary; rotate if compromised |
| Cosmos DB free tier: 1 per subscription | Only one free account per sub | Existing free accounts will cause deployment to fail |

## Cleanup

```powershell
terraform destroy
```
