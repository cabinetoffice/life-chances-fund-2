/* _______________________________________________________________________________________________________________________
   Name:        COF_FieldMetadataController.cls
   Description: Controller class for Retrieve Field Descriptions action
                    
   Date         Version Author              Summary of Changes 
   ___________  _______ __________________  ______________________________________________________________________________
   Feb 2018     1.0     Michael Witchalls   Initial Release 
__________________________________________________________________________________________________________________________ */        
public with sharing class COF_FieldMetadataController {
	private static final String RETRIEVEVERIFICATION = 'The following LCF Field Metadata records have been retrieved:\n';
    private static final String VALIDATION_EXCEPTION = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
	private List<String> ObjectNameList;
    private Map<String, Map<String, MetadataService.CustomField>> fieldMetadataMap;
	public Boolean 	showButton		{get; set;}
	     
    public COF_FieldMetadataController(ApexPages.StandardController controller) { 
		showButton = true;
		// Retrieve list of SIB Objects
		ObjectNameList = new List<String>();
		List<Schema.PicklistEntry> pickValues = SIB_Field_Metadata__c.Object_Name__c.getDescribe().getPicklistValues();
   		for (Schema.PicklistEntry p: pickValues) {
			if (p.isActive()) {
				ObjectNameList.add(p.getLabel());
			}
        }		
    }

	/*
		This method makes a SOAP API call to the Salesforce Metadata API in order to retrieve field descriptions
		and other metadata for a specified objects. This is required since description is not available via Apex Describe.
		Unfortunately, the Metadata API is only available to end users with 'Modify All Data' permission, so 
		we have to use a custom object to store the descriptions for end user access.
		
		M.Witchalls Feb 2018 with thanks to Andrew Fawcett and FinancialForce.
		
		PRE-REQUISITE: THERE MUST EXIST IN SALESFROCE SETUP A REMOTE SITE SETTING WHERE 
			"Remote Site URL" = this org's Visualforce URL (e.g. https://lcf--lcfdev--c.cs89.visual.force.com)
	*/
    public PageReference retrieveMetadata() {
    	fieldMetadataMap = new Map<String, Map<String, MetadataService.CustomField>>();
    	
	    MetadataService.MetadataPort service = new MetadataService.MetadataPort();
	    service.SessionHeader = new MetadataService.SessionHeader_element();
	    service.SessionHeader.sessionId = UserInfo.getSessionId();
	    
    	for (String targetObject: ObjectNameList) {
    		Map<String, MetadataService.CustomField> metaDataMap = new Map<String, MetadataService.CustomField>();
	    	MetadataService.CustomObject customObject =
	    		(MetadataService.CustomObject) service.readMetadata('CustomObject', new String[]{targetObject}).getRecords()[0]; 
	    	for (MetadataService.CustomField customField: customObject.fields) {
	    		metaDataMap.put(customField.fullName, customField);
	    	}
	    	fieldMetadataMap.put(targetObject, metaDataMap);
    	}
    	
   		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, RETRIEVEVERIFICATION));
    	for (String targetType: ObjectNameList) {
    		List<SIB_Field_Metadata__c> recordList = new List<SIB_Field_Metadata__c>();
    		Map<String, MetadataService.CustomField> metaDataMap = fieldMetadataMap.get(targetType);
    		Integer fieldCount = 0;
    		for (String fieldName: metaDataMap.keySet()) {
    			MetadataService.CustomField field = metaDataMap.get(fieldName);
	    		SIB_Field_Metadata__c record = new SIB_Field_Metadata__c(
	    			Name = field.label,
	    			Object_Name__c = targetType,
	    			Field_Key__c = targetType+'.'+fieldName,
	    			Description__c = field.description,
	    			Help_Text__c = field.inlineHelpText,
	    			Relationship_Name__c = (field.relationshipName == null) ? null : field.relationshipName+'__r'   			
	    		);
    			recordList.add(record);
    			fieldCount++; 
    		}
    		try {
	        	upsert recordList Field_Key__c;
	   			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, targetType+': '+fieldCount));
    		} catch (Exception e) {
        		exceptionMessage(e);
	   		}
    	}
  		showButton = false;
        return null;
    }

    public PageReference viewMetadata() {
		Schema.DescribeSObjectResult objectSchema = SIB_Field_Metadata__c.SObjectType.getDescribe();
		String objectIdPrefix = objectSchema.getKeyPrefix();
		PageReference nextPage = new PageReference('/'+objectIdPrefix+'/o');
        nextPage.setRedirect(true);
        return nextPage;
    }

    private void exceptionMessage(Exception e) {   	
        String msg = e.getMessage();
        if (msg.contains(VALIDATION_EXCEPTION)) {
            String validationError = msg.substringBetween(VALIDATION_EXCEPTION+', ',':');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, validationError));
		} else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, msg));
        }
    }    
}