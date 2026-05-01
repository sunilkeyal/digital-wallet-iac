# digital-wallet-iac

This folder contains Terraform infrastructure for deploying the Digital Wallet UI and backend to Azure.

## What is included

- Azure Resource Group
- Azure Storage Account with static website hosting for the UI
- Azure Cosmos DB account configured for MongoDB API
- Azure Cosmos DB Mongo database
- Azure App Service Plan for the backend
- Azure Linux App Service running Java 21 for the backend

## Terraform file structure

- `main.tf` - shared configuration, common locals, random name suffix, and resource group definition.
- `storage.tf` - frontend storage account and static website configuration for the UI.
- `cosmos.tf` - Cosmos DB account and Mongo database resources.
- `appservice.tf` - App Service Plan and backend App Service definition.
- `providers.tf` - Terraform Azure provider configuration.
- `variables.tf` - input variables required for deployment.
- `outputs.tf` - useful outputs such as the static website URL and backend app URL.

## Usage

1. Change into the IAC folder:

   ```powershell
   cd digital-wallet-iac
   ```

2. Initialize Terraform:

   ```powershell
   terraform init
   ```

3. Validate the configuration:

   ```powershell
   terraform validate
   ```

4. Format the files (optional):

   ```powershell
   terraform fmt -recursive
   ```

5. Apply the configuration:

   ```powershell
   terraform apply
   ```

   Or customize values with:

   ```powershell
   terraform apply -var="resource_group_name=digital-wallet-rg" -var="location=eastus"
   ```

6. After apply completes, Terraform will output the UI website URL and backend app URL.

## Sample terraform.tfvars

Create a `terraform.tfvars` file in the same folder to provide values for the deployment:

```hcl
resource_group_name = "digital-wallet-rg"
location            = "eastus"
resource_prefix     = "dw"
frontend_index_document = "index.html"
frontend_error_document = "404.html"
backend_port        = 8080
app_service_plan_sku = "B1"
```

> Adjust `resource_prefix` and `location` to match your Azure naming and region preferences.

## Deploying the applications

- Build and publish the UI assets, then upload them to the Storage Account static website container.
- Deploy the backend JAR to the App Service, for example via Azure CLI, GitHub Actions, or Azure DevOps.

## Notes

- `storage.tf` defines the Azure Storage Account with static website hosting.
- `cosmos.tf` defines the Cosmos DB account and MongoDB database used by the backend.
- `appservice.tf` defines the App Service Plan and the Java-based backend App Service.
- The backend app settings include the Cosmos DB MongoDB connection string and database name.
- The UI static website uses `index.html` as the default document and should be published as a static site.
