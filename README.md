# Azure Audit Artifacts

> **⚠️ DISCLAIMER:** All data in this folder is **fictional and anonymized**. Company names, tenant IDs, subscription IDs, resource names, costs, and any identifying information are fabricated for demonstration purposes only. This portfolio is safe to share publicly and contains no real client data.

## Overview

This folder contains sample deliverables from an Azure Governance & Systems Audit engagement. These artifacts demonstrate the depth, structure, and quality of work we provide to clients seeking clarity on their Azure environments.

**Fictional Client:** Northwind Health  
**Engagement Type:** Azure Environment Audit & Optimization Assessment  
**Scope:** Production, Development, and Shared Services subscriptions

---

## What's Included

| Folder | Artifact | Purpose |
|--------|----------|---------|
| `/sample-inventory/` | `resources.csv`, `resources.json` | Complete Azure resource inventory with metadata |
| `/sample-inventory/` | `tags-and-owners.csv` | Tag taxonomy and ownership matrix |
| `/naming-conventions/` | `naming-standard.md` | Recommended naming convention standard |
| `/naming-conventions/` | `examples.md` | Good vs bad naming examples |
| `/cost-analysis/` | `cost-analysis-summary.md` | Executive summary of cost findings |
| `/cost-analysis/` | `cost-breakdown-by-service.csv` | Monthly cost by Azure service type |
| `/cost-analysis/` | `quick-wins.md` | Immediate cost optimization opportunities |
| `/dependency-diagrams/` | `dependency-map.mmd`, `dependency-map.md` | Visual architecture and data flow diagram |
| `/sop/` | `azure-audit-sop.md` | Standard Operating Procedure for audits |
| `/sop/` | `change-control-and-safety.md` | Guardrails and rollback procedures |
| `/sop/` | `engagement-checklist.md` | Reusable client engagement checklist |

---

## Artifact Descriptions

### 1. Sample Azure Resource Inventory
A realistic inventory of ~45 Azure resources across multiple subscriptions. Includes resource groups, naming patterns, regions, environments, owners, cost centers, criticality ratings, and applied tags. Available in both CSV and JSON formats for flexibility.

### 2. Naming Conventions Documentation
A comprehensive naming standard covering all common Azure resource types. Includes patterns for environments, regions, and applications—plus explicit rules for length constraints, forbidden characters, and tagging requirements.

### 3. Cost Analysis
Executive-level cost summary with service-by-service breakdown. Identifies top cost drivers, risks, and 10 actionable quick wins with estimated savings ranges. Covers common issues like overprovisioned compute, idle resources, and storage tier misconfigurations.

### 4. Dependency Diagram
A Mermaid-based architecture diagram showing how frontend applications connect to APIs, databases, storage, messaging, and security services. Includes private endpoint topology and monitoring relationships.

### 5. Standard Operating Procedures (SOP)
Complete audit methodology from intake through handoff. Includes safety protocols, change control procedures, and a reusable engagement checklist for consistent delivery.

---

## How to Use This Portfolio

1. **Prospects:** Review these artifacts to understand what a typical engagement delivers
2. **Clients:** Use as templates for your own documentation standards
3. **Internal:** Reference for training and quality assurance

---

## Key Principles Demonstrated

- **Read-Only First:** Discovery phase uses only Reader access—no changes until approved
- **Documentation-Driven:** Every finding is documented before action is taken
- **Staged Execution:** Changes follow a quarantine → validate → promote pattern
- **Traceability:** All resources linked to owners, cost centers, and business applications

---

## Questions?

These samples represent a typical mid-sized Azure audit engagement. Actual deliverables are customized based on environment complexity, client priorities, and scope.

---

*Last Updated: February 2026*
