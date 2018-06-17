/* _______________________________________________________________________________________________________________
   Name:		LCFGrantControllersTest.cls
   Description: Test Class for LCFGrantsController and LCFGrantBlockController
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   May 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class LCFGrantControllersTest { 
	private static final String RECORDTYPE = 'Full Application';
	private static final String THEME1 = 'Children\'s services';
	private static final String THEME2 = 'Healthy lives';
	private static final String STAGE = 'Full Application';
	private static final String DRAFT = 'Draft';
	private static final String NOTSUBMITTED = 'Not Submitted';
	private static final String SUBMITTED = 'Submitted';
	private static final String INCOMPLETE = 'INCOMPLETE';
	private static final String INPROGRESS = 'IN PROGRESS';
	private static final String FIRSTNAME = 'Joe';
	private static final String LASTNAME = 'Bloggs';
	private static final String EMAILADDRESS = 'joe.bloggs@email.com';
	
	@testSetup static void setup() {
		// Add section text
		SIB_Information__c info = new SIB_Information__c(Name = 'Life Chances Fund');
		insert info;
		SIB_Section_Text__c text = new SIB_Section_Text__c(
			SIB_Reference__c = info.Id,
			Name = 'Form',
			Object_Name__c = 'Form_LCF_Grant_Achievement_1__c',
			Text__c = 'Form Text'
		);
    	insert text;
		SIB_Section_Text__c text2 = new SIB_Section_Text__c(
			SIB_Reference__c = info.Id,
			Name = 'lcf_grant_user_referral_1',
			Object_Name__c = 'Form_LCF_Grant_Achievement_1__c',
			Text__c = 'Section Text'
		);
    	insert text2;
    	
    	// Create a Contact
    	Contact c = new Contact(
    		FirstName=FIRSTNAME,
    		LastName=LASTNAME,
    		Email = EMAILADDRESS
    	);
    	insert c;
    	
		// Create an Application
		Application__c a = new Application__c(
			RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get(RECORDTYPE).getRecordTypeId(),
			application_theme__c = THEME1,
			Application_Stage__c = STAGE,
			Full_Application_Status__c = DRAFT,
			Contact__c = c.Id,
			Contact_Email__c = EMAILADDRESS
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
    	// lcfgrants?id={application id}
    	// lcfgrantblock?form=lcf_grant_achievement_1&app=APP-01165&grant=GNT-0001
    	Application__c a = [SELECT Id, Name, Contact_Email__c FROM Application__c LIMIT 1];
		
        PageReference pageRef = Page.LCFGrants;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('id', a.Id);      
          
		Test.startTest();
		ApexPages.StandardController stdcon = new ApexPages.StandardController(a);
		LCFGrantsController con1 = new LCFGrantsController(stdcon);
		con1.newGrantAction();
    	LCF_Grant__c g = [SELECT Id, Name, Application__c, Contact_Email__c FROM LCF_Grant__c LIMIT 1];
    	
    	pageRef = Page.LCFGrantBlock;
    	Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('app', a.Name);      
        ApexPages.currentPage().getParameters().put('grant', g.Name);      
        ApexPages.currentPage().getParameters().put('form', 'lcf_grant_achievement_1'); 
             
    	LCFGrantBlockController con2 = new LCFGrantBlockController();
		con2.initialAction();
		con2.submit();
		con2.viewAll();
		
        ApexPages.currentPage().getParameters().put('section', 'lcf_grant_user_referral_1');      
    	LCFGrantBlockController con3 = new LCFGrantBlockController();
    	con3.initialAction();
		con3.start();
		con3.summaryPage();
     	
     	Test.stopTest();
     	Form_LCF_Grant_Achievement_1__c f = [SELECT Id, ab_approval_status__c FROM Form_LCF_Grant_Achievement_1__c LIMIT 1];    	
        system.assertEquals(SUBMITTED, f.ab_approval_status__c);
    }  
    
    
}