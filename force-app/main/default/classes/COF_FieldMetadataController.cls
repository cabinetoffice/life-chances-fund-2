/* _______________________________________________________________________________________________________________________
   Name:        COF_FieldMetadataController.cls
   Description: Controller class for Retrieve Field Metadata action
                    
   Date         Version Author              Summary of Changes 
   ___________  _______ __________________  ______________________________________________________________________________
   Feb 2018     1.0     Michael Witchalls   Initial Release 
__________________________________________________________________________________________________________________________ */        
public with sharing class COF_FieldMetadataController {
	private static final String RETRIEVEVERIFICATION = 'The following LCF Field Metadata records have been retrieved:\n';
    private static final String VALIDATION_EXCEPTION = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    private static final String PAGETITLETEXT = 'Page Title:';
    private Map<String, Map<String, MetadataService.CustomField>> fieldMetadataMap;
	public List<String> objectNameList	{get; set;}
	public Boolean showButton			{get; set;}
	     
    public COF_FieldMetadataController(ApexPages.StandardController controller) { 
		showButton = true;
		// Get objectNameList from SIB_Field_Metadata__c picklist field
		objectNameList = COF_FieldMetadataExtract.getObjectNames();
    }

    public PageReference retrieveMetadata() {   	
   		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, RETRIEVEVERIFICATION));
   		
   		// First map the field metadata for each object in objectNameList
   		COF_FieldMetadataExtract.extractMetadataMap(objectNameList);
   		
   		// Then create and upsert field metadata records
    	for (String targetType: objectNameList) {
    		List<SIB_Field_Metadata__c> recordList = COF_FieldMetadataExtract.retrieveFieldMetadata(targetType);
    		try {
	        	upsert recordList Field_Key__c;
	   			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, targetType+': '+recordList.size()));
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