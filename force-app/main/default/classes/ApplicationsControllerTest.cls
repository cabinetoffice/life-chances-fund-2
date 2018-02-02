/* _______________________________________________________________________________________________________________
   Name:		ApplicationsControllerTest.cls
   Description: Test Class for ApplicationsController
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Jan 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class ApplicationsControllerTest { 
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
	}    
	
    @isTest static void testit() {
    	Application__c a = [SELECT Id, Name FROM Application__c LIMIT 1];
		
        PageReference pageRef = Page.Applications;
        Test.setCurrentPage(pageRef);     
        
		Test.startTest();
		ApplicationsController con1 = new ApplicationsController();
     	
     	Test.stopTest();
        system.assertEquals(a.Name, con1.applications[0].get('Name'));
    }  
    
    
}