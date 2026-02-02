# Naming Convention Examples

**Reference:** See [`naming-standard.md`](naming-standard.md) for complete rules and constraints.

---

## Good vs Bad Names

### Resource Groups

| ✅ Good | ❌ Bad | Why Bad |
|---------|--------|---------|
| `rg-nwh-prod-web-eastus` | `ResourceGroup1` | Generic, no context |
| `rg-nwh-dev-api-eastus` | `rg-portal` | Missing environment and region |
| `rg-nwh-shared-identity-eastus` | `Production-Resources` | Spaces not allowed, too vague |

### App Services

| ✅ Good | ❌ Bad | Why Bad |
|---------|--------|---------|
| `app-nwh-portal-prod-001` | `PatientPortal` | Missing prefix, environment, instance |
| `app-nwh-portalapi-dev-001` | `app-1` | No meaningful identification |
| `func-nwh-notifications-prod-001` | `myfunction` | Generic, unidentifiable |

### Storage Accounts

| ✅ Good | ❌ Bad | Why Bad |
|---------|--------|---------|
| `stnwhpatientdocs001` | `st-nwh-docs` | Hyphens not allowed in storage |
| `stnwhbackups001` | `storageaccount1` | Generic, no purpose or owner context |
| `stnwhdevdata001` | `NWHStorage` | Uppercase not allowed |

### Key Vaults

| ✅ Good | ❌ Bad | Why Bad |
|---------|--------|---------|
| `kv-nwh-prod-001` | `KeyVault` | Generic, no environment |
| `kv-nwh-dev-001` | `kv_production_main` | Underscores not standard |
| | `my-keyvault` | Missing organization identifier |

### SQL Resources

| ✅ Good | ❌ Bad | Why Bad |
|---------|--------|---------|
| `sql-nwh-main-prod-001` | `SQLServer` | Generic, uppercase |
| `sqldb-nwh-patients-prod` | `PatientDB` | Missing prefix, environment |
| `sqldb-nwh-appointments-prod` | `database1` | No context whatsoever |

### Virtual Networks

| ✅ Good | ❌ Bad | Why Bad |
|---------|--------|---------|
| `vnet-nwh-prod-eastus-001` | `VNet1` | Generic, no context |
| `snet-nwh-prod-web` | `Subnet-Web` | Inconsistent casing |
| `snet-nwh-prod-data` | `default` | Default names provide no value |

---

## Complete Resource Examples

Below are 20 concrete examples following the Northwind Health naming standard:

### Production Environment

| # | Resource Type | Name | Purpose |
|---|---------------|------|---------|
| 1 | Resource Group | `rg-nwh-prod-web-eastus` | Production web tier resources |
| 2 | Resource Group | `rg-nwh-prod-api-eastus` | Production API tier resources |
| 3 | Resource Group | `rg-nwh-prod-data-eastus` | Production data tier resources |
| 4 | App Service | `app-nwh-portal-prod-001` | Patient portal frontend |
| 5 | App Service | `app-nwh-portalapi-prod-001` | Patient portal API |
| 6 | App Service Plan | `plan-nwh-portal-prod-001` | Shared hosting plan for web apps |
| 7 | Function App | `func-nwh-notifications-prod-001` | Notification processing |
| 8 | Storage Account | `stnwhpatientdocs001` | Patient document storage |
| 9 | Storage Account | `stnwhbackups001` | Backup storage |
| 10 | SQL Server | `sql-nwh-main-prod-001` | Primary SQL Server |
| 11 | SQL Database | `sqldb-nwh-patients-prod` | Patient records database |
| 12 | Key Vault | `kv-nwh-prod-001` | Production secrets |
| 13 | Service Bus | `sb-nwh-prod-001` | Messaging namespace |
| 14 | App Insights | `ai-nwh-prod-001` | Application monitoring |
| 15 | Virtual Network | `vnet-nwh-prod-eastus-001` | Production network |
| 16 | Subnet | `snet-nwh-prod-web` | Web tier subnet |
| 17 | Private Endpoint | `pep-nwh-sql-prod-001` | SQL private connectivity |
| 18 | Container Registry | `acrnwhprod001` | Container images |
| 19 | AKS Cluster | `aks-nwh-prod-001` | Kubernetes cluster |
| 20 | Managed Identity | `id-nwh-portal-prod` | Portal app identity |

### Development Environment

| # | Resource Type | Name | Purpose |
|---|---------------|------|---------|
| 1 | Resource Group | `rg-nwh-dev-web-eastus` | Development web resources |
| 2 | App Service | `app-nwh-portal-dev-001` | Dev patient portal |
| 3 | App Service Plan | `plan-nwh-portal-dev-001` | Dev hosting plan |
| 4 | SQL Server | `sql-nwh-main-dev-001` | Dev SQL Server |
| 5 | Key Vault | `kv-nwh-dev-001` | Dev secrets |

---

## Anti-Patterns to Avoid

### 1. Personal Names
❌ `rg-john-test` → ✅ `rg-nwh-test-portal-eastus`

### 2. Dates in Resource Names
❌ `sql-backup-20250115` → ✅ `snap-nwh-backup-20250115` (dates OK in snapshots only)

### 3. Sequential Without Purpose
❌ `vm1`, `vm2`, `vm3` → ✅ `vm-nwh-web-prod-001`, `vm-nwh-web-prod-002`

### 4. Abbreviations Without Standard
❌ `pp-api-prd` → ✅ `app-nwh-portalapi-prod-001`

### 5. Mixed Casing
❌ `KeyVault-PROD-Main` → ✅ `kv-nwh-prod-001`

### 6. Overly Long Names
❌ `app-northwind-health-patient-portal-production-east-us-primary-001` → ✅ `app-nwh-portal-prod-001`

---

## Tag Examples

Every resource should have these tags applied:

```json
{
  "env": "prod",
  "app": "patient-portal",
  "owner": "j.martinez@northwindhealth.fake",
  "costcenter": "CC-4100",
  "data_classification": "PHI",
  "lifecycle": "active"
}
```

### Tag Values by Environment

| Tag | Production | Development | Test |
|-----|------------|-------------|------|
| `env` | `prod` | `dev` | `test` |
| `data_classification` | `PHI`, `Confidential`, `Internal` | `Test` | `Test` |
| `lifecycle` | `active` | `active` | `temporary` |

---

## Checklist for New Resources

Before creating any Azure resource:

- [ ] Resource type prefix is correct
- [ ] Organization code (`nwh`) is included
- [ ] Application name is meaningful
- [ ] Environment is specified (`prod`, `dev`, `test`, `stage`)
- [ ] Instance number uses three digits
- [ ] Name meets length constraints
- [ ] No forbidden characters used
- [ ] All required tags are defined
- [ ] Owner is identified

---

*Consistent naming today prevents confusion tomorrow.*
