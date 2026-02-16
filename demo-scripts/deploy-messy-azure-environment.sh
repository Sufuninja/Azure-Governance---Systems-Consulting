#!/bin/bash
#===============================================================================
# AZURE GOVERNANCE DEMO - MESSY ENVIRONMENT DEPLOYMENT SCRIPT
#===============================================================================
# Purpose: Creates a deliberately ungoverned Azure environment for demonstration
# Author: Azure Governance & Systems Consulting
# 
# WARNING: This script intentionally creates resources with:
#   - Inconsistent naming conventions
#   - Missing tags
#   - Hidden dependencies
#   - Orphaned resources
#   - No diagnostic settings
#
# REQUIREMENTS:
#   - Azure CLI installed and logged in (az login)
#   - Subscription selected (az account set -s <subscription-id>)
#   - Sufficient permissions to create resources
#
# COST: Uses lowest-cost SKUs (Free/Basic tiers) - estimated <$5/day
#===============================================================================

set -e

echo "=============================================="
echo "  AZURE MESSY ENVIRONMENT DEPLOYMENT"
echo "  For Governance Demo Purposes"
echo "=============================================="
echo ""

#-------------------------------------------------------------------------------
# CONFIGURATION - Random suffixes to ensure unique resource names
#-------------------------------------------------------------------------------
RANDOM_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)
SQL_ADMIN_PASSWORD="Demo@Pass$(cat /dev/urandom | tr -dc 'A-Za-z0-9' | fold -w 8 | head -n 1)!"

# Regions - intentionally mixed (governance issue)
REGION_1="eastus"
REGION_2="westus2"

echo "Random suffix for unique names: $RANDOM_SUFFIX"
echo "Using regions: $REGION_1 and $REGION_2"
echo ""

#===============================================================================
# SECTION 1: RESOURCE GROUPS (Inconsistent Naming)
#===============================================================================
echo ">>> Creating Resource Groups with inconsistent naming..."

# camelCase naming (bad practice #1)
az group create \
    --name "appCoreRG" \
    --location "$REGION_1" \
    --output none
echo "  ✓ Created: appCoreRG (camelCase, no tags)"

# kebab-case naming (bad practice #2 - different convention)
az group create \
    --name "customer-data-prod" \
    --location "$REGION_2" \
    --output none
echo "  ✓ Created: customer-data-prod (kebab-case, no tags)"

# Random style with numbers (bad practice #3)
az group create \
    --name "rg1-test-misc" \
    --location "$REGION_1" \
    --tags "createdby=bob" "temp=maybe" \
    --output none
echo "  ✓ Created: rg1-test-misc (random style, inconsistent tags)"

echo ""

#===============================================================================
# SECTION 2: STORAGE ACCOUNT (Shared by multiple services - hidden dependency)
#===============================================================================
echo ">>> Creating shared Storage Account..."

STORAGE_NAME="stgdata${RANDOM_SUFFIX}"

az storage account create \
    --name "$STORAGE_NAME" \
    --resource-group "appCoreRG" \
    --location "$REGION_1" \
    --sku "Standard_LRS" \
    --kind "StorageV2" \
    --access-tier "Hot" \
    --allow-blob-public-access false \
    --min-tls-version "TLS1_2" \
    --output none

echo "  ✓ Created: $STORAGE_NAME (no tags, shared dependency)"

# Get storage connection string for later use
STORAGE_CONNECTION=$(az storage account show-connection-string \
    --name "$STORAGE_NAME" \
    --resource-group "appCoreRG" \
    --query connectionString -o tsv)

# Create some containers with random names
az storage container create \
    --name "uploads" \
    --account-name "$STORAGE_NAME" \
    --output none

az storage container create \
    --name "func-data" \
    --account-name "$STORAGE_NAME" \
    --output none

az storage container create \
    --name "backup-old" \
    --account-name "$STORAGE_NAME" \
    --output none

echo "  ✓ Created containers: uploads, func-data, backup-old"
echo ""

#===============================================================================
# SECTION 3: AZURE SQL DATABASE (Basic SKU)
#===============================================================================
echo ">>> Creating Azure SQL Database..."

SQL_SERVER_NAME="sqlsrv${RANDOM_SUFFIX}"
SQL_DB_NAME="CustomerDB"

# Create SQL Server (in different region - bad practice)
az sql server create \
    --name "$SQL_SERVER_NAME" \
    --resource-group "customer-data-prod" \
    --location "$REGION_2" \
    --admin-user "sqladmin" \
    --admin-password "$SQL_ADMIN_PASSWORD" \
    --output none

echo "  ✓ Created SQL Server: $SQL_SERVER_NAME (different region than app)"

# Create SQL Database (Basic tier - cheapest)
az sql db create \
    --name "$SQL_DB_NAME" \
    --resource-group "customer-data-prod" \
    --server "$SQL_SERVER_NAME" \
    --edition "Basic" \
    --capacity 5 \
    --max-size "2GB" \
    --output none

echo "  ✓ Created SQL Database: $SQL_DB_NAME (Basic tier, no tags)"

# Allow Azure services (overly permissive - governance issue)
az sql server firewall-rule create \
    --name "AllowAzureServices" \
    --resource-group "customer-data-prod" \
    --server "$SQL_SERVER_NAME" \
    --start-ip-address "0.0.0.0" \
    --end-ip-address "0.0.0.0" \
    --output none

echo "  ✓ Created firewall rule: AllowAzureServices (overly permissive)"
echo ""

#===============================================================================
# SECTION 4: APP SERVICE PLAN AND WEB APPS
#===============================================================================
echo ">>> Creating App Services..."

# App Service Plan 1 (inconsistent naming)
# Using B1 (Basic) tier since Free tier quota is often 0 in many subscriptions
APP_PLAN_1="plan-prod-apps"
az appservice plan create \
    --name "$APP_PLAN_1" \
    --resource-group "appCoreRG" \
    --location "$REGION_2" \
    --sku "B1" \
    --output none

echo "  ✓ Created App Service Plan: $APP_PLAN_1 (Basic tier - cheapest paid)"

# Web App 1 - Connected to Storage Account (no documentation)
WEBAPP_1="webapp-main-${RANDOM_SUFFIX}"
az webapp create \
    --name "$WEBAPP_1" \
    --resource-group "appCoreRG" \
    --plan "$APP_PLAN_1" \
    --output none

# Configure app settings (Storage connection - hidden dependency)
az webapp config appsettings set \
    --name "$WEBAPP_1" \
    --resource-group "appCoreRG" \
    --settings "STORAGE_CONNECTION=$STORAGE_CONNECTION" "Environment=prod" \
    --output none

echo "  ✓ Created Web App: $WEBAPP_1 (connected to storage, no tags)"

# Web App 2 - Connected to SQL Database (in different resource group!)
WEBAPP_2="CustomerPortal${RANDOM_SUFFIX}"
az webapp create \
    --name "$WEBAPP_2" \
    --resource-group "appCoreRG" \
    --plan "$APP_PLAN_1" \
    --tags "owner=marketing" \
    --output none

# Get SQL connection string
SQL_CONNECTION="Server=tcp:${SQL_SERVER_NAME}.database.windows.net,1433;Initial Catalog=${SQL_DB_NAME};Persist Security Info=False;User ID=sqladmin;Password=${SQL_ADMIN_PASSWORD};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

# Configure SQL connection (cross-resource-group dependency)
az webapp config connection-string set \
    --name "$WEBAPP_2" \
    --resource-group "appCoreRG" \
    --connection-string-type "SQLAzure" \
    --settings "DefaultConnection=$SQL_CONNECTION" \
    --output none

echo "  ✓ Created Web App: $WEBAPP_2 (connected to SQL in different RG, random tag)"
echo ""

#===============================================================================
# SECTION 5: FUNCTION APP (Shares storage - hidden dependency)
#===============================================================================
echo ">>> Creating Function App..."

# App Service Plan for Functions (Consumption would be free, but using separate plan for demo)
FUNC_NAME="func-processor-${RANDOM_SUFFIX}"

az functionapp create \
    --name "$FUNC_NAME" \
    --resource-group "rg1-test-misc" \
    --storage-account "$STORAGE_NAME" \
    --consumption-plan-location "$REGION_1" \
    --runtime "dotnet" \
    --runtime-version "6" \
    --functions-version "4" \
    --os-type "Windows" \
    --output none

echo "  ✓ Created Function App: $FUNC_NAME (shares storage with webapp, different RG)"
echo ""

#===============================================================================
# SECTION 6: VIRTUAL NETWORK (Undocumented subnets)
#===============================================================================
echo ">>> Creating Virtual Network with undocumented subnets..."

VNET_NAME="vnet-legacy-${RANDOM_SUFFIX}"

az network vnet create \
    --name "$VNET_NAME" \
    --resource-group "rg1-test-misc" \
    --location "$REGION_1" \
    --address-prefix "10.0.0.0/16" \
    --output none

echo "  ✓ Created VNet: $VNET_NAME"

# Subnet 1 - no clear purpose documented
az network vnet subnet create \
    --name "subnet1" \
    --resource-group "rg1-test-misc" \
    --vnet-name "$VNET_NAME" \
    --address-prefix "10.0.1.0/24" \
    --output none

echo "  ✓ Created Subnet: subnet1 (purpose unknown)"

# Subnet 2 - no clear purpose documented
az network vnet subnet create \
    --name "backend-snet" \
    --resource-group "rg1-test-misc" \
    --vnet-name "$VNET_NAME" \
    --address-prefix "10.0.2.0/24" \
    --output none

echo "  ✓ Created Subnet: backend-snet (purpose unknown)"
echo ""

#===============================================================================
# SECTION 7: ORPHANED RESOURCES (Waste/Risk)
#===============================================================================
echo ">>> Creating orphaned resources..."

# Public IP - Not attached to anything (waste)
PUBLIC_IP_NAME="pip-old-lb-${RANDOM_SUFFIX}"
az network public-ip create \
    --name "$PUBLIC_IP_NAME" \
    --resource-group "rg1-test-misc" \
    --location "$REGION_1" \
    --sku "Basic" \
    --allocation-method "Dynamic" \
    --tags "project=migration2023" \
    --output none

echo "  ✓ Created Public IP: $PUBLIC_IP_NAME (NOT attached - orphaned)"

# Managed Disk - Not attached to anything (waste)
DISK_NAME="disk-backup-temp"
az disk create \
    --name "$DISK_NAME" \
    --resource-group "customer-data-prod" \
    --location "$REGION_2" \
    --size-gb 32 \
    --sku "Standard_LRS" \
    --output none

echo "  ✓ Created Managed Disk: $DISK_NAME (NOT attached - orphaned)"
echo ""

#===============================================================================
# SECTION 8: ADDITIONAL CHAOS - Random Resources
#===============================================================================
echo ">>> Creating additional messy resources..."

# Another storage account with inconsistent naming (in wrong region)
STORAGE_2="logsarchive${RANDOM_SUFFIX}"
az storage account create \
    --name "$STORAGE_2" \
    --resource-group "customer-data-prod" \
    --location "$REGION_1" \
    --sku "Standard_LRS" \
    --kind "StorageV2" \
    --tags "dept=IT" "CostCenter=Unknown" \
    --output none

echo "  ✓ Created Storage Account: $STORAGE_2 (different naming style, partial tags)"

# Key Vault with no access policies set properly
# Note: soft-delete is now enabled by default, retention-days defaults to 90
KV_NAME="kv-legacy-${RANDOM_SUFFIX}"
az keyvault create \
    --name "$KV_NAME" \
    --resource-group "appCoreRG" \
    --location "$REGION_1" \
    --sku "standard" \
    --output none

echo "  ✓ Created Key Vault: $KV_NAME (no tags, minimal config)"
echo ""

#===============================================================================
# SUMMARY OUTPUT
#===============================================================================
echo "=============================================="
echo "  DEPLOYMENT COMPLETE - SUMMARY"
echo "=============================================="
echo ""
echo "RESOURCE GROUPS CREATED:"
echo "  • appCoreRG (East US) - no tags"
echo "  • customer-data-prod (West US 2) - no tags"
echo "  • rg1-test-misc (East US) - random tags"
echo ""
echo "STORAGE ACCOUNTS:"
echo "  • $STORAGE_NAME (appCoreRG) - SHARED by multiple services"
echo "  • $STORAGE_2 (customer-data-prod) - partial tags"
echo ""
echo "SQL RESOURCES:"
echo "  • SQL Server: $SQL_SERVER_NAME (customer-data-prod)"
echo "  • SQL Database: $SQL_DB_NAME (Basic tier)"
echo "  • Admin User: sqladmin"
echo "  • Admin Password: $SQL_ADMIN_PASSWORD"
echo ""
echo "APP SERVICES:"
echo "  • Plan: $APP_PLAN_1 (Free tier)"
echo "  • Web App 1: $WEBAPP_1 → connects to Storage"
echo "  • Web App 2: $WEBAPP_2 → connects to SQL"
echo ""
echo "FUNCTION APP:"
echo "  • $FUNC_NAME → shares storage with Web App 1"
echo ""
echo "NETWORKING:"
echo "  • VNet: $VNET_NAME"
echo "  • Subnets: subnet1, backend-snet (undocumented)"
echo "  • Public IP: $PUBLIC_IP_NAME (ORPHANED)"
echo ""
echo "OTHER RESOURCES:"
echo "  • Managed Disk: $DISK_NAME (ORPHANED)"
echo "  • Key Vault: $KV_NAME"
echo ""
echo "=============================================="
echo "  GOVERNANCE ISSUES CREATED:"
echo "=============================================="
echo "  1. Inconsistent resource group naming"
echo "  2. Mixed Azure regions"
echo "  3. Missing/inconsistent tags"
echo "  4. Hidden dependencies (storage shared)"
echo "  5. Cross-resource-group dependencies"
echo "  6. Orphaned Public IP"
echo "  7. Orphaned Managed Disk"
echo "  8. No diagnostic settings"
echo "  9. Undocumented VNet/subnets"
echo " 10. Overly permissive SQL firewall"
echo "=============================================="
echo ""
echo "Environment ready for governance analysis!"
echo ""
echo "To clean up later, delete the resource groups:"
echo "  az group delete -n appCoreRG --yes --no-wait"
echo "  az group delete -n customer-data-prod --yes --no-wait"
echo "  az group delete -n rg1-test-misc --yes --no-wait"
