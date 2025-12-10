@isTest
public class BulkAPILookupResolverTest {
    public static testmethod void testARFrom() {
       final String result = BulkAPILookupResolver.lookup(AccountRelationship.AccountFromId);
         // ### Note the parentobject has two ExternalIds, hence the list
        System.AssertEquals('AccountFrom.producer_bp_id__c, AccountFrom.mm_member_id__c',result); 
    }
    public static testmethod void testARTo() {
       final String result = BulkAPILookupResolver.lookup(AccountRelationship.AccountToId);
         // ### Note the parentobject has two ExternalIds, hence the list
        System.AssertEquals('AccountTo.producer_bp_id__c, AccountTo.mm_member_id__c',result); 
    }

    public static testmethod void testACRAccount() {
       final String result = BulkAPILookupResolver.lookup(AccountContactRelation.AccountId);
         // ### Note the parentobject has two ExternalIds, hence the list
        System.AssertEquals('Account.producer_bp_id__c, Account.mm_member_id__c',result); 
    }
    public static testmethod void testACRContact() {
       final String result = BulkAPILookupResolver.lookup(AccountContactRelation.ContactId);
        // ### Note the parentobject has two ExternalIds, hence the list
        System.AssertEquals('Contact.producer_bp_id__c, Contact.mm_member_id__c',result); 

    }
    public static testmethod void testPolicyNamedInsured() {
       final String result = BulkAPILookupResolver.lookup(InsurancePolicy.NameInsuredId);
        // ### Note the parentobject has two ExternalIds, hence the list
       System.AssertEquals('NameInsured.producer_bp_id__c, NameInsured.mm_member_id__c',result); 
    }

    public static testmethod void testIPPPolicy() {
       final String result = BulkAPILookupResolver.lookup(InsurancePolicyParticipant.InsurancePolicyId);
       System.AssertEquals('InsurancePolicy.agreement_number__c',result); 
    }
    public static testmethod void testIPPAccount() {
       final String result = BulkAPILookupResolver.lookup(InsurancePolicyParticipant.PrimaryParticipantAccountId);
        // ### Note the parentobject has two ExternalIds, hence the list
        System.AssertEquals('PrimaryParticipantAccount.producer_bp_id__c, PrimaryParticipantAccount.mm_member_id__c',result); 
    }
    public static testmethod void testNull() {
       final String result = BulkAPILookupResolver.lookup(null);
       System.AssertEquals(null,result); 
    } 
    public static testmethod void testNullCompose() {
       final String result = BulkAPILookupResolver.composeFieldReference(null,null);
       System.AssertEquals(null,result); 
    }    
    public static testmethod void testNullExtIdFields() {
       final List<String> result = BulkAPILookupResolver.getExternalIdFields(null);
       System.AssertEquals(new List<String>(),result);  // Empty
    }

    public static testmethod void testOwnerField() {
        final String result = BulkAPILookupResolver.lookup(InsurancePolicy.OwnerId);
        System.AssertEquals(null,result);         
    } 
    public static testmethod void testPPAcsv() {
       final String result = BulkAPILookupResolver.generateCSVHeader(ProducerPolicyAssignment.SObjectType);
       System.AssertEquals('OwnerId,InsurancePolicy.agreement_number__c, InsurancePolicy.agreement_key__c,Producer.producer_external_id__c,LineOfBusiness,PPA_ExternalID__c',result); 
    }    

}