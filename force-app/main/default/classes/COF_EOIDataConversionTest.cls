/* _______________________________________________________________________________________________________________
   Name:		COF_EOIDataConversionTest.cls
   Description: Test Class for COF_EOIDataConversionController and COF_EOIDataConversion
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Apr 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class COF_EOIDataConversionTest { 
	private static final String RECORDTYPE = 'Expression of Interest';
	private static final String THEME1 = 'Children\'s services';
	private static final String STAGE = 'Expression of Interest';
	private static final String DRAFT = 'Draft';
	private static final String OBJECTNAME = 'Form_LCF_EOI_1__c';
	private static final String FIELDNAME1 = 'lc_first_name__c';
	private static final String FIELDNAME2 = 'or_income_for_year__c';
	
	@testSetup static void setup() {   	
		// Create an Application
		Application__c a = new Application__c(
			RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get(RECORDTYPE).getRecordTypeId(),
			application_theme__c = THEME1,
			Application_Stage__c = STAGE,
			Status__c = DRAFT
		);
		insert a;
		// Create Application Questions
		List<Application_Question__c> questions = new List<Application_Question__c>{
			new Application_Question__c(Name = 'Test 1', Question_Number__c = 1, Question__c = 'Question 1', Question_Type__c = 'Short Text'),
			new Application_Question__c(Name = 'Test 2', Question_Number__c = 2, Question__c = 'Question 2', Question_Type__c = 'Currency')
		};
		insert questions;
		// Create Application Answers
		Application_Answer__c ans1 = new Application_Answer__c(
			Application__c = a.Id,
			Application_Question__c = questions[0].Id,
			Short_Text_Answer__c = 'Answer 1',
			Data_Conversion_Form__c = STAGE
		);
		Application_Answer__c ans2 = new Application_Answer__c(
			Application__c = a.Id,
			Application_Question__c = questions[1].Id,
			Currency_Answer__c = 200,
			Data_Conversion_Form__c = STAGE
		);
		List<Application_Answer__c> answers = new List<Application_Answer__c>{ans1, ans2};
		insert answers;
		// Create metadata
		List<SIB_Field_Metadata__c> mdList = new List<SIB_Field_Metadata__c>{
			new SIB_Field_Metadata__c(Object_Name__c = OBJECTNAME, Field_Name__c = FIELDNAME1, Help_Text__c = 'Question 1', Type__c = 'Text'),
			new SIB_Field_Metadata__c(Object_Name__c = OBJECTNAME, Field_Name__c = FIELDNAME2, Help_Text__c = 'Question 2', Type__c = 'Currency')
		};
		insert mdList;
		Application_Commissioner__c comm = new Application_Commissioner__c(
			Application__c = a.Id,
			Organisation_Name__c = 'Test Org',
			Is_Lead_Commissioner__c = 'Yes',
			Last_Name__c = 'Test Name'		
		);
		insert comm;
		Outcome__c outcome = new Outcome__c(
			Application__c = a.Id,
			Name = 'Test Outcome'
		);
		insert outcome;
		Previous_Application__c prevApp = new Previous_Application__c(
			Application__c = a.Id,
			Name = 'Old App'
		);
		insert prevApp;
	}
		
    @isTest static void testit() {
		
        PageReference pageRef = Page.COF_EOIDataConversion;
        Test.setCurrentPage(pageRef);     
        
		Test.startTest();
		COF_EOIDataConversionController con1 = new COF_EOIDataConversionController();
		con1.createEOIData();
		con1.createCommissioners();     	
     	con1.createOutcomes(); 
     	con1.createPreviousApps();
     	Test.stopTest();
     	
     	List<Form_LCF_EOI_1__c> eoiList = [
     		SELECT Name, lc_first_name__c, or_income_for_year__c
     		FROM Form_LCF_EOI_1__c
     	];
     	
      	system.assertEquals(1, eoiList.size());
     	system.assertEquals('Answer 1', eoiList[0].lc_first_name__c);
     	system.assertEquals(200, eoiList[0].or_income_for_year__c);

    }  
    
    
}