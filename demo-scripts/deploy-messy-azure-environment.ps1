#===============================================================================
# AZURE GOVERNANCE DEMO - MESSY ENVIRONMENT DEPLOYMENT SCRIPT (PowerShell)
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

$ErrorActionPreference = "Stop"

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  AZURE MESSY ENVIRONMENT DEPLOYMENT" -ForegroundColor Cyan
Write-Host "  For Governance Demo Purposes" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

#-------------------------------------------------------------------------------
# CONFIGURATION - Random suffixes to ensure unique resource names
#-------------------------------------------------------------------------------
$RANDOM_SUFFIX = -join ((97..122) + (48..57) | Get-Random -Count 6 | ForEach-Object {[char]$_})
$SQL_ADMIN_PASSWORD = "Demo@Pass" + (-join ((65..90) + (97..122) + (48..57) | Get-Random -Count 8 | ForEach-Object {[char]$_})) + "!"

# Regions - intentionally mixed (governance issue)
$REGION_1 = "eastus"
$REGION_2 = "westus2"

Write-Host "Random suffix for unique names: $RANDOM_SUFFIX" -ForegroundColor Yellow
Write-Host "Using regions: $REGION_1 and $REGION_2" -ForegroundColor Yellow
Write-Host ""

#===============================================================================
# SECTION 1: RESOURCE GROUPS (Inconsistent Naming)
#===============================================================================
Write-Host ">>> Creating Resource Groups with inconsistent naming..." -ForegroundColor Green

# camelCase naming (bad practice #1)
az group create `
    --name "appCoreRG" `
    --location $REGION_1 `
    --output none

Write-Host "  [OK] Created: appCoreRG (camelCase, no tags)" -ForegroundColor White

# kebab-case naming (bad practice #2 - different convention)
az group create `
    --name "customer-data-prod" `
    --location $REGION_2 `
    --output none

Write-Host "  [OK] Created: customer-data-prod (kebab-case, no tags)" -ForegroundColor White

# Random style with numbers (bad practice #3)
az group create `
    --name "rg1-test-misc" `
    --location $REGION_1 `
    --tags "createdby=bob" "temp=maybe" `
    --output none

Write-Host "  [OK] Created: rg1-test-misc (random style, inconsistent tags)" -ForegroundColor White
Write-Host ""

#===============================================================================
# SECTION 2: STORAGE ACCOUNT (Shared by multiple services - hidden dependency)
#===============================================================================
Write-Host ">>> Creating shared Storage Account..." -ForegroundColor Green

$STORAGE_NAME = "stgdata$RANDOM_SUFFIX"

az storage account create `
    --name $STORAGE_NAME `
    --resource-group "appCoreRG" `
    --location $REGION_1 `
    --sku "Standard_LRS" `
    --kind "StorageV2" `
    --access-tier "Hot" `
    --allow-blob-public-access false `
    --min-tls-version "TLS1_2" `
    --output none

Write-Host "  [OK] Created: $STORAGE_NAME (no tags, shared dependency)" -ForegroundColor White

# Get storage connection string for later use
$STORAGE_CONNECTION = az storage account show-connection-string `
    --name $STORAGE_NAME `
    --resource-group "appCoreRG" `
    --query connectionString -o tsv

# Create some containers with random names
az storage container create `
    --name "uploads" `
    --account-name $STORAGE_NAME `
    --output none

az storage container create `
    --name "func-data" `
    --account-name $STORAGE_NAME `
    --output none

az storage container create `
    --name "backup-old" `
    --account-name $STORAGE_NAME `
    --output none

Write-Host "  [OK] Created containers: uploads, func-data, backup-old" -ForegroundColor White
Write-Host ""

#===============================================================================
# SECTION 3: AZURE SQL DATABASE (Basic SKU)
#===============================================================================
Write-Host ">>> Creating Azure SQL Database..." -ForegroundColor Green

$SQL_SERVER_NAME = "sqlsrv$RANDOM_SUFFIX"
$SQL_DB_NAME = "CustomerDB"

# Create SQL Server (in different region - bad practice)
az sql server create `
    --name $SQL_SERVER_NAME `
    --resource-group "customer-data-prod" `
    --location $REGION_2 `
    --admin-user "sqladmin" `
    --admin-password $SQL_ADMIN_PASSWORD `
    --output none

Write-Host "  [OK] Created SQL Server: $SQL_SERVER_NAME (different region than app)" -ForegroundColor White

# Create SQL Database (Basic tier - cheapest)
az sql db create `
    --name $SQL_DB_NAME `
    --resource-group "customer-data-prod" `
    --server $SQL_SERVER_NAME `
    --edition "Basic" `
    --capacity 5 `
    --max-size "2GB" `
    --output none

Write-Host "  [OK] Created SQL Database: $SQL_DB_NAME (Basic tier, no tags)" -ForegroundColor White

# Allow Azure services (overly permissive - governance issue)
az sql server firewall-rule create `
    --name "AllowAzureServices" `
    --resource-group "customer-data-prod" `
    --server $SQL_SERVER_NAME `
    --start-ip-address "0.0.0.0" `
    --end-ip-address "0.0.0.0" `
    --output none

Write-Host "  [OK] Created firewall rule: AllowAzureServices (overly permissive)" -ForegroundColor White
Write-Host ""

#===============================================================================
# SECTION 4: APP SERVICE PLAN AND WEB APPS
#===============================================================================
Write-Host ">>> Creating App Services..." -ForegroundColor Green

# App Service Plan 1 (inconsistent naming)
# Using B1 (Basic) tier since Free tier quota is often 0 in many subscriptions
$APP_PLAN_1 = "plan-prod-apps"
az appservice plan create `
    --name $APP_PLAN_1 `
    --resource-group "appCoreRG" `
    --location $REGION_2 `
    --sku "B1" `
    --output none

Write-Host "  [OK] Created App Service Plan: $APP_PLAN_1 (Basic tier - cheapest paid)" -ForegroundColor White

# Web App 1 - Connected to Storage Account (no documentation)
$WEBAPP_1 = "webapp-main-$RANDOM_SUFFIX"
az webapp create `
    --name $WEBAPP_1 `
    --resource-group "appCoreRG" `
    --plan $APP_PLAN_1 `
    --output none

# Configure app settings (Storage connection - hidden dependency)
az webapp config appsettings set `
    --name $WEBAPP_1 `
    --resource-group "appCoreRG" `
    --settings "STORAGE_CONNECTION=$STORAGE_CONNECTION" "Environment=prod" `
    --output none

Write-Host "  [OK] Created Web App: $WEBAPP_1 (connected to storage, no tags)" -ForegroundColor White

# Web App 2 - Connected to SQL Database (in different resource group!)
$WEBAPP_2 = "CustomerPortal$RANDOM_SUFFIX"
az webapp create `
    --name $WEBAPP_2 `
    --resource-group "appCoreRG" `
    --plan $APP_PLAN_1 `
    --tags "owner=marketing" `
    --output none

# Build SQL connection string
$SQL_CONNECTION = "Server=tcp:$SQL_SERVER_NAME.database.windows.net,1433;Initial Catalog=$SQL_DB_NAME;Persist Security Info=False;User ID=sqladmin;Password=$SQL_ADMIN_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

# Configure SQL connection (cross-resource-group dependency)
az webapp config connection-string set `
    --name $WEBAPP_2 `
    --resource-group "appCoreRG" `
    --connection-string-type "SQLAzure" `
    --settings "DefaultConnection=$SQL_CONNECTION" `
    --output none

Write-Host "  [OK] Created Web App: $WEBAPP_2 (connected to SQL in different RG, random tag)" -ForegroundColor White
Write-Host ""

#===============================================================================
# SECTION 5: FUNCTION APP (Shares storage - hidden dependency)
#===============================================================================
Write-Host ">>> Creating Function App..." -ForegroundColor Green

$FUNC_NAME = "func-processor-$RANDOM_SUFFIX"

az functionapp create `
    --name $FUNC_NAME `
    --resource-group "rg1-test-misc" `
    --storage-account $STORAGE_NAME `
    --consumption-plan-location $REGION_1 `
    --runtime "dotnet" `
    --runtime-version "6" `
    --functions-version "4" `
    --os-type "Windows" `
    --output none

Write-Host "  [OK] Created Function App: $FUNC_NAME (shares storage with webapp, different RG)" -ForegroundColor White
Write-Host ""

#===============================================================================
# SECTION 6: VIRTUAL NETWORK (Undocumented subnets)
#===============================================================================
Write-Host ">>> Creating Virtual Network with undocumented subnets..." -ForegroundColor Green

$VNET_NAME = "vnet-legacy-$RANDOM_SUFFIX"

az network vnet create `
    --name $VNET_NAME `
    --resource-group "rg1-test-misc" `
    --location $REGION_1 `
    --address-prefix "10.0.0.0/16" `
    --output none

Write-Host "  [OK] Created VNet: $VNET_NAME" -ForegroundColor White

# Subnet 1 - no clear purpose documented
az network vnet subnet create `
    --name "subnet1" `
    --resource-group "rg1-test-misc" `
    --vnet-name $VNET_NAME `
    --address-prefix "10.0.1.0/24" `
    --output none

Write-Host "  [OK] Created Subnet: subnet1 (purpose unknown)" -ForegroundColor White

# Subnet 2 - no clear purpose documented
az network vnet subnet create `
    --name "backend-snet" `
    --resource-group "rg1-test-misc" `
    --vnet-name $VNET_NAME `
    --address-prefix "10.0.2.0/24" `
    --output none

Write-Host "  [OK] Created Subnet: backend-snet (purpose unknown)" -ForegroundColor White
Write-Host ""

#===============================================================================
# SECTION 7: ORPHANED RESOURCES (Waste/Risk)
#===============================================================================
Write-Host ">>> Creating orphaned resources..." -ForegroundColor Green

# Public IP - Not attached to anything (waste)
$PUBLIC_IP_NAME = "pip-old-lb-$RANDOM_SUFFIX"
az network public-ip create `
    --name $PUBLIC_IP_NAME `
    --resource-group "rg1-test-misc" `
    --location $REGION_1 `
    --sku "Basic" `
    --allocation-method "Dynamic" `
    --tags "project=migration2023" `
    --output none

Write-Host "  [OK] Created Public IP: $PUBLIC_IP_NAME (NOT attached - orphaned)" -ForegroundColor White

# Managed Disk - Not attached to anything (waste)
$DISK_NAME = "disk-backup-temp"
az disk create `
    --name $DISK_NAME `
    --resource-group "customer-data-prod" `
    --location $REGION_2 `
    --size-gb 32 `
    --sku "Standard_LRS" `
    --output none

Write-Host "  [OK] Created Managed Disk: $DISK_NAME (NOT attached - orphaned)" -ForegroundColor White
Write-Host ""

#===============================================================================
# SECTION 8: ADDITIONAL CHAOS - Random Resources
#===============================================================================
Write-Host ">>> Creating additional messy resources..." -ForegroundColor Green

# Another storage account with inconsistent naming (in wrong region)
$STORAGE_2 = "logsarchive$RANDOM_SUFFIX"
az storage account create `
    --name $STORAGE_2 `
    --resource-group "customer-data-prod" `
    --location $REGION_1 `
    --sku "Standard_LRS" `
    --kind "StorageV2" `
    --tags "dept=IT" "CostCenter=Unknown" `
    --output none

Write-Host "  [OK] Created Storage Account: $STORAGE_2 (different naming style, partial tags)" -ForegroundColor White

# Key Vault with no access policies set properly
# Note: soft-delete is now enabled by default, retention-days defaults to 90
$KV_NAME = "kv-legacy-$RANDOM_SUFFIX"
az keyvault create `
    --name $KV_NAME `
    --resource-group "appCoreRG" `
    --location $REGION_1 `
    --sku "standard" `
    --output none

Write-Host "  [OK] Created Key Vault: $KV_NAME (no tags, minimal config)" -ForegroundColor White
Write-Host ""

#===============================================================================
# SUMMARY OUTPUT
#===============================================================================
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  DEPLOYMENT COMPLETE - SUMMARY" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "RESOURCE GROUPS CREATED:" -ForegroundColor Yellow
Write-Host "  - appCoreRG (East US) - no tags"
Write-Host "  - customer-data-prod (West US 2) - no tags"
Write-Host "  - rg1-test-misc (East US) - random tags"
Write-Host ""
Write-Host "STORAGE ACCOUNTS:" -ForegroundColor Yellow
Write-Host "  - $STORAGE_NAME (appCoreRG) - SHARED by multiple services"
Write-Host "  - $STORAGE_2 (customer-data-prod) - partial tags"
Write-Host ""
Write-Host "SQL RESOURCES:" -ForegroundColor Yellow
Write-Host "  - SQL Server: $SQL_SERVER_NAME (customer-data-prod)"
Write-Host "  - SQL Database: $SQL_DB_NAME (Basic tier)"
Write-Host "  - Admin User: sqladmin"
Write-Host "  - Admin Password: $SQL_ADMIN_PASSWORD" -ForegroundColor Red
Write-Host ""
Write-Host "APP SERVICES:" -ForegroundColor Yellow
Write-Host "  - Plan: $APP_PLAN_1 (Free tier)"
Write-Host "  - Web App 1: $WEBAPP_1 -> connects to Storage"
Write-Host "  - Web App 2: $WEBAPP_2 -> connects to SQL"
Write-Host ""
Write-Host "FUNCTION APP:" -ForegroundColor Yellow
Write-Host "  - $FUNC_NAME -> shares storage with Web App 1"
Write-Host ""
Write-Host "NETWORKING:" -ForegroundColor Yellow
Write-Host "  - VNet: $VNET_NAME"
Write-Host "  - Subnets: subnet1, backend-snet (undocumented)"
Write-Host "  - Public IP: $PUBLIC_IP_NAME (ORPHANED)" -ForegroundColor Red
Write-Host ""
Write-Host "OTHER RESOURCES:" -ForegroundColor Yellow
Write-Host "  - Managed Disk: $DISK_NAME (ORPHANED)" -ForegroundColor Red
Write-Host "  - Key Vault: $KV_NAME"
Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  GOVERNANCE ISSUES CREATED:" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  1. Inconsistent resource group naming" -ForegroundColor Magenta
Write-Host "  2. Mixed Azure regions" -ForegroundColor Magenta
Write-Host "  3. Missing/inconsistent tags" -ForegroundColor Magenta
Write-Host "  4. Hidden dependencies (storage shared)" -ForegroundColor Magenta
Write-Host "  5. Cross-resource-group dependencies" -ForegroundColor Magenta
Write-Host "  6. Orphaned Public IP" -ForegroundColor Magenta
Write-Host "  7. Orphaned Managed Disk" -ForegroundColor Magenta
Write-Host "  8. No diagnostic settings" -ForegroundColor Magenta
Write-Host "  9. Undocumented VNet/subnets" -ForegroundColor Magenta
Write-Host " 10. Overly permissive SQL firewall" -ForegroundColor Magenta
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Environment ready for governance analysis!" -ForegroundColor Green
Write-Host ""
Write-Host "To clean up later, delete the resource groups:" -ForegroundColor Yellow
Write-Host "  az group delete -n appCoreRG --yes --no-wait"
Write-Host "  az group delete -n customer-data-prod --yes --no-wait"
Write-Host "  az group delete -n rg1-test-misc --yes --no-wait"
Write-Host ""

# Save summary to file
$SummaryContent = @"
# Azure Messy Environment Deployment Summary
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Random Suffix: $RANDOM_SUFFIX

## Resource Groups
- appCoreRG (East US)
- customer-data-prod (West US 2)
- rg1-test-misc (East US)

## Resources Created
- Storage Account: $STORAGE_NAME
- Storage Account: $STORAGE_2
- SQL Server: $SQL_SERVER_NAME
- SQL Database: $SQL_DB_NAME
- App Service Plan: $APP_PLAN_1
- Web App: $WEBAPP_1
- Web App: $WEBAPP_2
- Function App: $FUNC_NAME
- VNet: $VNET_NAME
- Public IP: $PUBLIC_IP_NAME (orphaned)
- Managed Disk: $DISK_NAME (orphaned)
- Key Vault: $KV_NAME

## Credentials (SAVE SECURELY)
- SQL Admin User: sqladmin
- SQL Admin Password: $SQL_ADMIN_PASSWORD
"@

$SummaryContent | Out-File -FilePath "deployment-summary-$RANDOM_SUFFIX.txt"
Write-Host "Summary saved to: deployment-summary-$RANDOM_SUFFIX.txt" -ForegroundColor Green
