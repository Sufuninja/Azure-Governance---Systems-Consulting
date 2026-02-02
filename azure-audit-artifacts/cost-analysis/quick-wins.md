# Cost Optimization Quick Wins

**Client:** Northwind Health  
**Prepared By:** Azure Governance Consulting

---

## Overview

This document identifies 10 cost optimization opportunities, prioritized by effort level and potential savings. Quick wins are low-risk changes that can be implemented within days, while medium-term items require more planning and coordination.

---

## Quick Wins Matrix

| # | Opportunity | Est. Monthly Savings | Effort | Risk |
|---|-------------|---------------------|--------|------|
| 1 | Delete orphaned resources | $85 | Very Low | Very Low |
| 2 | Remove temporary load test resources | $490 | Very Low | Low |
| 3 | Reduce Log Analytics retention | $280 | Low | Low |
| 4 | Downgrade Production App Service Plan | $650 | Low | Medium |
| 5 | Right-size AKS cluster | $890 | Medium | Medium |
| 6 | Migrate backup storage to Cool tier | $420 | Low | Low |
| 7 | Implement dev environment auto-shutdown | $1,100 | Medium | Low |
| 8 | Downgrade Service Bus to Standard tier | $700 | Medium | Medium |
| 9 | Reserved Instances for SQL | $600 | Low | Low |
| 10 | Optimize App Insights sampling | $400 | Medium | Low |

**Total Potential Savings: $4,200–$5,800/month**

---

## Detailed Recommendations

### 1. Delete Orphaned Resources

**Savings:** $85/month  
**Effort:** Very Low (< 1 hour)  
**Risk:** Very Low

**Current State:**
- 1 orphaned managed disk: `disk-nwh-legacy-001`
- 1 orphaned public IP: `pip-nwh-legacy-001`
- 1 orphaned NIC: `nic-nwh-legacy-001`
- 1 old snapshot: `snap-nwh-backup-20250115`

**Action:**
1. Verify resources are not in use
2. Move to quarantine resource group for 7 days
3. Delete if no issues arise

**Validation Query (Azure Resource Graph):**
```kusto
resources
| where type =~ "Microsoft.Compute/disks"
| where properties.diskState == "Unattached"
```

---

### 2. Remove Temporary Load Test Resources

**Savings:** $490/month  
**Effort:** Very Low (< 1 hour)  
**Risk:** Low

**Current State:**
- Resource Group: `rg-nwh-test-temp-eastus`
- Contains: `app-nwh-loadtest-001`, `plan-nwh-loadtest-001`
- Tagged with `lifecycle=temporary`
- Load testing completed over 30 days ago

**Action:**
1. Confirm with owner (a.wong@northwindhealth.fake) that testing is complete
2. Export any needed test results
3. Delete resource group

---

### 3. Reduce Log Analytics Retention

**Savings:** $280/month  
**Effort:** Low (< 2 hours)  
**Risk:** Low

**Current State:**
- Workspace: `log-nwh-prod-001`
- Retention: 90 days (default)
- Actual requirement: 30 days operational

**Action:**
1. Reduce retention to 30 days
2. Set up export to Storage Account for long-term archival if needed
3. Use Archive tier for compliance data

**Implementation:**
```powershell
Set-AzOperationalInsightsWorkspace `
  -ResourceGroupName "rg-nwh-prod-monitoring-eastus" `
  -Name "log-nwh-prod-001" `
  -RetentionInDays 30
```

---

### 4. Downgrade Production App Service Plan

**Savings:** $650/month  
**Effort:** Low (1-2 hours)  
**Risk:** Medium (requires testing)

**Current State:**
- Plan: `plan-nwh-portal-prod-001`
- SKU: P2v3 (4 vCPU, 16 GB RAM)
- Cost: ~$1,500/month
- Avg CPU: 25%, Avg Memory: 30%

**Recommendation:**
- Downgrade to P1v3 (2 vCPU, 8 GB RAM): ~$850/month
- Alternatively, implement autoscaling rules

**Action:**
1. Review 30-day performance metrics
2. Test with P1v3 in staging environment
3. Schedule maintenance window
4. Scale down during low-traffic period
5. Monitor for 48 hours post-change

---

### 5. Right-Size AKS Cluster

**Savings:** $890/month  
**Effort:** Medium (4-8 hours)  
**Risk:** Medium (requires coordination)

**Current State:**
- Cluster: `aks-nwh-prod-001`
- Nodes: 3× Standard_D4s_v3
- Utilization: ~15% cluster capacity
- Cost: ~$2,680/month

**Recommendation:**
- Reduce to 2 nodes: ~$1,790/month
- Enable cluster autoscaler (min: 2, max: 4)

**Action:**
1. Review pod resource requests/limits
2. Analyze peak utilization patterns
3. Enable cluster autoscaler
4. Set node pool to 2 nodes
5. Test failover scenarios

---

### 6. Migrate Backup Storage to Cool Tier

**Savings:** $420/month  
**Effort:** Low (2-4 hours)  
**Risk:** Low

**Current State:**
- Account: `stnwhbackups001`
- Tier: Hot (all containers)
- Access pattern: Monthly or less
- Cost: ~$650/month

**Recommendation:**
- Move to Cool tier: ~$230/month
- Consider Archive for data > 6 months old

**Action:**
1. Analyze blob access patterns via Storage Analytics
2. Create lifecycle management policy
3. Set default tier to Cool for new uploads
4. Migrate existing blobs to Cool tier

**Lifecycle Policy Example:**
```json
{
  "rules": [
    {
      "name": "moveToCool",
      "enabled": true,
      "type": "Lifecycle",
      "definition": {
        "filters": { "blobTypes": ["blockBlob"] },
        "actions": {
          "baseBlob": {
            "tierToCool": { "daysAfterModificationGreaterThan": 30 },
            "tierToArchive": { "daysAfterModificationGreaterThan": 180 }
          }
        }
      }
    }
  ]
}
```

---

### 7. Implement Dev Environment Auto-Shutdown

**Savings:** $1,100/month  
**Effort:** Medium (4-6 hours)  
**Risk:** Low

**Current State:**
- Dev resources run 24/7 (168 hrs/week)
- Actual usage: ~45 hrs/week (business hours)
- Waste: 73% of runtime

**Recommendation:**
- Auto-shutdown at 7 PM, auto-start at 7 AM (M-F)
- 65% cost reduction on dev App Service Plans and SQL

**Action:**
1. Document required uptime hours with development team
2. Implement Azure Automation runbook for App Service stop/start
3. Configure SQL auto-pause (if using Serverless tier) or schedule scale-down
4. Test restore process

---

### 8. Downgrade Service Bus to Standard Tier

**Savings:** $700/month  
**Effort:** Medium (4-8 hours)  
**Risk:** Medium (requires testing)

**Current State:**
- Namespace: `sb-nwh-prod-001`
- Tier: Premium (1 messaging unit)
- Volume: ~500 messages/day
- Cost: ~$1,890/month

**Premium Features in Use:**
- Private endpoint ✅ (required for compliance)
- Message size > 256 KB ❌ (not used)
- Geo-DR ❌ (not used)

**Issue:** Private endpoints require Premium tier. Evaluate if network isolation is mandatory.

**Alternative:** If Premium is required, consider reducing messaging units during off-peak hours.

---

### 9. Reserved Instances for SQL Databases

**Savings:** $600/month  
**Effort:** Low (1-2 hours)  
**Risk:** Low (financial commitment)

**Current State:**
- SQL spend: ~$4,850/month
- All databases on Pay-As-You-Go pricing
- Databases are stable, long-term workloads

**Recommendation:**
- Purchase 1-year Reserved Capacity
- Expected discount: ~40% on vCore costs
- Savings: ~$600/month (~$7,200/year)

**Action:**
1. Confirm SQL database stability (no planned decomission)
2. Calculate exact RI requirements
3. Purchase via Azure Portal or EA agreement
4. Apply to existing databases

---

### 10. Optimize App Insights Sampling

**Savings:** $400/month  
**Effort:** Medium (4-6 hours)  
**Risk:** Low

**Current State:**
- Workspace: `ai-nwh-prod-001`
- Ingestion: ~15 GB/day
- Cost: ~$680/month
- Sampling: Disabled (capturing 100%)

**Recommendation:**
- Enable adaptive sampling (capture 25-50%)
- Filter out verbose dependency calls
- Reduce log levels in code

**Action:**
1. Review telemetry data to identify high-volume, low-value events
2. Configure sampling in Application Insights SDK
3. Add filtering for common dependency calls
4. Adjust log levels in application code

**SDK Configuration Example:**
```csharp
services.AddApplicationInsightsTelemetry(options => {
    options.EnableAdaptiveSampling = true;
});
```

---

## Implementation Priority

### This Week
- [ ] #1: Delete orphaned resources
- [ ] #2: Remove load test resources
- [ ] #3: Reduce Log Analytics retention

### This Month
- [ ] #4: Downgrade App Service Plan
- [ ] #6: Migrate backup storage to Cool
- [ ] #9: Evaluate Reserved Instances

### This Quarter
- [ ] #5: Right-size AKS
- [ ] #7: Dev auto-shutdown
- [ ] #8: Evaluate Service Bus tier
- [ ] #10: App Insights optimization

---

## Tracking

Create an Azure Advisor recommendation dashboard to track:
- Cost recommendations identified
- Recommendations implemented
- Estimated vs. actual savings
- New recommendations surfaced

---

*All changes should follow the change control process documented in [`../sop/change-control-and-safety.md`](../sop/change-control-and-safety.md).*
