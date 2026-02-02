# Azure Naming Convention Standard

**Client:** Northwind Health  
**Version:** 1.0  
**Last Updated:** February 2026

---

## Overview

This document defines the naming convention standard for all Azure resources in the Northwind Health environment. Consistent naming improves discoverability, supports automation, enables accurate cost allocation, and reduces operational risk.

---

## General Pattern

```
{resource-type}-{organization}-{application}-{environment}-{instance}
```

### Components

| Component | Description | Example Values |
|-----------|-------------|----------------|
| `resource-type` | Abbreviated resource type prefix | `app`, `func`, `sql`, `st`, `kv` |
| `organization` | Company or business unit abbreviation | `nwh` |
| `application` | Application or workload name | `portal`, `api`, `notifications` |
| `environment` | Deployment environment | `prod`, `dev`, `test`, `stage` |
| `instance` | Numeric instance identifier | `001`, `002` |

---

## Resource Type Prefixes

| Azure Resource | Prefix | Example |
|----------------|--------|---------|
| Resource Group | `rg-` | `rg-nwh-prod-web-eastus` |
| App Service | `app-` | `app-nwh-portal-prod-001` |
| App Service Plan | `plan-` | `plan-nwh-portal-prod-001` |
| Function App | `func-` | `func-nwh-notifications-prod-001` |
| Storage Account | `st` | `stnwhpatientdocs001` |
| SQL Server | `sql-` | `sql-nwh-main-prod-001` |
| SQL Database | `sqldb-` | `sqldb-nwh-patients-prod` |
| Key Vault | `kv-` | `kv-nwh-prod-001` |
| Service Bus | `sb-` | `sb-nwh-prod-001` |
| Container Registry | `acr-` | `acr-nwh-prod-001` |
| AKS Cluster | `aks-` | `aks-nwh-prod-001` |
| App Insights | `ai-` | `ai-nwh-prod-001` |
| Log Analytics | `log-` | `log-nwh-prod-001` |
| Virtual Network | `vnet-` | `vnet-nwh-prod-eastus-001` |
| Subnet | `snet-` | `snet-nwh-prod-web` |
| Network Security Group | `nsg-` | `nsg-nwh-prod-web` |
| Private Endpoint | `pep-` | `pep-nwh-sql-prod-001` |
| Private DNS Zone | `pdnsz-` | `pdnsz-privatelink-sql` |
| Public IP | `pip-` | `pip-nwh-portal-prod-001` |
| Virtual Machine | `vm-` | `vm-nwh-legacy-001` |
| Disk | `disk-` | `disk-nwh-vm001-os` |
| Managed Identity | `id-` | `id-nwh-portal-prod` |
| Network Interface | `nic-` | `nic-nwh-vm001` |
| Snapshot | `snap-` | `snap-nwh-backup-20250115` |

---

## Environment Codes

| Environment | Code | Usage |
|-------------|------|-------|
| Production | `prod` | Live customer-facing workloads |
| Staging | `stage` | Pre-production validation |
| Test | `test` | Integration and QA testing |
| Development | `dev` | Developer sandboxes |

---

## Region Codes

Use standard Azure region names in resource group names or where disambiguation is needed:

| Region | Code |
|--------|------|
| East US | `eastus` |
| East US 2 | `eastus2` |
| West US 2 | `westus2` |
| Central US | `centralus` |
| West Europe | `westeurope` |
| North Europe | `northeurope` |

---

## Length Constraints & Special Rules

Different Azure resources have different naming constraints:

| Resource Type | Max Length | Allowed Characters | Notes |
|---------------|------------|-------------------|-------|
| Resource Group | 90 | Alphanumeric, `-`, `_`, `.`, `()` | Cannot end with period |
| Storage Account | 24 | **Lowercase alphanumeric only** | No hyphens allowed |
| Key Vault | 24 | Alphanumeric, `-` | Must start with letter |
| SQL Server | 63 | Lowercase alphanumeric, `-` | Cannot start/end with hyphen |
| App Service | 60 | Alphanumeric, `-` | Cannot start/end with hyphen |
| Function App | 60 | Alphanumeric, `-` | Same as App Service |
| Container Registry | 50 | **Alphanumeric only** | No hyphens allowed |
| AKS Cluster | 63 | Alphanumeric, `-`, `_` | Must start with letter |
| Virtual Network | 64 | Alphanumeric, `-`, `_`, `.` | — |

### Storage Account Special Rule

Because storage accounts cannot contain hyphens and have a 24-character limit, use a condensed format:

```
st{org}{purpose}{env}{instance}
```

**Example:** `stnwhpatientdocs001`

### Container Registry Special Rule

Container registries cannot contain hyphens:

```
acr{org}{env}{instance}
```

**Example:** `acrnwhprod001`

---

## Forbidden Patterns

❌ **Do not use:**
- Spaces in any resource name
- Special characters except where explicitly allowed
- Generic names like `test`, `temp`, `new`, `copy`
- Personal identifiers like usernames or initials
- Sequential names without purpose (e.g., `app1`, `app2`)

---

## Required Tags

All resources **must** have the following tags applied:

| Tag Key | Description | Example Values |
|---------|-------------|----------------|
| `env` | Environment | `prod`, `dev`, `test`, `stage` |
| `app` | Application name | `patient-portal`, `notifications`, `shared` |
| `owner` | Technical owner email | `j.martinez@northwindhealth.fake` |
| `costcenter` | Cost allocation code | `CC-4100` |
| `data_classification` | Data sensitivity level | `PHI`, `Confidential`, `Internal`, `Public`, `Test` |
| `lifecycle` | Resource lifecycle status | `active`, `review`, `temporary`, `deprecated` |

### Optional Tags

| Tag Key | Description | Example Values |
|---------|-------------|----------------|
| `created_by` | Who created the resource | `terraform`, `manual`, `pipeline` |
| `created_date` | Creation date | `2025-01-15` |
| `expiry_date` | For temporary resources | `2025-03-01` |
| `compliance` | Compliance requirements | `HIPAA`, `SOC2` |

---

## Resource Group Naming

Resource groups should group resources by:
- Environment
- Application or functional area
- Region

**Pattern:**
```
rg-{org}-{environment}-{function}-{region}
```

**Examples:**
- `rg-nwh-prod-web-eastus` — Production web tier resources
- `rg-nwh-prod-data-eastus` — Production data tier resources
- `rg-nwh-dev-api-eastus` — Development API resources
- `rg-nwh-shared-identity-eastus` — Shared identity resources

---

## Instance Numbering

- Use three-digit instance numbers: `001`, `002`, `003`
- Start at `001` for single instances (allows for future scaling)
- Increment sequentially for multiple instances of the same type

---

## Subscription Naming

**Pattern:**
```
{org}-{purpose}
```

**Examples:**
- `NWH-Production` — Production workloads
- `NWH-Development` — Development and test workloads
- `NWH-Shared-Services` — Cross-cutting infrastructure

---

## Enforcement

- Use Azure Policy to enforce naming patterns
- Implement tag requirements via policy
- Run compliance reports monthly
- Block non-compliant resource creation in Production

---

## Exceptions

Any deviation from this standard requires:
1. Documented justification
2. Approval from the cloud governance team
3. Entry in the exceptions register with review date

---

*This standard is based on Microsoft Cloud Adoption Framework recommendations and adapted for Northwind Health requirements.*
