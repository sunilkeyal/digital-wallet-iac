# Azure Deployment Guide for Digital Wallet

## Prerequisites

You must have the following installed on your system:

1. **Azure CLI** - Download from https://aka.ms/installazurecliwindows
2. **Terraform** - Download from https://www.terraform.io/downloads
3. **A valid Azure subscription** with permissions to create resources

## Step-by-step Deployment

### 1. Install Azure CLI

Download the Windows installer from: https://aka.ms/installazurecliwindows

After installation, restart your PowerShell terminal and verify:

```powershell
az --version
```

### 2. Authenticate to Azure

```powershell
az login
```

This will open your browser for interactive authentication. Confirm the Azure subscription:

```powershell
az account set --subscription 0ebe7661-7a3a-4632-bd5e-0bed8e7154af
```

### 3. Initialize Terraform

From the `digital-wallet-iac` directory:

```powershell
cd digital-wallet-iac
terraform init
```

### 4. Plan the Deployment

Generate a plan to preview all resources that will be created:

```powershell
terraform plan -out=tfplan
```

Review the plan output. It will create:

- Azure Resource Group: `digital-wallet-rg` in `eastus`
- Storage Account: for static website hosting (React UI)
- Cosmos DB Account: MongoDB API database
- App Service Plan: `B1` Linux plan
- App Service: for Spring Boot backend

### 5. Apply the Configuration

Deploy the infrastructure to Azure:

```powershell
terraform apply tfplan
```

This will take 5-10 minutes to complete.

### 6. Retrieve Outputs

After successful deployment, Terraform will display the URLs:

```powershell
terraform output
```

You should see:
- `frontend_static_website_url`: URL to the React UI
- `backend_app_url`: URL to the Spring Boot API

### 7. Deploy Applications

**Deploy the UI:**

Build and upload the React UI to the storage account static website:

```powershell
cd digital-wallet-ui
npm run build

# Get the storage account name from terraform output
$storageAccountName = terraform output -raw frontend_storage_account_name

# Upload to storage
az storage blob upload-batch -s ./dist -d '$web' --account-name $storageAccountName
```

**Deploy the Backend:**

Build the Spring Boot JAR and deploy to App Service:

```powershell
cd digital-wallet-backend
./gradlew build

# Get the app service name from terraform output
$appServiceName = terraform output -raw backend_app_name

# Deploy the JAR
az webapp deployment source config-zip --resource-group digital-wallet-rg --name $appServiceName --src build/libs/digital-wallet-backend-0.0.1-SNAPSHOT.jar
```

## Troubleshooting

### Error: "unable to build authorizer"

Make sure Azure CLI is installed and you have successfully run `az login`.

### Error: "Resource group already exists"

If the resource group exists, the deployment will skip creation. If you want a fresh deployment, manually delete the resource group:

```powershell
az group delete --name digital-wallet-rg --yes
```

### Error: "Subscription not found"

Verify your subscription ID is correct:

```powershell
az account list --output table
```

## Cleanup

To destroy all resources created by Terraform:

```powershell
terraform destroy
```

Confirm when prompted.

## Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure CLI Documentation](https://docs.microsoft.com/cli/azure/)
- [Azure App Service Documentation](https://docs.microsoft.com/azure/app-service/)
