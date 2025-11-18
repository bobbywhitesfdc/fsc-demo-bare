/**
 * Utility Class to assist an ETL Developer in resolving the name of a lookup relationship to 
 * use with the Bulk API
 * 
 * Example:  
 * 
 * As an ETL Developer, I'm trying to upsert an InsurancePolicyParticipant record and use external Ids to resolve the AccountLookup 
 * 
 * Inputs:
 * 1. SObjectType of the Target Object to ETL load
 * 2. Target Field Name
 * 3. SObjectType of the Source Object to which the Lookup Relationship points
 * 
 * Output: 
 * CSV Header for this field reference
 **/ 
public class BulkAPILookupResolver {
    /**
     * Use Schema Describe methods to generate the field reference syntax
     **/ 
    public static String lookup(final Schema.SObjectType targetObject, final String targetField, final Schema.SObjectType sourceObject) {
        // get the source object
        // find the relationship(s) that point to the target object and the specific field
        // compose the syntax reference based on the relationship name
        return null;
    }
}