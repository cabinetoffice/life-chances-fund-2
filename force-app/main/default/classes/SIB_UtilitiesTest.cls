@isTest
private class SIB_UtilitiesTest {
	
	@testSetup static void initData(){
		Theme__c theme = DataFactory.insertTheme('Test Theme');
		Application_Window__c aw = DataFactory.insertAW(theme.Id);
		Application_Window_Template__c awt = DataFactory.insertAWT(aw.Id);
		Application_Form_Section__c afs = DataFactory.insertAFS('Test Section', 'Expression of Interest');
		Application_Question__c aq = DataFactory.insertAQ('First Name', 'Short Text', 'FirstName', 'Short_Text_Answer__c', '', '1');
		Application_Question_Template__c aqt = DataFactory.insertAQT(awt.Id, aq.Id, afs.Id);
	}

	static testMethod void positiveTesting() {
		System.assertEquals(false, SIB_Utilities.isValidEmail('test@'));
		System.assertEquals(false, SIB_Utilities.isValidEmail('test@test'));
		System.assertEquals(true, SIB_Utilities.isValidEmail('test@test.com'));
		System.assertNotEquals(null, SIB_Utilities.getRecordTypeId('Contact', 'Customer User'));
		System.assertEquals(Page.SIB_Login.getURL(), SIB_Utilities.returnHomePage().getURL());
		System.assertEquals('Id', SIB_Utilities.generateDefaultFields(null));
		System.assertEquals(null, SIB_Utilities.checkLoggedInStatus());
		Application_Window_Template__c awt = [
			SELECT Id
			FROM Application_Window_Template__c
			LIMIT 1
		];
		System.assertEquals('FirstName,Id', SIB_Utilities.generateDefaultFields(awt.Id));
        SIB_Utilities.returnHomePage();
	}
}