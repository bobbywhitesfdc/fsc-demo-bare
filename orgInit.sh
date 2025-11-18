#!/bin/bash
# Exit on error!
set -euxo pipefail

function prop {
    grep "${1}" project.properties|cut -d'=' -f2
}
#create scratch org
# let it auto-assign the username ( username="$(prop 'user.admin' )" )
#sf org create scratch -f config/project-scratch-def.json -a "$(prop 'default.env.alias' )"  --set-default --duration-days 28

sf org assign permsetlicense -n FinServ_FinancialServicesCloudStandardPsl
sf org assign permsetlicense -n FSCInsurancePsl

# Limited customization required for data loading
sf project deploy start -w 20
#sf org assign permset -n FSC_Data_Load

#sfdx force:apex:execute -f scripts/apex/fixroles.apex

#Populate some Test data
sf force data bulk upsert -o FSCDEMO -f data/households.csv -s Account -i Enterprise_Party_Id__c -w 20
sf force data bulk upsert -o FSCDEMO -f data/persons.csv -s Account -i Enterprise_Party_Id__c -w 20
sf force data bulk upsert -o FSCDEMO -f data/businesses.csv -s Account -i Enterprise_Party_Id__c -w 20
sf force data bulk upsert -o FSCDEMO -f data/acr.csv -s AccountContactRelation -i ACR_Ext_Id__c -w 20
sf force data bulk upsert -o FSCDEMO -f data/aar.csv -s AccountRelationship -i AA_External_Id__c -w 20
sf force data bulk upsert -o FSCDEMO -f data/aar.csv -s AccountRelationship -i AA_External_Id__c -w 20
sf force data bulk upsert -o FSCDEMO -f data/policy.csv -s InsurancePolicy -i PolicyExtId__c -w 20
sf force data bulk upsert -o FSCDEMO -f data/ipp.csv -s InsurancePolicyParticipant -i Policy_Participant_External_Id__c -w 20

#sf force data bulk upsert -o FSCDEMO -f data/financialaccounts.csv -s FinServ__FinancialAccount__c -i FinServ__FinancialAccountNumber__c -w 20

sf org open
