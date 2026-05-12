# digital-wallet-iac

Terraform infrastructure for deploying the Digital Wallet application to Azure — **configured for free-tier pricing**.

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Storage Account (static website)                │
│  → React UI (public, HTTPS-only, TLS 1.2)       │
├─────────────────────────────────────────────────┤
│  App Service F1 (Free, Linux, Java 25)           │
│  → Spring Boot backend                           │
│  → 60 CPU min/day, 1 GB RAM, 1 GB storage       │
├─────────────────────────────────────────────────┤
│  Cosmos DB (MongoDB API) — Free Tier             │
│  → 1000 RU/s, 25 GB storage, public access      │
├─────────────────────────────────────────────────┤
│  Monitoring (within 5 GB/mo free tier)           │
│  → Log Analytics + Application Insights          │
│  → Diagnostic settings on all resources          │
└─────────────────────────────────────────────────┘
```

## Resources (all free or minimal cost)

| Resource | Cost | Detail |
|----------|------|--------|
| Resource Group | **$0** | |
| Storage Account (LRS) | **~$1–2/mo** | Static website for React UI |
| Cosmos DB | **$0** | Free tier: 1000 RU/s + 25 GB |
| App Service Plan F1 | **$0** | 60 CPU min/day, 1 GB RAM |
| App Service (Java 25) | **$0** | Included in plan |
| Log Analytics | **$0** | Within 5 GB/mo free ingestion |
| Application Insights | **$0** | Shared with Log Analytics free tier |
| Diagnostic Settings | **$0** | No direct charge |
| **Total** | **~$1–2/mo** | |

> **Note:** App Service F1 has a 60 CPU minutes/day quota. Spring Boot cold starts (~30–60s) count against this. For heavier usage, upgrade to B1 ($54.75/mo) by changing `sku_name` in `appservice.tf`.

## File structure

| File | Purpose |
|------|---------|
| `main.tf` | Locals, random suffix, resource group |
| `providers.tf` | Azure provider configuration |
| `versions.tf` | Terraform version, provider pins, remote state docs |
| `variables.tf` | Input variables with defaults |
| `storage.tf` | Frontend storage account with static website |
| `cosmos.tf` | Cosmos DB (free tier) with MongoDB API |
| `appservice.tf` | App Service plan (F1) + Linux web app (Java 25) |
| `monitor.tf` | Log Analytics, Application Insights, diagnostics |
| `outputs.tf` | URLs and connection strings |

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

See the instructions in `versions.tf` — remote state requires a paid Storage Account for the backend container (~$1–2/mo).

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `resource_prefix` | `digitalwallet` | Prefix for all resource names |
| `resource_group_name` | `digital-wallet-rg` | Azure resource group |
| `location` | `eastus` | Azure region |
| `frontend_index_document` | `index.html` | Static site index |
| `frontend_error_document` | `index.html` | SPA 404 fallback |
| `backend_port` | `8080` | Spring Boot port |
| `tags` | `{}` | Extra tags merged into all resources |

## Security Notes

- Cosmos DB is publicly accessible (free tier limitation) — connection string in App Settings is your primary security boundary
- Consider upgrading to **S1 + Private Endpoint** for production networking
- Always store secrets (JWT_SECRET, etc.) in Azure Key Vault, not in App Settings
