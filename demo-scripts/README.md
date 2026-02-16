# Azure Governance Demo - Messy Environment Deployment Scripts

## Purpose

These scripts create a **deliberately ungoverned Azure environment** for demonstration purposes. The environment simulates what happens when resources are created organically over 3-5 years without proper governance, naming standards, or tagging strategies.

**This is NOT a best-practice environment.** It is intentionally messy to showcase governance issues.

---

## Available Scripts

| Script | Platform | Description |
|--------|----------|-------------|
| [`deploy-messy-azure-environment.sh`](deploy-messy-azure-environment.sh) | Bash (Linux/macOS/WSL) | Shell script using Azure CLI |
| [`deploy-messy-azure-environment.ps1`](deploy-messy-azure-environment.ps1) | PowerShell (Windows) | PowerShell script using Azure CLI |

---

## Prerequisites

1. **Azure CLI** installed and configured
2. **Logged in** to Azure: `az login`
3. **Subscription selected**: `az account set -s <subscription-id>`
4. **Sufficient permissions** to create resources (Contributor role or higher)

---

## Usage

### Bash (Linux/macOS/WSL)

```bash
chmod +x deploy-messy-azure-environment.sh
./deploy-messy-azure-environment.sh
```

### PowerShell (Windows)

```powershell
.\deploy-messy-azure-environment.ps1
```

---

## What Gets Created

### Resource Groups (Inconsistent Naming)

| Name | Location | Tags | Issue |
|------|----------|------|-------|
| `appCoreRG` | East US | None | camelCase naming |
| `customer-data-prod` | West US 2 | None | kebab-case naming |
| `rg1-test-misc` | East US | `createdby=bob`, `temp=maybe` | Random style |

### Resources Summary

| Resource Type | Name | Resource Group | Issues |
|---------------|------|----------------|--------|
| Storage Account | `stgdata{suffix}` | appCoreRG | Shared by multiple services (hidden dependency) |
| Storage Account | `logsarchive{suffix}` | customer-data-prod | Different naming style, partial tags |
| SQL Server | `sqlsrv{suffix}` | customer-data-prod | Different region than apps |
| SQL Database | `CustomerDB` | customer-data-prod | No tags |
| App Service Plan | `plan-prod-apps` | appCoreRG | Free tier |
| Web App | `webapp-main-{suffix}` | appCoreRG | Connected to storage (hidden dependency) |
| Web App | `CustomerPortal{suffix}` | appCoreRG | Connected to SQL in different RG |
| Function App | `func-processor-{suffix}` | rg1-test-misc | Shares storage (cross-RG dependency) |
| VNet | `vnet-legacy-{suffix}` | rg1-test-misc | Undocumented purpose |
| Subnet | `subnet1` | rg1-test-misc | Unknown purpose |
| Subnet | `backend-snet` | rg1-test-misc | Unknown purpose |
| Public IP | `pip-old-lb-{suffix}` | rg1-test-misc | **ORPHANED** - not attached |
| Managed Disk | `disk-backup-temp` | customer-data-prod | **ORPHANED** - not attached |
| Key Vault | `kv-legacy-{suffix}` | appCoreRG | Minimal configuration |

---

## Governance Issues Created

This environment intentionally contains the following governance problems:

1. **Inconsistent Resource Group Naming**
   - Mixed conventions: camelCase, kebab-case, random with numbers

2. **Mixed Azure Regions**
   - Resources spread across East US and West US 2
   - SQL Database in different region than connecting App Services

3. **Missing/Inconsistent Tags**
   - Most resources have no tags
   - Some have random, unhelpful tags (`temp=maybe`)
   - No consistent tagging strategy

4. **Hidden Dependencies**
   - Storage account shared between Web App and Function App
   - Not documented or visible in Azure Portal easily

5. **Cross-Resource-Group Dependencies**
   - Web App in `appCoreRG` connects to SQL in `customer-data-prod`
   - Function App in `rg1-test-misc` uses storage in `appCoreRG`

6. **Orphaned Resources (Waste)**
   - Public IP address not attached to anything
   - Managed Disk not attached to any VM

7. **No Diagnostic Settings**
   - No logging or monitoring configured
   - No insights into resource health

8. **Undocumented Networking**
   - VNet and subnets with no clear purpose
   - No documentation on intended use

9. **Security Concerns**
   - SQL firewall allows all Azure services (0.0.0.0)
   - Key Vault with minimal configuration

10. **Naming Inconsistencies**
    - Resources don't follow any naming convention
    - Mix of styles: kebab-case, camelCase, no separator

---

## Estimated Cost

This environment uses the **cheapest possible SKUs**:

| Resource | SKU | Estimated Monthly Cost |
|----------|-----|----------------------|
| Storage Accounts (2x) | Standard_LRS | ~$0.50 each |
| SQL Database | Basic (5 DTU) | ~$5/month |
| App Service Plan | Free (F1) | Free |
| Function App | Consumption | Pay-per-use (minimal) |
| Public IP | Basic Dynamic | ~$3/month |
| Managed Disk | Standard 32GB | ~$1.50/month |
| Key Vault | Standard | ~$0.03/10k operations |
| VNet | - | Free |

**Total Estimated Cost: < $15/month**

---

## Cleanup

To delete all resources created by this script, run:

```bash
az group delete -n appCoreRG --yes --no-wait
az group delete -n customer-data-prod --yes --no-wait
az group delete -n rg1-test-misc --yes --no-wait
```

Or in PowerShell:

```powershell
az group delete -n appCoreRG --yes --no-wait
az group delete -n customer-data-prod --yes --no-wait
az group delete -n rg1-test-misc --yes --no-wait
```

> **Note:** The `--no-wait` flag allows commands to run in parallel. Deletion may take 5-10 minutes.

---

## Dependency Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AZURE MESSY ENVIRONMENT                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────┐     ┌────────────────────────────────┐         │
│  │     appCoreRG           │     │   customer-data-prod            │        │
│  │     (East US)           │     │   (West US 2)                   │        │
│  │                         │     │                                  │        │
│  │  ┌─────────────────┐   │     │  ┌─────────────────┐            │        │
│  │  │ stgdata{suffix} │◄──┼─────┼──┤ Web App 2       │            │        │
│  │  │ Storage Account │   │     │  │ CustomerPortal  │            │        │
│  │  └────────┬────────┘   │     │  └────────┬────────┘            │        │
│  │           │            │     │           │                      │        │
│  │           │            │     │           ▼                      │        │
│  │  ┌────────┴────────┐   │     │  ┌─────────────────┐            │        │
│  │  │ Web App 1       │   │     │  │ SQL Server      │            │        │
│  │  │ webapp-main     │   │     │  │ sqlsrv{suffix}  │            │        │
│  │  └─────────────────┘   │     │  │                 │            │        │
│  │                         │     │  │ ┌─────────────┐│            │        │
│  │  ┌─────────────────┐   │     │  │ │ CustomerDB  ││            │        │
│  │  │ Key Vault       │   │     │  │ └─────────────┘│            │        │
│  │  │ kv-legacy       │   │     │  └─────────────────┘            │        │
│  │  └─────────────────┘   │     │                                  │        │
│  │                         │     │  ┌─────────────────┐            │        │
│  │  ┌─────────────────┐   │     │  │ Managed Disk    │ ⚠ ORPHAN   │        │
│  │  │ App Service Plan│   │     │  │ disk-backup-temp│            │        │
│  │  │ plan-prod-apps  │   │     │  └─────────────────┘            │        │
│  │  └─────────────────┘   │     │                                  │        │
│  └─────────────────────────┘     │  ┌─────────────────┐            │        │
│                                   │  │ logsarchive     │            │        │
│                                   │  │ Storage Account │            │        │
│  ┌─────────────────────────┐     │  └─────────────────┘            │        │
│  │     rg1-test-misc       │     └────────────────────────────────┘        │
│  │     (East US)           │                                                │
│  │                         │                                                │
│  │  ┌─────────────────┐   │                                                │
│  │  │ Function App    │───┼────► Uses stgdata{suffix} from appCoreRG       │
│  │  │ func-processor  │   │                                                │
│  │  └─────────────────┘   │                                                │
│  │                         │                                                │
│  │  ┌─────────────────┐   │                                                │
│  │  │ VNet            │   │                                                │
│  │  │ vnet-legacy     │   │                                                │
│  │  │ ├─ subnet1      │   │                                                │
│  │  │ └─ backend-snet │   │                                                │
│  │  └─────────────────┘   │                                                │
│  │                         │                                                │
│  │  ┌─────────────────┐   │                                                │
│  │  │ Public IP       │ ⚠ │  ORPHAN - Not attached to anything            │
│  │  │ pip-old-lb      │   │                                                │
│  │  └─────────────────┘   │                                                │
│  └─────────────────────────┘                                                │
│                                                                              │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  LEGEND:  ──► Dependency   ⚠ Risk/Waste   ◄── Shared Resource             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Next Steps

After deploying this environment, you can:

1. **Analyze with Azure Resource Graph** - Query resources and dependencies
2. **Export inventory** - Use Azure CLI to export all resources to JSON/CSV
3. **Map dependencies** - Document hidden connections between resources
4. **Identify waste** - Find orphaned resources (disk, IP)
5. **Propose governance** - Create naming conventions, tagging policies
6. **Demonstrate Azure Policy** - Show how policies could prevent future issues
7. **Present findings** - Use this as a baseline for governance recommendations

---

## Author

Azure Governance & Systems Consulting
