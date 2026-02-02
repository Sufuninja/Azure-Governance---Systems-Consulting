# Executive Summary

**Azure Environment Audit — Northwind Health**

---

## Engagement Overview

This document summarizes the findings from a comprehensive audit of Northwind Health's Azure environment, conducted in January–February 2026. The assessment covered three subscriptions (Production, Development, and Shared Services) containing approximately 45 resources across compute, data, networking, security, and monitoring services.

The audit focused on four key areas:
- Resource organization and governance
- Cost efficiency and optimization opportunities
- Architecture dependencies and risk posture
- Operational maturity and change management

---

## Key Findings

### Environment Complexity

The Northwind Health Azure environment supports a patient-facing portal, internal APIs, notification services, and a container-based microservices platform. The architecture follows a reasonable tiered design with web, API, and data layers separated by subnets and secured via private endpoints.

**Strengths identified:**
- Private endpoints in place for SQL, Storage, and Key Vault
- Managed identities used for application authentication
- Application Insights configured for observability

**Areas requiring attention:**
- Inconsistent naming conventions across resources
- Incomplete tagging, particularly for legacy resources
- Five orphaned resources with no documented owner
- Dev environment resources running 24/7 unnecessarily

### Governance Gaps

The environment lacks a formal naming standard, resulting in inconsistent resource names that complicate management and cost attribution. Several resources are missing required tags (owner, cost center, data classification), making it difficult to track accountability and compliance.

A recommended naming standard and tag governance framework is provided in the accompanying documentation.

### Cost Optimization Opportunities

Current monthly Azure spend is approximately **$18,450**. The audit identified optimization opportunities totaling **$4,200–$5,800 per month** (23–31% reduction), with potential annual savings of **$50,400–$69,600**.

| Category | Monthly Savings | Effort |
|----------|-----------------|--------|
| Delete orphaned/temporary resources | $575 | Low |
| Right-size overprovisioned compute | $1,540 | Medium |
| Optimize storage tiers | $420 | Low |
| Implement dev auto-shutdown | $1,100 | Medium |
| Service tier adjustments | $1,300 | Medium |
| Reserved Instance pricing | $600 | Low |

Detailed recommendations with implementation steps are provided in the Cost Analysis document.

### Risk Assessment

| Risk | Severity | Recommendation |
|------|----------|----------------|
| Legacy VM with unknown owner | Medium | Identify owner or decommission |
| Overprovisioned production compute | Low | Right-size based on usage data |
| Service Bus Premium underutilized | Low | Evaluate Standard tier feasibility |
| 90-day log retention (default) | Low | Reduce to 30 days, archive if needed |
| Key Vault redundancy | Low | Consolidate to single vault |

No critical security vulnerabilities were identified during this audit. The private endpoint architecture provides strong network isolation for sensitive data services.

---

## Recommended Next Steps

### Immediate (This Week)

1. **Delete orphaned resources** — Validate and remove the identified orphaned disk, public IP, NIC, and old snapshot after confirmation they are unused.

2. **Remove temporary test resources** — Delete the load testing resource group (`rg-nwh-test-temp-eastus`) following owner confirmation.

3. **Identify legacy resource owners** — Assign ownership to `vm-nwh-legacy-001` and associated resources, or begin decommission planning.

### Short-Term (This Month)

4. **Adopt naming standard** — Implement the provided naming convention for all new resources. Plan remediation for existing resources during next maintenance window.

5. **Enforce tag requirements** — Deploy Azure Policy to require mandatory tags on resource creation.

6. **Right-size production compute** — Downgrade `plan-nwh-portal-prod-001` from P2v3 to P1v3 based on utilization data showing 25% average CPU.

7. **Optimize storage tiers** — Migrate `stnwhbackups001` from Hot to Cool tier.

### Medium-Term (This Quarter)

8. **Implement dev auto-shutdown** — Configure automation to stop development resources outside business hours.

9. **Evaluate Reserved Instances** — Analyze stable workloads for 1-year reserved capacity pricing on SQL databases.

10. **Review Service Bus tier** — Evaluate whether Standard tier meets requirements given current message volume (~500/day).

---

## Summary

The Northwind Health Azure environment is fundamentally sound with appropriate security controls in place. The primary opportunities lie in governance improvements (naming, tagging) and cost optimization through right-sizing and tier adjustments.

Implementing the recommendations in this report will reduce monthly spend by 23–31%, improve operational clarity through consistent naming and tagging, and reduce risk by addressing orphaned and undocumented resources.

We recommend scheduling a follow-up session to prioritize the implementation roadmap and address any questions regarding specific recommendations.

---

*Prepared by Azure Governance Consulting — February 2026*
