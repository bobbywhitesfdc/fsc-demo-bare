String roleExternalId = 'MDM1';

FinServ__ReciprocalRole__c entityRole = new FinServ__ReciprocalRole__c(Name='Member'
	,FinServ__CreateInverseRole__c=false
	,FinServ__RelationshipType__c='Account Role'
	,FinServ__SourceSystemId__c=roleExternalId
	, FinServ__InverseRole__c='Is Member of');
upsert entityRole FinServ__SourceSystemId__c;
