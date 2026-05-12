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

## CI/CD — GitHub Actions

A workflow is provided at `.github/workflows/deploy-infra.yml` that:

1. **Validates** — `terraform fmt`, `init`, `validate` on every PR/push
2. **Plans** — `terraform plan` with Azure OIDC authentication
3. **Applies** — `terraform apply` on push to `main` (requires environment approval)

### GitHub Secrets (sensitive)

| Secret | Purpose |
|--------|---------|
| `TFE_TOKEN` | Terraform Cloud API token (for remote state) |
| `AZURE_CLIENT_ID` | Service principal client ID (OIDC federated credential) |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |

### GitHub Variables (non-sensitive)

| Variable | Default | Purpose |
|----------|---------|---------|
| `TF_CLOUD_ORGANIZATION` | — | Terraform Cloud organization name |
| `TF_CLOUD_WORKSPACE` | `digital-wallet-iac` | Terraform Cloud workspace name |
| `TF_RESOURCE_PREFIX` | `dw` | Terraform `resource_prefix` var |
| `TF_RESOURCE_GROUP_NAME` | `digital-wallet-rg` | Terraform `resource_group_name` var |
| `TF_LOCATION` | `eastus` | Terraform `location` var |
| `TF_ENVIRONMENT` | `dev` | GitHub environment name |

### Setting up OIDC Federated Credentials

1. Create an Azure service principal:
   ```powershell
   az ad sp create-for-rbac --name "github-actions-digital-wallet" `
     --role Contributor `
     --json-auth false
   ```
2. Note the `clientId`, `tenantId`, and `subscriptionId`.
3. In the Azure portal, go to your App Registration → **Certificates & secrets** → **Federated credentials**.
4. Add a credential for GitHub Actions:
   - **Entity type**: `Environment`
   - **GitHub org**: your GitHub org/user
   - **Repository**: `digital-wallet-iac`
   - **Environment**: `dev`
   - **Name**: `github-actions-dev`
5. Repeat for a `production` environment if needed.

### Setting up Terraform Cloud

1. Create a free account at [app.terraform.io](https://app.terraform.io)
2. Create an organization and note the name
3. Generate a **Team API token** (Settings → Teams → Create token)
4. Add the token as `TFE_TOKEN` in GitHub Secrets
5. Add the organization name as `TF_CLOUD_ORGANIZATION` in GitHub Variables
6. The workspace (`digital-wallet-iac`) is created automatically on first `terraform init`

## Limitations

- **App Service F1**: 60 CPU min/day quota. Cold start ~30–60s. No always-on — app goes idle after ~20 min.
- **Cosmos DB Free Tier**: Only 1 free account per subscription. Publicly accessible (connection string is auth boundary).
- **Static Web Apps Free**: 500 MB storage, 100 GB bandwidth. Connected source repo for CI is optional.
- **Log Analytics**: 30-day retention, 5 GB/mo free ingestion.

Upgrade path: B1 ($54.75/mo) for App Service, S1 ($73/mo) + Private Endpoint for production networking.
