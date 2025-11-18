@isTest
public class BulkAPILookupResolverTest {
    public static testmethod void testACRAccount() {
       final String result = BulkAPILookupResolver.lookup(AccountContactRelation.SObjectType,'AccountId',Account.SObjectType);
       System.AssertEquals('Account.Enterprise_Party_Id__c',result); 
    }
    public static testmethod void testACRContact() {
       final String result = BulkAPILookupResolver.lookup(AccountContactRelation.SObjectType,'ContactId',Contact.SObjectType);
       System.AssertEquals('Contact.Enterprise_Party_Id__c',result); 

    }
    public static testmethod void testIPPPolicy() {
       final String result = BulkAPILookupResolver.lookup(InsurancePolicyParticipant.SObjectType,'InsurancePolicyId',InsurancePolicy.SObjectType);
       System.AssertEquals('Account.bar',result); 
    }
    public static testmethod void testIPPAccount() {
       final String result = BulkAPILookupResolver.lookup(InsurancePolicyParticipant.SObjectType,'PrimaryParticipantAccountId',Account.SObjectType);
       System.AssertEquals('Account.bar',result); 
    }
}