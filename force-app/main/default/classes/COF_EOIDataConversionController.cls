/* _______________________________________________________________________________________________________________________
   Name:        COF_EOIDataConversionController.cls
   Description: Controller class for EOI Data Conversion action
                    
   Date         Version Author              Summary of Changes 
   ___________  _______ __________________  ______________________________________________________________________________
   Apr 2018     1.0     Michael Witchalls   Initial Release 
__________________________________________________________________________________________________________________________ */        
public with sharing class COF_EOIDataConversionController {
    private String VALIDATION_EXCEPTION = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    private Map<String, Form_LCF_EOI_1__c> appEOIMap;
    private Map<String, SIB_Field_Metadata__c> metadataMap;

	public Boolean showEOIButton		{get; set;}
	public Boolean showOtherButtons		{get; set;}
	     
    public COF_EOIDataConversionController() { 
		showEOIButton = true;
		showOtherButtons = false;
	}
	     
	/*
		This method creates and upserts EOI Form records
		1) Process application answers
		2) Upsert form records
	*/
    public PageReference createEOIData() {
    	String message = COF_EOIDataConversion.convertEOI(); 
    	if (message != null) {
    		if (message.startsWith('Error:')) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, message));
    		} else {
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, message));
    			showEOIButton = false;
    			showOtherButtons = true;
    		}
    	}
    	return null;
    }

	/*
		This method creates and upserts EOI Commissioner records
		1) Process application commissioners
		2) Upsert Form_LCF_Commissioner_1__c records
	*/
    public PageReference createCommissioners() {
    	String message = COF_EOIDataConversion.convertCommissioners(); 
    	if (message != null) {
    		if (message.startsWith('Error:')) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, message));
    		} else {
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, message));
    		}
    	}
    	return null;
    }
	
	/*
		This method creates and upserts EOI Outcome records
		1) Process application outcomes
		2) Upsert Form_LCF_Outcome_1__c records
	*/
    public PageReference createOutcomes() {
    	String message = COF_EOIDataConversion.convertOutcomes(); 
    	if (message != null) {
    		if (message.startsWith('Error:')) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, message));
    		} else {
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, message));
    		}
    	}
    	return null;
    }
	
	/*
		This method creates and upserts EOI Previous App records
		1) Process application previous applications 
		2) Upsert Form_LCF_Previous_App_1__c records
	*/
    public PageReference createPreviousApps() {
    	String message = COF_EOIDataConversion.convertPreviousApps(); 
    	if (message != null) {
    		if (message.startsWith('Error:')) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, message));
    		} else {
    			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, message));
    		}
    	}
    	return null;
    }
}