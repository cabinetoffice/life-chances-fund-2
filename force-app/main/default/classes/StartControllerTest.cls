/* _______________________________________________________________________________________________________________
   Name:		StartControllerTest.cls
   Description: Test Class for StartController
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Jan 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class StartControllerTest { 
	private static final String RECORDTYPE = 'Full Application';
	private static final String THEME1 = 'Children\'s services';
	private static final String THEME2 = 'Healthy lives';
	private static final String STAGE = 'Full Application';
	private static final String DRAFT = 'Draft';
	
	@testSetup static void setup() {
		// Add section text
		SIB_Information__c info = new SIB_Information__c(Name = 'Life Chances Fund');
		insert info;
		SIB_Section_Text__c text = new SIB_Section_Text__c(
			SIB_Reference__c = info.Id,
			Name = 'lcf_full_app_overview_1',
			Object_Name__c = 'Form_LCF_Full_App_1__c',
			Text__c = 'Section Text'
		);
    	insert text;
    	
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
	}    
	
    @isTest static void testit() {
    	// Start?form=lcf_full_app_1&section=lcf_full_app_overview_1&app=APP-01118
    	Application__c a = [SELECT Id, Name FROM Application__c LIMIT 1];
		
        PageReference pageRef = Page.Start;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('app', a.Name);      
        ApexPages.currentPage().getParameters().put('form', 'lcf_full_app_1');      
        ApexPages.currentPage().getParameters().put('section', 'lcf_full_app_overview_1');      
         
		Test.startTest();
		StartController con1 = new StartController();
		con1.start();
		con1.summaryPage();
     	
     	Test.stopTest();
        system.assertEquals(a.Name, con1.application.get('Name'));
    }  
    
    
}