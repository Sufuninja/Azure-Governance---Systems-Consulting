# Change Control and Safety Procedures

**Document Type:** Safety Procedures  
**Version:** 1.0  
**Last Updated:** February 2026

---

## Purpose

This document defines the guardrails, approval processes, and rollback procedures for implementing changes during an Azure audit engagement. Following these procedures protects client environments and ensures changes can be reversed if issues arise.

---

## Core Principles

### 1. Read-Only First
Discovery phase uses **only Reader access**. No write permissions granted until:
- Discovery is complete
- Findings reviewed with client
- Change plan approved
- Proper backups confirmed

### 2. Document Before Doing
Every change must be documented **before** execution:
- What will change
- Why it's changing
- Expected outcome
- Rollback procedure

### 3. Non-Production First
Test changes in development/test environments before production:
- Validate change procedure works
- Identify unexpected side effects
- Build confidence in rollback

### 4. Staged Deletion
Never delete resources immediately. Follow the quarantine process:
1. Move to quarantine resource group
2. Wait observation period (7-14 days)
3. Validate no dependencies
4. Delete only after confirmation

### 5. Client Ownership
- Client personnel execute all changes
- Consultant provides guidance and scripts
- Changes are made by those accountable for the environment

---

## Change Categories

### Category 1: Safe Changes (Low Risk)

**Examples:**
- Adding or modifying tags
- Creating resource groups
- Enabling diagnostic settings
- Modifying Log Analytics retention
- Scaling up resources (more capacity)

**Approval:** Technical lead verbally approves  
**Timing:** Anytime during business hours  
**Rollback:** Simple and immediate

---

### Category 2: Moderate Changes (Medium Risk)

**Examples:**
- Scaling down non-production resources
- Changing storage tier (Hot → Cool)
- Modifying App Service Plan SKU (non-prod)
- Deleting orphaned resources (after quarantine)
- Changing backup retention policies

**Approval:** Technical lead written approval (email/ticket)  
**Timing:** Business hours, with monitoring  
**Rollback:** May require brief service interruption

---

### Category 3: Impactful Changes (Higher Risk)

**Examples:**
- Scaling down production resources
- Modifying network configuration
- Changing Service Bus tier
- Modifying AKS cluster configuration
- Deleting any production-tagged resource

**Approval:** Change Advisory Board (CAB) or equivalent  
**Timing:** Scheduled maintenance window only  
**Rollback:** May require extended effort; tested in advance

---

### Category 4: Critical Changes (High Risk)

**Examples:**
- Modifying private endpoints
- Changing Key Vault access policies
- SQL database tier changes (production)
- Network security group modifications
- Any change to authentication/identity

**Approval:** CAB + Security team sign-off  
**Timing:** Scheduled maintenance window with full team  
**Rollback:** Detailed rollback plan required; tested beforehand

---

## Quarantine Process

The quarantine process protects against accidental deletion of resources that may have hidden dependencies.

### Step 1: Identify Candidates

Resources flagged for deletion:
- Orphaned resources (unattached disks, IPs, NICs)
- Temporary/test resources
- Deprecated or unused services
- Duplicate resources

### Step 2: Create Quarantine Resource Group

```bash
az group create \
  --name "rg-nwh-quarantine-eastus" \
  --location "eastus" \
  --tags "purpose=quarantine" "created_date=2026-02-01" "delete_after=2026-02-15"
```

### Step 3: Move Resources

Move identified resources to quarantine group:

```bash
az resource move \
  --destination-group "rg-nwh-quarantine-eastus" \
  --ids "/subscriptions/<subscription-id>/resourceGroups/rg-nwh-legacy-eastus/providers/Microsoft.Compute/disks/disk-nwh-legacy-001"
```

> **Note:** Replace `<subscription-id>` with the actual subscription ID.

### Step 4: Observation Period

| Resource Type | Minimum Wait |
|---------------|--------------|
| Orphaned disk/snapshot | 7 days |
| Unused public IP | 7 days |
| Test/temp resources | 3 days |
| Any production-tagged | 14 days |

### Step 5: Final Validation

Before deletion:
- [ ] No error logs referencing resource
- [ ] No failed deployments looking for resource
- [ ] Owner confirms no longer needed
- [ ] Observation period complete

### Step 6: Delete

After validation:

```bash
az resource delete \
  --ids "/subscriptions/<subscription-id>/resourceGroups/rg-nwh-quarantine-eastus/providers/Microsoft.Compute/disks/disk-nwh-legacy-001"
```

Or delete entire quarantine group:

```bash
az group delete --name "rg-nwh-quarantine-eastus" --yes --no-wait
```

---

## Backup Requirements

### Before Any Production Change

| Resource Type | Backup Method | Verification |
|---------------|---------------|--------------|
| SQL Database | Point-in-time restore enabled | Verify backup exists |
| Storage Account | Soft delete enabled | Verify retention period |
| Key Vault | Soft delete + purge protection | Verify settings |
| VM | Snapshot OS + data disks | Verify snapshot completed |
| App Service | Deploy slots available | Verify slot can swap |
| AKS | etcd backup / namespace export | Verify backup accessible |

### Backup Checklist

- [ ] Backup taken < 24 hours before change
- [ ] Backup verified (can restore?)
- [ ] Backup retention sufficient for rollback window
- [ ] Backup location documented
- [ ] Restore procedure documented

---

## Rollback Procedures

### App Service / Function App

**Scale Change Rollback:**
```bash
az appservice plan update \
  --name "plan-nwh-portal-prod-001" \
  --resource-group "rg-nwh-prod-web-eastus" \
  --sku P2v3  # Original SKU
```

**Deployment Rollback:**
- Use deployment slots: swap staging back to production
- Or redeploy previous version from CI/CD

---

### SQL Database

**Tier Change Rollback:**
```bash
az sql db update \
  --name "sqldb-nwh-patients-prod" \
  --server "sql-nwh-main-prod-001" \
  --resource-group "rg-nwh-prod-data-eastus" \
  --service-objective S3  # Original tier
```

**Data Rollback:**
- Use point-in-time restore to create new database
- Validate data integrity
- Swap connection strings

---

### Storage Account

**Tier Change Rollback:**
- Access tier changes take up to 24 hours
- If urgent, copy data to new account with correct tier

**Deleted Blob Recovery:**
```bash
az storage blob undelete \
  --account-name "stnwhpatientdocs001" \
  --container-name "documents" \
  --name "file.pdf"
```

---

### Key Vault

**Deleted Secret Recovery:**
```bash
az keyvault secret recover \
  --vault-name "kv-nwh-prod-001" \
  --name "sql-connection-string"
```

**Deleted Key Vault Recovery:**
```bash
az keyvault recover --name "kv-nwh-prod-001"
```

> **Note:** Requires soft-delete and purge protection enabled

---

### AKS Cluster

**Node Count Rollback:**
```bash
az aks nodepool update \
  --cluster-name "aks-nwh-prod-001" \
  --resource-group "rg-nwh-prod-containers-eastus" \
  --name "nodepool1" \
  --node-count 3  # Original count
```

**Configuration Rollback:**
- Re-apply previous kubectl configurations
- Use GitOps to restore previous state

---

## Emergency Procedures

### If Something Goes Wrong

1. **Stop:** Don't make additional changes
2. **Assess:** What changed? What's the impact?
3. **Communicate:** Notify stakeholders immediately
4. **Rollback:** Execute documented rollback procedure
5. **Verify:** Confirm system is restored
6. **Document:** Record incident details

### Emergency Contacts

| Role | Contact | When to Engage |
|------|---------|----------------|
| Technical Lead | Client contact | Any production issue |
| Security Team | Client contact | Any security concern |
| Audit Lead | Consultant contact | Any audit-related issue |
| Azure Support | Microsoft | Platform issues |

### Incident Documentation Template

```markdown
## Incident Report

**Date/Time:** 
**Affected Resource:** 
**Change Attempted:** 
**What Happened:** 
**Business Impact:** 
**Rollback Performed:** 
**Resolution:** 
**Lessons Learned:** 
```

---

## Pre-Change Checklist

Use this checklist before any change:

- [ ] Change documented and approved
- [ ] Backups verified
- [ ] Rollback procedure defined
- [ ] Team notified (who needs to know?)
- [ ] Monitoring in place (how will we know if it fails?)
- [ ] Within approved maintenance window (if required)
- [ ] Tested in non-production (if applicable)

---

## Post-Change Checklist

Use this checklist after any change:

- [ ] Change completed successfully
- [ ] Functionality verified
- [ ] No errors in logs
- [ ] Performance within expected range
- [ ] Change log updated
- [ ] Stakeholders notified of completion

---

## Change Log Template

| Date | Resource | Change | Performed By | Approved By | Rollback Available |
|------|----------|--------|--------------|-------------|-------------------|
| 2026-02-01 | plan-nwh-portal-prod-001 | Scaled P2v3 → P1v3 | J. Martinez | D. Patel | Yes - scale up |
| 2026-02-02 | stnwhbackups001 | Changed tier to Cool | S. Chen | D. Patel | Yes - 24hr migration |

---

## Related Documents

- [`azure-audit-sop.md`](azure-audit-sop.md) — Full audit process
- [`engagement-checklist.md`](engagement-checklist.md) — Engagement tracking

---

*Safety is not optional. Every change is reversible until it isn't.*
