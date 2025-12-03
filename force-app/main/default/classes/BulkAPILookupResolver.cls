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
 
    public static String generateCSVHeader(final Schema.SObjectType sobjectType) {
        return generateCSVHeader(sobjectType,true);
    }
/**
 * Generate a CSV header for the given SObjectType with all fields.
 * Lookup fields use external ID references, RecordTypeId uses RecordType.DeveloperName,
 * Id field is excluded, and read-only fields are skipped.
 * 
 * @param sobjectType The SObjectType to generate CSV header for
 * @return CSV header string with field references
 **/
public static String generateCSVHeader(final Schema.SObjectType sobjectType, boolean includeAllFields) {
    if (sobjectType == null) {
        return null;
    }
    
    List<String> headerFields = new List<String>();
    Schema.DescribeSObjectResult describeResult = sobjectType.getDescribe();
    Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
    
    for (String fieldName : fieldsMap.keySet()) {
        System.debug('processing: ' + fieldName);
        Schema.SObjectField fieldToken = fieldsMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = fieldToken.getDescribe();
        
        // Skip the Id field
        if (fieldDescribe.getName().equalsIgnoreCase('Id')) {
            System.Debug('skipping ID field');
            continue;
        }
        
        // Skip read-only fields (system audit fields like CreatedDate, CreatedById, LastModifiedDate, etc.)
        if (!fieldDescribe.isCreateable() && !fieldDescribe.isUpdateable()) {
            System.Debug('Skipping unwritable field:' + fieldDescribe.getName());
            continue;
        }
        
        // Special handling for RecordTypeId
        if (fieldDescribe.getName().equalsIgnoreCase('RecordTypeId')) {
            headerFields.add('RecordType.DeveloperName');
            continue;
        }
        
        if (fieldDescribe.getName()==null) {
            System.Debug('### NULL Name - type: ' + fieldDescribe.getType());
            continue;
        } 
        
        // Check if this is a lookup/master-detail relationship
        if (fieldDescribe.getType() == Schema.DisplayType.REFERENCE) {
            String lookupReference = lookup(fieldToken);
            System.Debug('Lookup reference:'+lookupReference);
            if (!String.isBlank(lookupReference)) {
                headerFields.add(lookupReference);
            } else {
                // Fallback to regular field name if no external IDs found
                headerFields.add(fieldDescribe.getName());
            }
        } else {
            // Regular field - use the field name
            if (includeAllFields || !fieldDescribe.isNillable() || fieldDescribe.isCustom()) {
               headerFields.add(fieldDescribe.getName());
            }
        }
    }
    
    return String.join(headerFields, ',');
}    
    /**
     * Use Schema Describe methods to generate the field reference syntax
     **/ 
    public static String lookup(final Schema.sObjectField targetField) {
        // short circuit on null
        if (targetField == null) return null;
        
        System.Debug('Processing Lookups for:' + targetField);
        
        // get the targetField, list the relationship name
        // get the source object from that targetField
        // list the ExternalId fields that are candidates
        // compose the syntax reference based on the relationship name
        Schema.DescribeFieldResult dfr = targetField.getDescribe().getSObjectField().getDescribe();
        String result = null;
        for (Schema.sObjectType soType : dfr.getReferenceTo()) {
            String composedRef = composeFieldReference(dfr.getRelationshipName(), getExternalIdFields(soType));
            if (composedRef == null || composedRef=='null') {
                System.Debug('### skipping null composedRef');
                continue; 
            }
            
            if (result == null) {
                result = '';
            } else if (!String.IsBlank(result)) {
               result += ','; 
            } 
            
            result += composeFieldReference(dfr.getRelationshipName(), getExternalIdFields(soType));
        }
        return result;
    }
    
    public static List<String> getExternalIdFields(Schema.SObjectType sobjectType) {
        List<String> externalIdFields = new List<String>();
        
        if (sobjectType == null) { 
            return externalIdFields; 
        } else {
            // Get the describe result
            Schema.DescribeSObjectResult describeResult = sobjectType?.getDescribe();
            
            // Get all fields
            Map<String, Schema.SObjectField> fieldsMap = describeResult?.fields?.getMap();
            
            // Iterate through fields and check for External ID AND Unique
            for (String fieldName : fieldsMap?.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldsMap?.get(fieldName)?.getDescribe();
                
                // Check if field is marked as External ID AND is Unique
                if (fieldDescribe?.isExternalId() && fieldDescribe?.isUnique()) {
                    externalIdFields.add(fieldName);
                }
            }
        }
        
        return externalIdFields;
    }
    
    public static String composeFieldReference(final String relationshipName, final List<String> externalIdFields) {
        System.Debug('###relname:' + relationshipName + ' extIdFields:' + externalIdFields);
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