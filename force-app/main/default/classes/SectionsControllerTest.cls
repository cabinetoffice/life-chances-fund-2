/* _______________________________________________________________________________________________________________
   Name:		SectionsControllerTest.cls
   Description: Test Class for SectionsController
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Jan 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class SectionsControllerTest { 
	private static final String RECORDTYPE = 'Full Application';
	private static final String THEME1 = 'Children\'s services';
	private static final String THEME2 = 'Healthy lives';
	private static final String STAGE = 'Full Application';
	private static final String DRAFT = 'Draft';
	private static final String SUBMITTED = 'Submitted';
	private static final String INCOMPLETE = 'INCOMPLETE';
	
	@testSetup static void setup() {
    	
		// Create an Application
		Application__c a = new Application__c(
			RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get(RECORDTYPE).getRecordTypeId(),
			application_theme__c = THEME1,
			Application_Stage__c = STAGE,
			Full_Application_Status__c = DRAFT
		);
		insert a;
	}    
	
    @isTest static void testit() {
    	// Sections?form=lcf_full_app_1&app=APP-01118
    	Application__c a = [SELECT Id, Name FROM Application__c LIMIT 1];
		
        PageReference pageRef = Page.Sections;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('app', a.Name);      
        ApexPages.currentPage().getParameters().put('form', 'lcf_full_app_1');      
         
		Test.startTest();
		SectionsController con1 = new SectionsController();
		con1.initialAction();
		con1.submit();
		con1.viewAll();
     	
     	Test.stopTest();
    	a = [SELECT Id, Name, Full_Application_Status__c FROM Application__c LIMIT 1];
     	Form_LCF_Full_App_1__c f = [SELECT Id, Name, ov_section_status__c FROM Form_LCF_Full_App_1__c LIMIT 1];
     	
        system.assertEquals(INCOMPLETE, f.ov_section_status__c);
		system.assertEquals(SUBMITTED, a.Full_Application_Status__c);
    }  
    
    
}