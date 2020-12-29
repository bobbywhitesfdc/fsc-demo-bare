public class BRAT_CLS_DocumentoTriggerHandler {
    
    public void OnAfterInsert(List<BRAT_OBJ_DOCUMENTO__c> newDocuments) {
 
            // getting all accounts from the documents
        Set<Id> accountIds = new Set<Id>();
        for (BRAT_OBJ_DOCUMENTO__c doc : newDocuments) {
            accountIds.add(doc.BRAT_LKU_CLIENTE__c);
        }
 
            // getting all territory system group from these accounts
        List<Group> grupos = [SELECT Id FROM Group WHERE RelatedId IN (SELECT Territory2Id FROM ObjectTerritory2Association where ObjectId IN :accountIds) AND Type = 'Territory'];
 
            // creating apex sharing for all system groups
        if (grupos.size() > 0) {
        
            List<BRAT_OBJ_DOCUMENTO__Share> newPermissionList = new List<BRAT_OBJ_DOCUMENTO__Share>();
            for(Group grupo : grupos){
                for(BRAT_OBJ_DOCUMENTO__c doc:newDocuments){
                    BRAT_OBJ_DOCUMENTO__Share novo = new BRAT_OBJ_DOCUMENTO__Share();
                    novo.AccessLevel='Edit';
                    novo.ParentId = doc.Id;
                    novo.UserOrGroupId = grupo.Id;
                    novo.RowCause=Schema.BRAT_OBJ_DOCUMENTO__Share.RowCause.Manual;
                    newPermissionList.add(novo);
                }
            }
            insert newPermissionList;
        }
    }
}

public class BRAT_CLS_DocumentoTriggerHandler {
    
    public void OnAfterInsert(List<BRAT_OBJ_DOCUMENTO__c> newDocuments) {

            // getting all accounts from the documents
        Set<Id> accountIds = new Set<Id>();
        for (BRAT_OBJ_DOCUMENTO__c doc : newDocuments) {
            accountIds.add(doc.BRAT_LKU_CLIENTE__c);
        }

            // getting all territory system group from these accounts
        List<Group> grupos = [SELECT Id FROM Group WHERE RelatedId IN (SELECT Territory2Id FROM ObjectTerritory2Association where ObjectId IN :accountIds) AND Type = 'Territory'];

            // creating apex sharing for all system groups
        if (grupos.size() > 0) {
        
            List<BRAT_OBJ_DOCUMENTO__Share> newPermissionList = new List<BRAT_OBJ_DOCUMENTO__Share>();
            for(Group grupo : grupos){
                for(BRAT_OBJ_DOCUMENTO__c doc:newDocuments){
                    BRAT_OBJ_DOCUMENTO__Share novo = new BRAT_OBJ_DOCUMENTO__Share();
                    novo.AccessLevel='Edit';
                    novo.ParentId = doc.Id;
                    novo.UserOrGroupId = grupo.Id;
                    novo.RowCause=Schema.BRAT_OBJ_DOCUMENTO__Share.RowCause.Manual;
                    newPermissionList.add(novo);
                }
            }
            insert newPermissionList;
        }
    }
}