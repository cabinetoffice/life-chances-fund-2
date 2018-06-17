/* _______________________________________________________________________________________________________________
   Name:		COF_FullAppViewControllerTest.cls
   Description: Test Class for COF_FullAppViewControlle
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Mar 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class COF_FullAppViewControllerTest { 
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
	}    
	
    @isTest static void testit() {
    	Application__c a = [SELECT Id, Name FROM Application__c LIMIT 1];
    	Form_LCF_Full_App_1__c f = [SELECT Id, Name FROM Form_LCF_Full_App_1__c LIMIT 1];
		
        PageReference pageRef = Page.COF_FullAppViewOverride;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('Id', f.Id);      
        
		Test.startTest();
		ApexPages.StandardController stdcon = new ApexPages.StandardController(f);
        COF_FullAppViewOverrideController con = new COF_FullAppViewOverrideController(stdcon);
        con.getViewAction();
        con.viewForm();
      	
     	Test.stopTest();
        system.assertEquals(a.Name, con.appId);
    }  
    
    
}