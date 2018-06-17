/* _______________________________________________________________________________________________________________
   Name:		COF_GrantViewControllerTest.cls
   Description: Test Class for COF_FullAppViewControlle
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   May 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class COF_GrantViewControllerTest { 
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
    	
		// Create a Grant
		LCF_Grant__c g = new LCF_Grant__c(Application__c = a.Id);
		insert g;
	}    
	
    @isTest static void testit() {
    	LCF_Grant__c g = [SELECT Id, Name, Application__c FROM LCF_Grant__c LIMIT 1];
		
        PageReference pageRef = Page.COF_GrantViewOverride;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('Id', g.Id);      
        
		Test.startTest();
		ApexPages.StandardController stdcon = new ApexPages.StandardController(g);
        COF_GrantManagementViewController con = new COF_GrantManagementViewController(stdcon);
        con.getViewAction();
        con.viewForm();
      	
     	Test.stopTest();
        system.assertEquals(g.Application__c, con.applicationId);
    }  
    
}