# Azure Deployment Guide for Digital Wallet

## Prerequisites

- **Azure CLI** — https://aka.ms/installazurecliwindows
- **Terraform** ≥ 1.5 — https://www.terraform.io/downloads
- **An Azure subscription** with permissions to create resources

## Step-by-step Deployment

### 1. Authenticate to Azure

```powershell
az login
az account set --subscription "your-subscription-id"
```

### 2. Configure Variables

```powershell
cd digital-wallet-iac
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your preferred prefix, region, etc.
```

### 3. Initialize and Deploy

```powershell
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

This provisions (5-10 minutes):

| Resource | Detail |
|----------|--------|
| Resource Group | Container for all resources |
| Virtual Network + Subnets | Private endpoints + App Service delegation |
| Storage Account | Static website for React UI (public) |
| Cosmos DB (MongoDB API) | Private endpoint, public access disabled |
| App Service Plan (S1 Linux) | Standard tier for VNet integration |
| App Service (Java 21) | Spring Boot with VNet integration |
| Private Endpoint | Cosmos DB via private IP |
| Log Analytics + App Insights | Monitoring and diagnostics |

### 4. Retrieve Outputs

```powershell
terraform output
```

Shows:
- `frontend_static_website_url` — React UI URL
- `backend_app_url` — Spring Boot API URL
- `cosmos_account_name` — Cosmos DB account name
- `application_insights_connection_string` — (sensitive) App Insights connection

### 5. Deploy the UI

```powershell
cd ../digital-wallet-ui
npm run build

$storageAccount = "your-storage-account-name"  # from terraform output
az storage blob upload-batch -s ./dist -d '$web' --account-name $storageAccount
```

### 6. Deploy the Backend

```powershell
cd ../digital-wallet-backend
./gradlew build

$appService = "your-app-service-name"  # from terraform output
az webapp deployment source config-zip `
  --resource-group digital-wallet-rg `
  --name $appService `
  --src build/libs/*.jar
```

### 7. Verify

Open `frontend_static_website_url` in a browser. The UI should load and connect to the backend API.

## Enabling Remote State (for teams)

See the instructions in `versions.tf` or the [README](./README.md#remote-state-recommended-for-teams).

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `az login` fails | Reinstall Azure CLI, ensure browser allows popups |
| `Resource group already exists` | Safe to reuse; delete with `az group delete -n digital-wallet-rg --yes` if you want fresh |
| `Subscription not found` | Run `az account list --output table` to find your subscription ID |
| Backend won't start | Check App Service logs in Azure Portal or App Insights |

## Cleanup

```powershell
terraform destroy
```

This deletes all resources. **This cannot be undone.** Cosmos DB data will be lost.
