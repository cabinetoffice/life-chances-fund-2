/* _______________________________________________________________________________________________________________
   Name:		COF_SetupViewControllerTest.cls
   Description: Test Class for COF_SetupViewController
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Apr 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class COF_SetupViewControllerTest { 
	private static final String RECORDTYPE = 'Full Application';
	private static final String THEME1 = 'Children\'s services';
	private static final String STAGE = 'Full Application';
	private static final String DRAFT = 'Draft';
	private static final String SUCCESSFUL = 'Successful';
	
	@testSetup static void setup() {
    	
		// Create an Application
		Application__c a = new Application__c(
			RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get(RECORDTYPE).getRecordTypeId(),
			application_theme__c = THEME1,
			Application_Stage__c = STAGE,
			Full_Application_Status__c = SUCCESSFUL,
			Full_Award_Setup_Status__c = DRAFT
		);
		insert a;
		// Create a Full Award Setup Form
		Form_LCF_Setup_1__c f = new Form_LCF_Setup_1__c(
			application__c = a.Id
		);
		insert f; 
	}    
	
    @isTest static void testit() {
    	Application__c a = [SELECT Id, Name FROM Application__c LIMIT 1];
    	Form_LCF_Setup_1__c f = [SELECT Id, Name FROM Form_LCF_Setup_1__c LIMIT 1];
		
        PageReference pageRef = Page.COF_SetupViewOverride;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('Id', f.Id);      
        
		Test.startTest();
		ApexPages.StandardController stdcon = new ApexPages.StandardController(f);
        COF_SetupViewOverrideController con = new COF_SetupViewOverrideController(stdcon);
        con.getViewAction();
        con.viewForm();
      	
     	Test.stopTest();
        system.assertEquals(a.Name, con.appId);
    }  
    
    
}