# Azure Naming Standards and Governance

**Northwind Health — Recommended Standard**  
**Version 1.0 — February 2026**

---

## Purpose

This document establishes the official naming convention and tag governance framework for all Azure resources in the Northwind Health environment. Consistent naming and tagging improves discoverability, enables accurate cost allocation, supports automation, and reduces operational risk.

Adoption of this standard is recommended for all new resources immediately, with a phased remediation plan for existing resources.

---

## Naming Convention

### General Pattern

```
{resource-type}-{organization}-{application}-{environment}-{instance}
```

**Example:** `app-nwh-portal-prod-001`

### Pattern Components

| Component | Description | Values |
|-----------|-------------|--------|
| `resource-type` | Abbreviated prefix for resource type | See prefix table below |
| `organization` | Company abbreviation | `nwh` |
| `application` | Application or workload name | `portal`, `api`, `notifications` |
| `environment` | Deployment environment | `prod`, `dev`, `test`, `stage` |
| `instance` | Three-digit instance number | `001`, `002`, etc. |

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
| Container Registry | `acr` | `acrnwhprod001` |
| AKS Cluster | `aks-` | `aks-nwh-prod-001` |
| App Insights | `ai-` | `ai-nwh-prod-001` |
| Log Analytics | `log-` | `log-nwh-prod-001` |
| Virtual Network | `vnet-` | `vnet-nwh-prod-eastus-001` |
| Subnet | `snet-` | `snet-nwh-prod-web` |
| Private Endpoint | `pep-` | `pep-nwh-sql-prod-001` |
| Private DNS Zone | `pdnsz-` | `pdnsz-privatelink-sql` |
| Network Security Group | `nsg-` | `nsg-nwh-prod-web` |
| Public IP | `pip-` | `pip-nwh-portal-prod-001` |
| Virtual Machine | `vm-` | `vm-nwh-legacy-001` |
| Managed Disk | `disk-` | `disk-nwh-vm001-os` |
| Managed Identity | `id-` | `id-nwh-portal-prod` |

---

## Special Naming Rules

### Storage Accounts (24-character limit, no hyphens)

```
st{org}{purpose}{instance}
```

**Example:** `stnwhpatientdocs001`

### Container Registries (50-character limit, no hyphens)

```
acr{org}{env}{instance}
```

**Example:** `acrnwhprod001`

### Resource Groups (include region)

```
rg-{org}-{env}-{function}-{region}
```

**Example:** `rg-nwh-prod-web-eastus`

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

| Region | Code |
|--------|------|
| East US | `eastus` |
| East US 2 | `eastus2` |
| West US 2 | `westus2` |
| Central US | `centralus` |
| West Europe | `westeurope` |

---

## Required Tags

All resources must have the following tags applied at creation:

| Tag | Description | Example Values |
|-----|-------------|----------------|
| `env` | Environment | `prod`, `dev`, `test`, `stage` |
| `app` | Application name | `patient-portal`, `notifications`, `shared` |
| `owner` | Technical owner (email) | `j.martinez@northwindhealth.fake` |
| `costcenter` | Financial cost center | `CC-4100`, `CC-4200` |
| `data_classification` | Data sensitivity | `PHI`, `Confidential`, `Internal`, `Test` |
| `lifecycle` | Resource lifecycle status | `active`, `review`, `temporary`, `deprecated` |

### Optional Tags

| Tag | Description |
|-----|-------------|
| `created_by` | Creation method (terraform, manual, pipeline) |
| `created_date` | Resource creation date |
| `expiry_date` | For temporary resources |
| `compliance` | Compliance requirements (HIPAA, SOC2) |

---

## Data Classification Values

| Classification | Description | Handling |
|----------------|-------------|----------|
| `PHI` | Protected Health Information | Encryption required, access logging, HIPAA BAA |
| `Confidential` | Sensitive business data | Encryption required, need-to-know access |
| `Internal` | Internal business use | Standard access controls |
| `Public` | Publicly shareable | No special controls |
| `Test` | Test/synthetic data only | No production data allowed |

---

## Examples: Good vs. Bad Names

### App Services

| ✓ Good | ✗ Bad | Issue |
|--------|-------|-------|
| `app-nwh-portal-prod-001` | `PatientPortal` | Missing prefix, environment, instance |
| `func-nwh-notifications-prod-001` | `myfunction` | Generic, unidentifiable |

### Storage Accounts

| ✓ Good | ✗ Bad | Issue |
|--------|-------|-------|
| `stnwhpatientdocs001` | `st-nwh-docs` | Hyphens not allowed |
| `stnwhbackups001` | `storageaccount1` | Generic, no context |

### SQL Resources

| ✓ Good | ✗ Bad | Issue |
|--------|-------|-------|
| `sql-nwh-main-prod-001` | `SQLServer` | Generic, uppercase |
| `sqldb-nwh-patients-prod` | `database1` | No context |

### Resource Groups

| ✓ Good | ✗ Bad | Issue |
|--------|-------|-------|
| `rg-nwh-prod-web-eastus` | `ResourceGroup1` | Generic |
| `rg-nwh-dev-api-eastus` | `rg-portal` | Missing environment, region |

---

## Implementation Plan

### Phase 1: New Resources (Immediate)

- Apply naming standard to all newly created resources
- Configure Azure Policy to enforce tag requirements
- Document exceptions in governance register

### Phase 2: Existing Resources (Next Maintenance Window)

- Inventory resources requiring rename
- Plan remediation during scheduled maintenance
- Update automation scripts and documentation

### Phase 3: Policy Enforcement (This Quarter)

- Enable deny policies for non-compliant names in Production
- Implement automated compliance reporting
- Schedule quarterly governance reviews

---

## Governance Enforcement

### Azure Policy Recommendations

1. **Require tags on resource creation** — Deny creation without required tags
2. **Enforce naming patterns** — Custom policy to validate naming convention
3. **Audit non-compliant resources** — Monthly compliance report

### Exception Process

Deviations from this standard require:
1. Documented technical justification
2. Approval from cloud governance lead
3. Entry in exceptions register with review date

---

## Ownership Reference

| Cost Center | Department | Primary Owner |
|-------------|------------|---------------|
| CC-4000 | Infrastructure | m.thompson@northwindhealth.fake |
| CC-4100 | Patient Portal | j.martinez@northwindhealth.fake |
| CC-4200 | Messaging | s.chen@northwindhealth.fake |
| CC-4300 | Data Platform | d.patel@northwindhealth.fake |
| CC-4500 | Container Platform | l.garcia@northwindhealth.fake |

---

*This standard is based on Microsoft Cloud Adoption Framework recommendations, adapted for Northwind Health requirements.*
