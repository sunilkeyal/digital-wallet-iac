# digital-wallet-iac

Terraform infrastructure for deploying the Digital Wallet application to Azure — **entirely on free-tier pricing**.

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Azure Static Web Apps (Free)                    │
│  → React UI, global CDN, free SSL, 100 GB bw    │
├─────────────────────────────────────────────────┤
│  App Service F1 (Free, Linux, Java 25)           │
│  → Spring Boot backend                           │
│  → 60 CPU min/day, 1 GB RAM                     │
├─────────────────────────────────────────────────┤
│  Cosmos DB (MongoDB API) — Free Tier             │
│  → 1000 RU/s, 25 GB storage                     │
├─────────────────────────────────────────────────┤
│  Monitoring (within 5 GB/mo free tier)           │
│  → Log Analytics + Application Insights          │
│  → Diagnostic settings on backend + Cosmos DB    │
└─────────────────────────────────────────────────┘
```

## Resources — **$0/month**

| Resource | Cost | Detail |
|----------|------|--------|
| Resource Group | **$0** | |
| Azure Static Web Apps (Free) | **$0** | 100 GB bandwidth, 500 MB storage, global CDN, SSL |
| Cosmos DB (Free Tier) | **$0** | 1000 RU/s + 25 GB storage |
| App Service Plan F1 | **$0** | 60 CPU min/day, 1 GB RAM |
| App Service (Java 25) | **$0** | Included in plan |
| Log Analytics (PerGB2018) | **$0** | Within 5 GB/mo free ingestion |
| Application Insights | **$0** | Shared with Log Analytics free tier |
| Diagnostic Settings | **$0** | No direct charge |
| **Total** | **$0/mo** | |

## File structure

| File | Purpose |
|------|---------|
| `main.tf` | Locals, random suffix, resource group |
| `providers.tf` | Azure provider configuration |
| `versions.tf` | Terraform version, provider pins, remote state docs |
| `variables.tf` | Input variables with defaults |
| `storage.tf` | Azure Static Web Apps (replaces Storage Account) |
| `cosmos.tf` | Cosmos DB (free tier) with MongoDB API |
| `appservice.tf` | App Service plan (F1) + Linux web app (Java 25) |
| `monitor.tf` | Log Analytics, Application Insights, diagnostics |
| `outputs.tf` | URLs and connection strings |

## Usage

```powershell
cd digital-wallet-iac
cp terraform.tfvars.example terraform.tfvars
# (terraform.tfvars is gitignored — secrets stay local)

terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Limitations

- **App Service F1**: 60 CPU min/day quota. Cold start ~30–60s. No always-on — app goes idle after ~20 min.
- **Cosmos DB Free Tier**: Only 1 free account per subscription. Publicly accessible (connection string is auth boundary).
- **Static Web Apps Free**: 500 MB storage, 100 GB bandwidth. Connected source repo for CI is optional.
- **Log Analytics**: 30-day retention, 5 GB/mo free ingestion.

Upgrade path: B1 ($54.75/mo) for App Service, S1 ($73/mo) + Private Endpoint for production networking.
