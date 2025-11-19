@isTest
public class BulkAPILookupResolverTest {
    public static testmethod void testACRAccount() {
       final String result = BulkAPILookupResolver.lookup(AccountContactRelation.AccountId);
       System.AssertEquals('Account.enterprise_party_id__c',result); 
    }
    public static testmethod void testACRContact() {
       final String result = BulkAPILookupResolver.lookup(AccountContactRelation.ContactId);
       System.AssertEquals('Contact.enterprise_party_id__c',result); 

    }
    public static testmethod void testIPPPolicy() {
       final String result = BulkAPILookupResolver.lookup(InsurancePolicyParticipant.InsurancePolicyId);
       System.AssertEquals('InsurancePolicy.policyextid__c',result); 
    }
    public static testmethod void testIPPAccount() {
       final String result = BulkAPILookupResolver.lookup(InsurancePolicyParticipant.PrimaryParticipantAccountId);
       System.AssertEquals('PrimaryParticipantAccount.enterprise_party_id__c',result); 
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
       System.AssertEquals(null,result); 
    }    
}