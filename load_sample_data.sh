#!/bin/bash
# Exit on error!
set -euxo pipefail

function prop {
    grep "${1}" project.properties|cut -d'=' -f2
}

#Populate some Test data to the Default Scratch org
sf force data bulk upsert  -f data/households.csv -s Account -i MM_Member_Id__c -w 20
sf force data bulk upsert  -f data/persons.csv -s Account -i MM_Member_Id__c -w 20
sf force data bulk upsert  -f data/businesses.csv -s Account -i MM_Member_Id__c -w 20
sf force data bulk upsert  -f data/partners.csv -s Account -i Producer_BP_Id__c -w 20
sf force data bulk upsert  -f data/contacts.csv -s Contact -i Producer_BP_Id__c -w 20

sf force data bulk upsert  -f data/producers.csv -s Producer -i Producer_External_ID__c -w 20

sf force data bulk upsert  -f data/acr.csv -s AccountContactRelation -i ACR_Ext_Id__c -w 20
sf force data bulk upsert  -f data/aar.csv -s AccountRelationship -i AA_External_Id__c -w 20
sf force data bulk upsert  -f data/policy.csv -s InsurancePolicy -i Agreement_Key__c -w 20

#InsurancePolicyParticipant is the junction between Policy and Contact OR Account
sf force data bulk upsert  -f data/ipp.csv -s InsurancePolicyParticipant -i Policy_Participant_External_Id__c -w 20
sf force data bulk upsert  -f data/ipp_stubbed.csv -s InsurancePolicyParticipant -i Policy_Participant_External_Id__c -w 20
#
sf force data bulk upsert  -f data/ProducerPolicyAssignment.csv -s ProducerPolicyAssignment -i PPA_ExternalID__c -w 20


#sf force data bulk upsert  -f data/financialaccounts.csv -s FinServ__FinancialAccount__c -i FinServ__FinancialAccountNumber__c -w 20

sf org open
