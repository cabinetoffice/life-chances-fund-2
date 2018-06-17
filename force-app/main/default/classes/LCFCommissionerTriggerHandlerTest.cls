/* _______________________________________________________________________________________________________________
   Name:		LCFCommissionerTriggerHandlerTest.cls
   Description: Test Class for LCFCommissionerTriggerHandler
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Mar 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class LCFCommissionerTriggerHandlerTest { 
	private static final String RECORDTYPE = 'Full Application';
	private static final String THEME1 = 'Children\'s services';
	private static final String THEME2 = 'Healthy lives';
	private static final String STAGE = 'Full Application';
	private static final String DRAFT = 'Draft';
	
	@testSetup static void setup() {   	
		// Create an Application
		Application__c a = new Application__c(
			RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get(RECORDTYPE).getRecordTypeId(),
			application_theme__c = THEME1,
			Application_Stage__c = STAGE,
			Full_Application_Status__c = DRAFT
		);
		insert a;
		// Create a Full Application Form
		Form_LCF_Full_App_1__c f = new Form_LCF_Full_App_1__c(
			application__c = a.Id,
			ov_services_start_date__c = System.Today(),
			si_themes__c = THEME1+';'+THEME2
		);
		insert f;
		// Create an EOI Form
		Form_LCF_EOI_1__c e = new Form_LCF_EOI_1__c(
			application__c = a.Id
		);
		insert e;
	}    
	
    @isTest static void testit() {
    	Form_LCF_Full_App_1__c f = [SELECT Id, application__c FROM Form_LCF_Full_App_1__c LIMIT 1];
    	Form_LCF_EOI_1__c e = [SELECT Id, application__c FROM Form_LCF_EOI_1__c LIMIT 1];
    	
    	Test.startTest();
		// Create a Commissioner
		Form_LCF_Commissioner_1__c c = new Form_LCF_Commissioner_1__c(
			application__c = f.application__c,
			full_application__c = f.Id,
			eoi__c = e.Id,
			st_organisation_name__c = 'Test Organisation',
			st_organisation_region__c = 'London',
			primary__c = true
		);
		insert c;
		c.st_organisation_region__c = 'South East'; 
		update c;
		Test.stopTest();
		
		Application__c a = [SELECT Id, Full_App_Primary_Commissioner__c, Full_App_Primary_Commissioner_Region__c FROM Application__c LIMIT 1];
		system.assertEquals('South East', a.Full_App_Primary_Commissioner_Region__c);
    }  
    
}