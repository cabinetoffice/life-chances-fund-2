/* _______________________________________________________________________________________________________________
   Name:		COF_ContentVersionTriggerHandlerTest.cls
   Description: Test Class for COF_ContentVersionTriggerHandler
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Mar 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */        
@isTest
private class COF_ContentVersionTriggerHandlerTest { 
	private static final String RECORDTYPE = 'Full Application';
	private static final String THEME1 = 'Children\'s services';
	private static final String STAGE = 'Full Application';
	private static final String DRAFT = 'Draft';
 	private static final String FILENAME1 = 'textme1.txt';
	private static final String FILEDATA1 = 'TEST DATA 1';
 	private static final String FILENAME2 = 'textme2.txt';
	private static final String FILEDATA2 = 'TEST DATA 2';
	
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
			application__c = a.Id
		);
		insert f;
	}    
	
    @isTest static void testit() {
    	Form_LCF_Full_App_1__c f = [SELECT Id, Name FROM Form_LCF_Full_App_1__c LIMIT 1];

    	Test.startTest();
		// create two file versions for the same content document
		ContentVersion cv1 = new ContentVersion(			
	    	Title = FILENAME1,
	    	PathOnClient = '/'+FILENAME1,
	    	VersionData = EncodingUtil.base64Decode(FILEDATA1),
	    	SIB_Form_ID__c = f.Id
		);
		insert cv1;
		cv1 = [SELECT Id, ContentDocumentId, VersionNumber FROM ContentVersion WHERE Id = :cv1.Id];	
		ContentVersion cv2 = new ContentVersion(
			ContentDocumentId = cv1.ContentDocumentId,
	    	Title = FILENAME2,
	    	PathOnClient = '/'+FILENAME2,
	    	VersionData = EncodingUtil.base64Decode(FILEDATA2),
	    	SIB_Form_ID__c = null
		);
		insert cv2;
		Test.stopTest();
		
		cv2 = [SELECT Id, ContentDocumentId, VersionNumber FROM ContentVersion WHERE Id = :cv2.Id];	
		system.assertEquals('2', cv2.VersionNumber);
		
		List<ContentDocumentLink> linkList = [
			SELECT Id, LinkedEntityId FROM ContentDocumentLink 
			WHERE ContentDocumentId = :cv2.ContentDocumentId
		];
		system.debug('###linkList: '+linkList);
		system.assertEquals(2, linkList.size());
		for (ContentDocumentLink link: linkList) {
			if (link.LinkedEntityId != UserInfo.getUserId()) system.assertEquals(f.Id, link.LinkedEntityId);
		}
    }  
    
}