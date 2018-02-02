/* _______________________________________________________________________________________________________________
   Name:		COF_ApplicationSubmittedControllerTest.cls
   Description: Test Class for COF_ApplicationSubmittedController
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Feb 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class COF_ApplicationSubmittedControllerTest { 
	private static final String RECORDTYPE = 'Full Application';
	private static final String THEME1 = 'Children\'s services';
	private static final String THEME2 = 'Healthy lives';
	private static final String STAGE = 'Full Application';
	private static final String SUBMITTED = 'Submitted';
	
	@testSetup static void setup() {
    	
		// Create an Application
		Application__c a = new Application__c(
			RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get(RECORDTYPE).getRecordTypeId(),
			application_theme__c = THEME1,
			Application_Stage__c = STAGE,
			Full_Application_Status__c = SUBMITTED
		);
		insert a;
		// Create a Full Application Form
		Form_LCF_Full_App_1__c f = new Form_LCF_Full_App_1__c(
			application__c = a.Id,
			ov_services_start_date__c = System.Today(),
			si_themes__c = THEME1+';'+THEME2
		);
		insert f;
	}    
	
    @isTest static void testit() {
    	// Start?form=lcf_full_app_1&section=lcf_full_app_overview_1&app=APP-01118
    	Application__c a = [SELECT Id, Name FROM Application__c LIMIT 1];
		
        PageReference pageRef = Page.COF_ApplicationSubmitted;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('app', a.Name);      
        ApexPages.currentPage().getParameters().put('form', 'lcf_full_app_1');      
          
		Test.startTest();
		COF_ApplicationSubmittedController con1 = new COF_ApplicationSubmittedController();
     	
     	Test.stopTest();
        system.assertEquals(a.Name, con1.application.get('Name'));
    }  
    
    
}