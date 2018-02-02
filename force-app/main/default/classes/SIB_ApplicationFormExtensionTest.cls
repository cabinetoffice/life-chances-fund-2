@isTest
private class SIB_ApplicationFormExtensionTest {
	@testSetup static void initData(){
		DataFactory.setUpFullApplication();
	}

	static testMethod void initialiseDataTesting() {
		SIB_ApplicationFormExtension controller = new SIB_ApplicationFormExtension();
		Application__c appToUse = getCurrentApplication();
		ApexPages.currentPage().getParameters().put('Id', appToUse.Id);
		ApexPages.currentPage().getParameters().put('formType', 'Expression+Of+Interest');   
        System.debug('URL:'+Page.SIB_ApplicationList.getUrl());
		//System.assertEquals(Page.SIB_ApplicationList.getUrl(), controller.initialiseData().getURL());
        System.debug('Theme:'+ApexPages.currentPage().getParameters().get('formType'));
		PageReference pr = controller.initialiseData();
		System.assertEquals(null, pr);
		System.assertEquals('Expression of interest application', controller.formDisplayName);
		System.assertEquals(0, controller.getHighestPageNumber());
		System.assertEquals(3, controller.objectNameToRecords.keySet().size());
		System.assertEquals('Status__c', controller.statusField);
		System.assertEquals('Draft', controller.currApp.get(controller.statusField));
		System.assertEquals(0, controller.branchQuestionMap.keySet().size());
		System.assertEquals(false, controller.disable);
		System.assertEquals(0, controller.getSWAnswers().keySet().size());
		controller.currApp.put(controller.statusField, 'Submitted');
		update controller.currApp;
		controller.initialiseData();
		System.assertEquals(true, controller.disable);
		controller.currApp.put(controller.statusField, 'Draft');
		update controller.currApp;
		controller.initialiseData();
		controller.viewAllAnswers();
		System.assertEquals(controller.formSection, 'ALL_QUESTIONS');
		System.assertEquals(8, controller.getSWAnswers().keySet().size());
		System.assertEquals(controller.additionalSectionToShow, 'Section Summary');
		System.assertEquals(controller.pageNumber, null);
		controller.previous();
		System.assertEquals(controller.formSection, '');
		System.assertEquals(controller.additionalSectionToShow, '');
		controller.additionalSectionToShow = 'Section Summary';
		controller.setFormSection();
		System.assertEquals('', controller.additionalSectionToShow);
		controller.getQWS();
		System.assertEquals(false, controller.hasNext);
		System.assertEquals(false, controller.hasPrevious);
		ApexPages.currentPage().getParameters().put('formSectionHeader', '1. Lead Contact');
		controller.setFormSection();
		System.assertEquals('1. Lead Contact', controller.formSection);
		System.assertEquals(5, controller.questionHolders.size());
		ApexPages.currentPage().getParameters().put('pageNumber', '1');
		controller.setPageNumber();
		System.assertEquals(1, controller.pageNumber);
		System.assertEquals(false, controller.hasPrevious);
		System.assertEquals(4, controller.getHighestPageNumber());
		controller.previous();
		System.assertEquals(null, controller.pageNumber);
		ApexPages.currentPage().getParameters().put('pageNumber', '4');
		controller.setPageNumber();
		System.assertEquals(false, controller.displayQuestionHelpText);
		controller.toggleDisplayQuestionHelpText();
		System.assertEquals(true, controller.displayQuestionHelpText);
		controller.saveAndContinue();
		System.assertEquals(false, controller.displayQuestionHelpText);
		System.assertEquals(null, controller.pageNumber);
		System.assertEquals('Section Summary', controller.additionalSectionToShow);
		controller.previous();
		System.assertEquals(controller.pageNumber, 4);
		controller.previous();
		System.assertEquals(controller.pageNumber, 3);
		controller.previous();
		System.assertEquals(controller.pageNumber, 2);
		controller.previous();
		System.assertEquals(controller.pageNumber, 1);
		controller.previous();
		System.assertEquals(controller.pageNumber, null);
		System.assertEquals('1. Lead Contact', controller.formSection);
		System.assertEquals(1, controller.getSWAnswers().keySet().size());
		controller.previous();
		System.assertEquals('', controller.formSection);
		ApexPages.currentPage().getParameters().put('sObjectType', 'Application_Commissioner__c');
		controller.generateSObject();
		System.assertEquals(controller.subPageNumber, 1);
		controller.nextSubPage();
		System.assertEquals(controller.subPageNumber, 2);
		controller.previous();
		System.assertEquals(controller.subPageNumber, 1);
		controller.previous();
		System.assertEquals(null, controller.subPageNumber);
		controller.pageNumber = 3;
		System.assertEquals(0, controller.getSObjectSize());
		ApexPages.currentPage().getParameters().put('formSectionHeader', '6. Commissioners');
		controller.setFormSection();
		controller.saveAndContinue();
		System.assertEquals('application commissioner', controller.getSObjectLabel().toLowerCase());
		controller.generateSObject();
		System.assertEquals(controller.subPageNumber, 1);
		controller.saveSObject();
		System.assertEquals(1, controller.getSObjectSize());
		System.assertEquals(null, controller.subPageNumber);
		System.assertEquals(null, controller.sObjectToCreate);
		ApexPages.currentPage().getParameters().put('pageNumber', '1');
		ApexPages.currentPage().getParameters().put('subPageNumber', '1');
		ApexPages.currentPage().getParameters().put('sObjectNumber', '0');
		ApexPages.currentPage().getParameters().put('sObjectName', 'Application_Commissioner__c');
		controller.setPageNumber();
		System.assertNotEquals(null, controller.sObjectToCreate);
		System.assertEquals(1, controller.subPageNumber);
		System.assertEquals(Page.SIB_ApplicationList.getURL(), controller.returnHomePage().getURL());
		Application_Question_Template__c randomAQT = [
			SELECT Application_Question__r.Id, Id
			FROM Application_Question_Template__c
			WHERE Application_Form_Section__r.Name = '6. Commissioners'
			LIMIT 1
		];
		controller.formSection = '6. Commissioners';
		System.assertEquals('', controller.getAnswerFromAQId(randomAQT.Application_Question__r.Id));
		ApexPages.currentPage().getParameters().put('answerType', 'Short_Text_Answer__c');
		ApexPages.currentPage().getParameters().put('answerToSet', 'Testing');
		ApexPages.currentPage().getParameters().put('aqtId', randomAQT.Id);
		controller.setAnswer();
		System.assertEquals(' Testing', controller.getAnswerFromAQId(randomAQT.Application_Question__r.Id));
		String longTextAnswer = '';
		for (Integer i = 0; i < 3300; i++){
			longTextAnswer += 'a';
		}
		ApexPages.currentPage().getParameters().put('answerType', 'Text_Answer__c');
		ApexPages.currentPage().getParameters().put('answerToSet', longTextAnswer);
		controller.setAnswer();
        controller.markSectionAsComplete();
		controller.currApp.put(controller.statusField, 'Submitted');
		update controller.currApp;
		controller.initialiseData();
		System.assertEquals(true, controller.disable);
		controller.upsertAnswer();
		System.assertEquals(9, ApexPages.getMessages().size());
		controller.saveAndContinueLater();
		System.assertEquals(null, controller.pageNumber);
		//Additional testing
		controller.generateRegionCBW();
        
        controller.saveAndSubmit();
	}
   
	static testMethod void initialiseDataTesting2() {
		SIB_ApplicationFormExtension controller = new SIB_ApplicationFormExtension();
		Application__c appToUse = getCurrentApplication();
        appToUse.Status__c = 'Successful';
        appToUse.Identity_Check_Status__c = 'Submitted';
        appToUse.Full_Application_Status__c = 'Draft';
        update appToUse;
		ApexPages.currentPage().getParameters().put('Id', appToUse.Id);
		ApexPages.currentPage().getParameters().put('formType', 'Full Application');   
        System.debug('URL:'+Page.SIB_ApplicationList.getUrl());
		//System.assertEquals(Page.SIB_ApplicationList.getUrl(), controller.initialiseData().getURL());
        System.debug('Theme:'+ApexPages.currentPage().getParameters().get('formType'));
		PageReference pr = controller.initialiseData();
		System.assertEquals(null, pr);
		System.assertEquals('Full application', controller.formDisplayName);
		System.assertEquals(0, controller.getHighestPageNumber());
		// System.assertEquals(3, controller.objectNameToRecords.keySet().size());
		System.assertEquals(1, controller.objectNameToRecords.keySet().size());
		System.assertEquals('Full_Application_Status__c', controller.statusField);
		System.assertEquals('Draft', controller.currApp.get(controller.statusField));
		System.assertEquals(0, controller.branchQuestionMap.keySet().size());
		System.assertEquals(false, controller.disable);
		System.assertEquals(0, controller.getSWAnswers().keySet().size());
		controller.currApp.put(controller.statusField, 'Submitted');
		update controller.currApp;
		controller.initialiseData();
		System.assertEquals(true, controller.disable);
		controller.currApp.put(controller.statusField, 'Draft');
		update controller.currApp;
		controller.initialiseData();
		controller.viewAllAnswers();
		System.assertEquals(controller.formSection, 'ALL_QUESTIONS');
		System.assertEquals(2, controller.getSWAnswers().keySet().size());
		System.assertEquals(controller.additionalSectionToShow, 'Section Summary');
		System.assertEquals(controller.pageNumber, null);
		controller.previous();
		System.assertEquals(controller.formSection, '');
		System.assertEquals(controller.additionalSectionToShow, '');
		controller.additionalSectionToShow = 'Section Summary';
		controller.setFormSection();
		System.assertEquals('', controller.additionalSectionToShow);
		controller.getQWS();
		System.assertEquals(false, controller.hasNext);
		System.assertEquals(false, controller.hasPrevious);
		ApexPages.currentPage().getParameters().put('formSectionHeader', '1. Overview of your project');
		controller.setFormSection();
		System.assertEquals('1. Overview of your project', controller.formSection);
		System.assertEquals(5, controller.questionHolders.size());
		ApexPages.currentPage().getParameters().put('pageNumber', '1');
		controller.setPageNumber();
		System.assertEquals(1, controller.pageNumber);
		System.assertEquals(false, controller.hasPrevious);
		System.assertEquals(3, controller.getHighestPageNumber());
		controller.previous();
		System.assertEquals(null, controller.pageNumber);
		ApexPages.currentPage().getParameters().put('pageNumber', '4');
		controller.setPageNumber();
		System.assertEquals(false, controller.displayQuestionHelpText);
		controller.toggleDisplayQuestionHelpText();
		System.assertEquals(true, controller.displayQuestionHelpText);
		controller.saveAndContinue();
		System.assertEquals(false, controller.displayQuestionHelpText);
		System.assertEquals(null, controller.pageNumber);
		System.assertEquals('Section Summary', controller.additionalSectionToShow);
		controller.previous();
		System.assertEquals(controller.pageNumber, 3);
		controller.previous();
		System.assertEquals(controller.pageNumber, 2);
		controller.previous();
		System.assertEquals(controller.pageNumber, 1);
		controller.previous();
		System.assertEquals(controller.pageNumber, null);
		System.assertEquals('1. Overview of your project', controller.formSection);
		System.assertEquals(1, controller.getSWAnswers().keySet().size());
		controller.previous();
		System.assertEquals('', controller.formSection);
		ApexPages.currentPage().getParameters().put('sObjectType', 'Primary_Outcome__c');
		controller.generateSObject();
		System.assertEquals(controller.subPageNumber, 1);
		controller.nextSubPage();
		System.assertEquals(controller.subPageNumber, 2);
		controller.previous();
		System.assertEquals(controller.subPageNumber, 1);
		controller.previous();
		System.assertEquals(null, controller.subPageNumber);
		controller.pageNumber = 3;
		System.assertEquals(0, controller.getSObjectSize());
		ApexPages.currentPage().getParameters().put('formSectionHeader', '5. Outcomes and payment triggers');
		controller.setFormSection();
		controller.saveAndContinue();
		System.assertEquals('primary outcome', controller.getSObjectLabel().toLowerCase());
		controller.generateSObject();
		System.assertEquals(controller.subPageNumber, 1);
		controller.saveSObject();
		System.assertEquals(1, controller.getSObjectSize());
		System.assertEquals(null, controller.subPageNumber);
		System.assertEquals(null, controller.sObjectToCreate);
		ApexPages.currentPage().getParameters().put('pageNumber', '1');
		ApexPages.currentPage().getParameters().put('subPageNumber', '1');
		ApexPages.currentPage().getParameters().put('sObjectNumber', '0');
		ApexPages.currentPage().getParameters().put('sObjectName', 'Primary_Outcome__c');
		controller.setPageNumber();
		System.assertNotEquals(null, controller.sObjectToCreate);
		System.assertEquals(1, controller.subPageNumber);
		System.assertEquals(Page.SIB_ApplicationList.getURL(), controller.returnHomePage().getURL());
		Application_Question_Template__c randomAQT = [
			SELECT Application_Question__r.Id, Id
			FROM Application_Question_Template__c
			WHERE Application_Form_Section__r.Name = '5. Outcomes and payment triggers'
			LIMIT 1
		];
		controller.formSection = '5. Outcomes and payment triggers';
		System.assertEquals('', controller.getAnswerFromAQId(randomAQT.Application_Question__r.Id));
		ApexPages.currentPage().getParameters().put('answerType', 'Short_Text_Answer__c');
		ApexPages.currentPage().getParameters().put('answerToSet', 'Testing');
		ApexPages.currentPage().getParameters().put('aqtId', randomAQT.Id);
		controller.setAnswer();
		System.assertEquals(' Testing', controller.getAnswerFromAQId(randomAQT.Application_Question__r.Id));
		String longTextAnswer = '';
		for (Integer i = 0; i < 33000; i++){
			longTextAnswer += 'a';
		}
		ApexPages.currentPage().getParameters().put('answerType', 'Text_Answer__c');
		ApexPages.currentPage().getParameters().put('answerToSet', longTextAnswer);
		controller.setAnswer();

	    controller.upsertAnswer();
//        controller.initialiseData();
		ApexPages.currentPage().getParameters().put('sObjectType', 'Primary_Outcome__c');
		controller.generateSObject();        
        ApexPages.currentPage().getParameters().put('childSObjectType', 'Outcome_Payment_Trigger__c');
        List<SIB_ApplicationFormExtension.ApplicationQuestionHolder> qws = controller.getqws();
       
        controller.generatecOfChildSObject();
        controller.setSubPageNumber();
        Integer int1 = controller.getcOfChildSObjectSize();
        String str1 = controller.getcOfchildSObjectLabel();        
        controller.getHasChild();
        
        controller.saveAndContinueLater();
		System.assertEquals(null, controller.pageNumber);
		//Additional testing
		controller.generateRegionCBW();
        Application_Answer__c aw = [Select Id From Application_Answer__c Limit 1];
        ApexPages.currentPage().getParameters().put('ansId', aw.Id);
        ApexPages.currentPage().getParameters().put('attachName', 'FiletoLoad');
        controller.showMessage();
        controller.updAttachment();
        // String displayFields = SIB_ApplicationFormExtension.getFieldsToDisplay();
        // controller.saveAndSubmit();
        Application_Question_Template__c aqt = new Application_Question_Template__c();
        Application_Answer__c applicationAnswer = new Application_Answer__c();
        // SIB_ApplicationFormExension.ApplicationQuestionHolder aqh = new SIB_ApplicationFormExension.ApplicationQuestionHolder(aqt, applicationAnswer, appToUse);
        SIB_ApplicationFormExtension.ApplicationQuestionHolder aqhWithChildRecord = controller.returnAQHWithChildRecord();
        String s = aqhWithChildRecord.getFieldsToDisplay();
        
        Application__c app = new Application__c();
        ApexPages.StandardController ssc = new ApexPages.StandardController(app);
        SIB_ApplicationFormExtension controller2 = new SIB_ApplicationFormExtension(ssc);
	}
    
	private static Application__c getCurrentApplication(){
		return [
			SELECT Id
			FROM Application__c
			LIMIT 1
		];
	}
}