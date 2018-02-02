/* _______________________________________________________________________________________________________________
   Name:		SummaryControllerTest.cls
   Description: Test Class for SummaryController
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Jan 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class SummaryControllerTest { 
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
		// Create a Commissioner
		Form_LCF_Commissioner_1__c c = new Form_LCF_Commissioner_1__c(
			application__c = a.Id,
			full_application__c = f.Id,
			co_organisation_name__c = 'Test Organisation'
		);
		insert c;
	}    
	
    @isTest static void testit() {
    	// summary?app=APP-01118&form=lcf_full_app_1&section=lcf_full_app_overview_1
    	Application__c a = [SELECT Id, Name FROM Application__c LIMIT 1];
    	Form_LCF_Full_App_1__c f = [SELECT Id, Name FROM Form_LCF_Full_App_1__c LIMIT 1];
		Form_LCF_Commissioner_1__c c = [SELECT Id, Name FROM Form_LCF_Commissioner_1__c LIMIT 1];
		
        PageReference pageRef = Page.Summary;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('app', a.Name);      
        ApexPages.currentPage().getParameters().put('form', 'lcf_full_app_1');      
        ApexPages.currentPage().getParameters().put('section', 'lcf_full_app_overview_1');      
        
		Test.startTest();
		SummaryController con1 = new SummaryController();
		con1.complete();
		con1.saveExit();
     	
     	Test.stopTest();
        system.assertEquals(f.Id, con1.targetObject.get('Id'));
    }  
    
    
}