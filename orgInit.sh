#!/bin/bash
# Exit on error!
set -euxo pipefail
#create scratch org
sfdx force:org:create -f config/project-scratch-def.json -s -a FSCDEMO username=admin.bolt3@fsc.demo.org --durationdays 28

#package installs of the main FSC package
# Working around deprecation issues by allowing hand editing
# See ./packages/installedPackage/FinServ.installedPackage
sfdx force:mdapi:deploy -d packages -w 20 

sfdx force:package:install --package 04t1E000001Iql5 -w 20
sfdx force:user:permset:assign -n FinancialServicesCloudStandard

# Limited customization required for data loading
sfdx force:source:push -f
sfdx force:user:permset:assign -n FSC_Data_Load
sfdx force:user:permset:assign -n Platform_Encryption_Management

sfdx force:apex:execute -f scripts/apex/fixroles.apex

#Populate some Test data
sfdx force:data:bulk:upsert -u FSCDEMO -f data/households.csv -s Account -i Enterprise_Party_Id__c -w 20
sfdx force:data:bulk:upsert -u FSCDEMO -f data/persons.csv -s Account -i Enterprise_Party_Id__c -w 20
sfdx force:data:bulk:upsert -u FSCDEMO -f data/businesses.csv -s Account -i Enterprise_Party_Id__c -w 20
sfdx force:data:bulk:upsert -u FSCDEMO -f data/acr.csv -s AccountContactRelation -i Enterprise_Party_Id__c -w 20
sfdx force:data:bulk:upsert -u FSCDEMO -f data/aar.csv -s FinServ__AccountAccountRelation__c -i FinServ__ExternalId__c -w 20

sfdx force:data:bulk:upsert -u FSCDEMO -f data/financialaccounts.csv -s FinServ__FinancialAccount__c -i FinServ__FinancialAccountNumber__c -w 20

sfdx force:org:open
