/* _______________________________________________________________________________________________________________________
   Name:        COF_FieldMetadataExtract.cls
   Description: Retrieve Field Metadata
                    
   Date         Version Author              Summary of Changes 
   ___________  _______ __________________  ______________________________________________________________________________
   Apr 2018     1.0     Michael Witchalls   Initial Release 
__________________________________________________________________________________________________________________________ */        
public without sharing class COF_FieldMetadataExtract {
    private static final String PAGETITLETEXT = 'Page Title:';
    private static Map<String, Map<String, MetadataService.CustomField>> fieldMetadataMap;
    
	/*
	 *	Purpose: Get list of SIB objects from SIB_Field_Metadata__c picklist field metadata
	 *	History: 
	 *		Mar 2018: Michael Witchalls: Initial Release
	 *
	 */    
    public static List<String> getObjectNames() {
		List<String> objectNameList = new List<String>();
		List<Schema.PicklistEntry> pickValues = SIB_Field_Metadata__c.Object_Name__c.getDescribe().getPicklistValues();
   		for (Schema.PicklistEntry p: pickValues) {
			if (p.isActive()) {
				objectNameList.add(p.getLabel());
			}
        }	
        return objectNameList;	    	
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
    public static void extractMetadataMap(List<String> objectNameList) {
    	fieldMetadataMap = new Map<String, Map<String, MetadataService.CustomField>>();
    	
	    MetadataService.MetadataPort service = new MetadataService.MetadataPort();
	    service.SessionHeader = new MetadataService.SessionHeader_element();
	    service.SessionHeader.sessionId = UserInfo.getSessionId();
	    
	    MetadataService.CustomObject testObject;
		/*
			A testObject is created for test classes because there is no simple way 
			to create a mock web service for the readMetadata method
		*/
	    if (Test.isRunningTest()) {
		    testObject = new MetadataService.CustomObject();
	    	testObject.fullName = 'Application__c';
			testObject.label = 'Application';
			MetadataService.CustomField fld = new MetadataService.CustomField();
			fld.fullName = 'Test__c';
			fld.label = 'Test';
			fld.description = 'Test Decription';
			fld.inlineHelpText = 'Test Help';
			fld.relationshipName = 'Test';
			testObject.fields = new List<MetadataService.CustomField>{fld};		    
	    }
	    
    	for (String targetObject: objectNameList) {
    		Map<String, MetadataService.CustomField> metaDataMap = new Map<String, MetadataService.CustomField>();
	    	MetadataService.CustomObject customObject =	Test.isRunningTest() ? testObject : 
				(MetadataService.CustomObject) service.readMetadata('CustomObject', new String[]{targetObject}).getRecords()[0]; 
	    	if (customObject != null && customObject.fields != null) {
		    	for (MetadataService.CustomField customField: customObject.fields) {
		    		metaDataMap.put(customField.fullName, customField);
		    	}
	    	}
	    	fieldMetadataMap.put(targetObject, metaDataMap);
    	}
    	
    }
	
	/*
	 *	Purpose: Create SIB_Field_Metadata__c records from the extracted metadata
	 *	History: 
	 *		Mar 2018: Michael Witchalls: Initial Release
	 *
	 */    
    public static List<SIB_Field_Metadata__c> retrieveFieldMetadata(String targetType) {
		List<SIB_Field_Metadata__c> recordList = new List<SIB_Field_Metadata__c>();
		Map<String, MetadataService.CustomField> metaDataMap = fieldMetadataMap.get(targetType);
		for (String fieldName: metaDataMap.keySet()) {
			MetadataService.CustomField field = metaDataMap.get(fieldName);
    		SIB_Field_Metadata__c record = new SIB_Field_Metadata__c(
    			Name = field.label,
    			Field_Name__c = fieldName,
    			Object_Name__c = targetType,
    			Field_Key__c = targetType+'.'+fieldName,
    			Help_Text__c = field.inlineHelpText,
    			Type__c = field.type_x,
    			Length__c = (field.type_x == 'Text') ? field.length : field.precision,
    			Relationship_Name__c = (field.relationshipName == null) ? null : field.relationshipName+'__r'   			
    		);
    		record.Page_Title__c = null;
    		record.Description__c = null;
			if (field.description != null && field.description.startsWith(PAGETITLETEXT)) {
				record.Page_Title__c = field.description.mid(11,255);
			} else {
				record.Description__c = field.description;
			}
			recordList.add(record);
		}
    	return recordList;
    }
}