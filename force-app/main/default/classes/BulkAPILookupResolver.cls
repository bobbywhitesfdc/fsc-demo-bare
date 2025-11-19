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
    public static String lookup(final Schema.sObjectField targetField) {
        // get the targetField, list the relationship name
        // get the source object from that targetField
        // list the ExternalId fields that are candidates
        // compose the syntax reference based on the relationship name
        Schema.DescribeFieldResult dfr = targetField.getDescribe().getSObjectField().getDescribe();
        String result = '';
        List <Schema.sObjectType> sourceTypes = dfr.getReferenceTo();
        for (Schema.sObjectType soType : sourceTypes) {
            if (!String.IsBlank(result)) result += ',';
            result += composeFieldReference(dfr.getRelationshipName(),getExternalIdFields(soType));
        }
        return result;
    } 
    public static List<String> getExternalIdFields(Schema.SObjectType sobjectType) {
        List<String> externalIdFields = new List<String>();
        
        if (sobjectType != null) {
            // Get the describe result
            Schema.DescribeSObjectResult describeResult = sobjectType.getDescribe();
            
            // Get all fields
            Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
            
            // Iterate through fields and check for External ID AND Unique
            for (String fieldName : fieldsMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName).getDescribe();
                
                // Check if field is marked as External ID AND is Unique
                if (fieldDescribe.isExternalId() && fieldDescribe.isUnique()) {
                    externalIdFields.add(fieldName);
                }
            }
        }
        
        return externalIdFields;
    }
    public static String composeFieldReference(final String relationshipName, final List<String> externalIdFields) {
        if (String.isBlank(relationshipName) || externalIdFields == null || externalIdFields.isEmpty()) {
            return null;
        }
        
        List<String> fieldReferences = new List<String>();
        
        for (String externalIdField : externalIdFields) {
            // Compose the field reference as RelationshipName.ExternalIdField
            fieldReferences.add(relationshipName + '.' + externalIdField);
        }
        
        // Return comma-separated list of field references
        return String.join(fieldReferences, ', ');
    }
}