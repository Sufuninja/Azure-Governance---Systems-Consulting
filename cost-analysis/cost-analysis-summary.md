# Cost Analysis Summary

**Client:** Northwind Health  
**Assessment Period:** January 2026  
**Prepared By:** Azure Governance Consulting  
**Status:** Draft for Review

---

## Executive Summary

This cost analysis examines the Northwind Health Azure environment across three subscriptions: Production, Development, and Shared Services. Total monthly spend is approximately **$18,450**, with identified optimization opportunities of **$4,200–$5,800/month** (23–31% reduction).

### Key Findings

| Metric | Value |
|--------|-------|
| Total Monthly Spend | $18,450 |
| Identified Savings | $4,200–$5,800/month |
| Potential Annual Savings | $50,400–$69,600 |
| Quick Wins (< 1 week effort) | 6 opportunities |
| Medium-Term Optimizations | 4 opportunities |

---

## Assumptions

- Cost data extracted from Azure Cost Management for January 2026
- Prices reflect Pay-As-You-Go rates (no Enterprise Agreement discounts applied)
- Currency: USD
- Region: East US pricing
- Reserved Instance and Savings Plan opportunities not yet evaluated
- Actual savings may vary based on usage patterns

---

## Top Cost Drivers

### By Service Type

| Rank | Service | Monthly Cost | % of Total |
|------|---------|--------------|------------|
| 1 | Azure SQL Database | $4,850 | 26.3% |
| 2 | App Service Plans | $3,920 | 21.2% |
| 3 | AKS (Kubernetes) | $2,680 | 14.5% |
| 4 | Storage Accounts | $2,150 | 11.7% |
| 5 | Service Bus | $1,890 | 10.2% |
| 6 | App Insights / Log Analytics | $1,420 | 7.7% |
| 7 | Virtual Machines (Legacy) | $890 | 4.8% |
| 8 | Other (VNet, DNS, IPs, etc.) | $650 | 3.5% |

### By Environment

| Environment | Monthly Cost | % of Total |
|-------------|--------------|------------|
| Production | $14,200 | 77.0% |
| Development | $3,450 | 18.7% |
| Shared Services | $800 | 4.3% |

---

## Risk Assessment

### High Priority Issues

1. **Overprovisioned Production App Service Plan**  
   - Current: P2v3 (4 cores, 16 GB)  
   - Utilization: ~25% CPU, ~30% memory average  
   - Risk: Paying for capacity not being used  
   - Recommendation: Downgrade to P1v3 or evaluate autoscaling

2. **AKS Cluster Underutilization**  
   - Current: 3 nodes running 24/7  
   - Utilization: ~15% cluster capacity  
   - Risk: Significant waste on idle compute  
   - Recommendation: Scale to 2 nodes or implement cluster autoscaler

3. **Service Bus Premium Tier**  
   - Current: Premium tier with 1 messaging unit  
   - Usage: ~500 messages/day  
   - Risk: Premium tier unnecessary for current volume  
   - Recommendation: Downgrade to Standard tier

### Medium Priority Issues

4. **Dev Environment Running 24/7**  
   - All dev resources run continuously  
   - Actual usage: Business hours only (~45 hrs/week)  
   - Recommendation: Implement auto-shutdown or reduce tier

5. **Storage Tier Mismatch**  
   - Backup storage using Hot tier  
   - Access pattern: Monthly or less  
   - Recommendation: Migrate to Cool or Archive tier

6. **Log Analytics Retention**  
   - Current: 90 days (default)  
   - Requirement: 30 days operational + archive  
   - Recommendation: Reduce retention, export to cheaper storage

### Low Priority Issues

7. **Orphaned Resources**  
   - 5 orphaned resources identified (disks, IPs, NICs)  
   - Combined cost: ~$85/month  
   - Recommendation: Clean up after validation

8. **Redundant Key Vault**  
   - Two Key Vaults in production  
   - Second vault appears unused  
   - Recommendation: Validate and consolidate

---

## Cost by Subscription

### NWH-Production ($14,200/month)

| Resource Type | Cost | Notes |
|---------------|------|-------|
| SQL Databases | $4,200 | S3 and S2 tiers |
| App Service Plans | $2,650 | P2v3 overprovisioned |
| AKS | $2,680 | Low utilization |
| Storage | $1,850 | Hot tier for backups |
| Service Bus | $1,890 | Premium unnecessary |
| App Insights | $680 | High ingestion |
| Other | $250 | Network, DNS |

### NWH-Development ($3,450/month)

| Resource Type | Cost | Notes |
|---------------|------|-------|
| App Service Plans | $1,270 | B2 tier, runs 24/7 |
| SQL Databases | $650 | S2 tier |
| Storage | $300 | Dev data |
| App Insights | $340 | Excessive logging |
| Load Test Resources | $490 | Should be deleted |
| Other | $400 | Various |

### NWH-Shared-Services ($800/month)

| Resource Type | Cost | Notes |
|---------------|------|-------|
| Private DNS Zones | $180 | Required |
| Managed Identities | $0 | No cost |
| Log Analytics | $400 | Shared workspace |
| Other | $220 | Network peering |

---

## Recommendations Summary

### Immediate Actions (This Week)

1. Delete orphaned resources ($85/month savings)
2. Delete temporary load test resources ($490/month savings)
3. Reduce Log Analytics retention to 30 days ($280/month savings)

### Short-Term Actions (This Month)

4. Downgrade Production App Service Plan ($650/month savings)
5. Right-size AKS cluster ($890/month savings)
6. Migrate backup storage to Cool tier ($420/month savings)

### Medium-Term Actions (This Quarter)

7. Implement dev environment auto-shutdown ($1,100/month savings)
8. Downgrade Service Bus to Standard tier ($700/month savings)
9. Evaluate Reserved Instance pricing for SQL ($600/month savings)
10. Consolidate monitoring and reduce App Insights sampling ($400/month savings)

---

## Next Steps

1. Review this analysis with technical stakeholders
2. Validate orphaned resources before deletion
3. Schedule change windows for production changes
4. Implement quick wins first to demonstrate value
5. Create monitoring dashboards for ongoing cost tracking

---

## Appendices

- [`cost-breakdown-by-service.csv`](cost-breakdown-by-service.csv) — Detailed service cost breakdown
- [`quick-wins.md`](quick-wins.md) — Prioritized quick win opportunities

---

*This analysis is based on a point-in-time snapshot. Costs may vary with usage. All recommendations should be validated in non-production environments first.*
