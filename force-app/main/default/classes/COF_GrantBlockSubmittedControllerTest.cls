/* _______________________________________________________________________________________________________________
   Name:		COF_GrantBlockSubmittedControllerTest.cls
   Description: Test Class for COF_GrantBlockSubmittedController
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   May 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class COF_GrantBlockSubmittedControllerTest { 
	private static final String COMPLETE = 'COMPLETE';
	private static final String NOTSUBMITTED = 'Not Submitted';
	private static final String SUBMITTED = 'Submitted';
	private static final String INCOMPLETE = 'INCOMPLETE';
	private static final String INPROGRESS = 'IN PROGRESS';
	private static final String RECORDTYPE = 'Full Application';
	private static final String THEME1 = 'Children\'s services';
	private static final String THEME2 = 'Healthy lives';
	private static final String STAGE = 'Full Application';
	
	@testSetup static void setup() {
    	
		// Create an Application
		Application__c a = new Application__c(
			RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get(RECORDTYPE).getRecordTypeId(),
			application_theme__c = THEME1,
			Application_Stage__c = STAGE
		);
		insert a;
    	
		// Create a Grant
		LCF_Grant__c g = new LCF_Grant__c(Application__c = a.Id);
		insert g;
		
		// Create a Grant Achievement form
		Form_LCF_Grant_Achievement_1__c f = new Form_LCF_Grant_Achievement_1__c(
			lcf_grant__c = g.Id,
			ab_approval_status__c = NOTSUBMITTED,
			ab_block_status__c = INPROGRESS
		);
		insert f;
	}    
	
    @isTest static void testit() {
    	// cof_grantblocksubmitted?form=lcf_grant_achievement_1&app=APP-01165&grant=GNT-0001
    	Application__c a = [SELECT Id, Name FROM Application__c LIMIT 1];
    	LCF_Grant__c g = [SELECT Id, Name FROM LCF_Grant__c LIMIT 1];
		
        PageReference pageRef = Page.COF_GrantBlockSubmitted;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('app', a.Name);      
        ApexPages.currentPage().getParameters().put('grant', g.Name);      
        ApexPages.currentPage().getParameters().put('form', 'lcf_grant_achievement_1');      
          
		Test.startTest();
		COF_GrantBlockSubmittedController con1 = new COF_GrantBlockSubmittedController();
     	
     	Test.stopTest();
        system.assertEquals(g.Name, con1.grant.get('Name'));
    }  
    
    
}