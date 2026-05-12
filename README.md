# digital-wallet-iac

Terraform infrastructure for deploying the Digital Wallet application to Azure.

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Storage Account (static website)                │
│  → React UI (publicly accessible)               │
├─────────────────────────────────────────────────┤
│  App Service (Linux, Java 21)                    │
│  → Spring Boot backend                           │
│  → VNet integration for private egress           │
├─────────────────────────────────────────────────┤
│  Cosmos DB (MongoDB API)                         │
│  → Private endpoint (no public access)           │
├─────────────────────────────────────────────────┤
│  Monitoring                                      │
│  → Log Analytics + Application Insights          │
│  → Diagnostic settings on all resources          │
└─────────────────────────────────────────────────┘
```

## Resources

- **Resource Group** — container for all resources
- **Virtual Network** — `10.0.0.0/16` with subnets for private endpoints and App Service
- **Storage Account** — static website hosting for the React UI (HTTPS-only, TLS 1.2)
- **Cosmos DB** — MongoDB API, private endpoint, public access disabled, bounded staleness consistency
- **App Service Plan** — Linux, S1+ (Standard required for VNet integration)
- **App Service** — Java 21 Spring Boot, VNet-integrated for private outbound traffic
- **Private Endpoint** — Cosmos DB accessible only via private IP
- **Log Analytics** — centralized logs and metrics
- **Application Insights** — application performance monitoring
- **Diagnostic Settings** — streaming logs/metrics from App Service, Cosmos DB, Storage

## File structure

| File | Purpose |
|------|---------|
| `main.tf` | Locals, random suffix, resource group |
| `providers.tf` | Azure provider (no hardcoded subscription) |
| `versions.tf` | Terraform version, provider pins, remote state docs |
| `variables.tf` | All input variables with defaults and validations |
| `network.tf` | VNet, subnets, private endpoints, DNS zones |
| `storage.tf` | Frontend storage account with static website |
| `cosmos.tf` | Cosmos DB account with MongoDB API |
| `appservice.tf` | App Service plan + Linux web app + VNet integration |
| `monitor.tf` | Log Analytics, Application Insights, diagnostics |
| `outputs.tf` | URLs, names, and monitoring connection strings |

## Usage

```powershell
cd digital-wallet-iac

# Copy and edit your variables
cp terraform.tfvars.example terraform.tfvars
# (terraform.tfvars is gitignored — secrets stay local)

terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Remote State (recommended for teams)

By default, state is stored locally. To enable remote state in Azure Storage:

```powershell
# 1. Create the state storage manually
az group create -n digital-wallet-tfstate -l eastus
az storage account create -n <unique-name> -g digital-wallet-tfstate -l eastus --sku Standard_LRS
az storage container create -n tfstate --account-name <unique-name>

# 2. Uncomment the backend block in versions.tf and set your account name

# 3. Migrate
terraform init -migrate
```

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `resource_prefix` | `digitalwallet` | Prefix for all resource names |
| `resource_group_name` | `digital-wallet-rg` | Azure resource group |
| `location` | `eastus` | Azure region |
| `app_service_plan_sku` | `S1` | App Service SKU (S1+ for VNet) |
| `frontend_index_document` | `index.html` | Static site index |
| `frontend_error_document` | `index.html` | SPA 404 fallback |
| `backend_port` | `8080` | Spring Boot port |
| `vnet_address_space` | `10.0.0.0/16` | VNet CIDR |
| `subnet_private_endpoints_prefix` | `10.0.1.0/24` | PE subnet |
| `subnet_appservice_prefix` | `10.0.2.0/24` | App Service subnet |
| `log_analytics_sku` | `PerGB2018` | Log Analytics tier |
| `tags` | `{}` | Extra tags merged into all resources |

## Deploying applications

See [DEPLOYMENT.md](./DEPLOYMENT.md) for steps to build and upload the UI and backend.

## Security

- Cosmos DB: private endpoint, public access disabled
- Storage Account: HTTPS-only, TLS 1.2
- App Service: HTTPS-only, VNet integration for outbound traffic
- No secrets hardcoded — all passed via variables or generated
