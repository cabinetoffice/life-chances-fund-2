/* _______________________________________________________________________________________________________________
   Name:		COF_OutcomeMetricTriggerHandlerTest.cls
   Description: Test Class for COF_OutcomeMetricTriggerHandler
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   May 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class COF_OutcomeMetricTriggerHandlerTest { 
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
    	
		// Create a Grant Outcome
		Form_LCF_Grant_Outcome_1__c go = new Form_LCF_Grant_Outcome_1__c(lcf_grant__c = g.Id);
		insert go;
	}    
	
    @isTest static void testit() {
    	Form_LCF_Grant_Outcome_1__c go = [SELECT Id, ou_outcome_metrics__c FROM Form_LCF_Grant_Outcome_1__c LIMIT 1];
    	
    	Test.startTest();
		// Create Outcome Metrics
		Form_LCF_Outcome_Metric_1__c om1 = new Form_LCF_Outcome_Metric_1__c(
			grant_outcome__c = go.Id,
			om_description__c = 'Metric 1',
			om_individual_cohort__c = 'Individual'
		);
		Form_LCF_Outcome_Metric_1__c om2 = new Form_LCF_Outcome_Metric_1__c(
			grant_outcome__c = go.Id,
			om_description__c = 'Metric 2',
			om_individual_cohort__c = 'Cohort'
		);
		
		List<Form_LCF_Outcome_Metric_1__c> omList = new List<Form_LCF_Outcome_Metric_1__c>{om1, om2};
		insert omList;
		
		om2.om_individual_cohort__c = 'Individual'; 
		update omList;
		
		delete om1;
		undelete om1;
		Test.stopTest();
		
    	go = [SELECT Id, ou_outcome_metrics__c FROM Form_LCF_Grant_Outcome_1__c LIMIT 1];
    	Integer n1 = go.ou_outcome_metrics__c.indexOf('Individual');
    	Integer n2 = go.ou_outcome_metrics__c.lastIndexOf('Individual');
		system.assert(n2 > n1);
    }  
    
}