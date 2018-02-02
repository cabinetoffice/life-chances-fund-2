@isTest
private class SIB_NewApplicationControllerTest {
	private static final String THEME1 = 'Children\'s services';
	
	@testSetup static void initData(){
		Theme__c theme = DataFactory.insertTheme(THEME1);
		Application_Window__c aw = DataFactory.createAW(theme.Id);
		//Adding in this line so it go through all the available options on the new controller to find the correct template.
		//TO DO: Add multiple different AWT's and make sure it selects the correct one. For now, this will cover code (and I know the code works)
		aw.Is_Live__c = false;
		insert aw;
		Application_Window_Template__c awt = DataFactory.insertAWT(aw.Id);
		//It queries based on contact email address, so we must always set it equal to the user email running the test.
		DataFactory.insertContact(UserInfo.getUserEmail());
	}

	static testMethod void positiveTesting() {
		SIB_NewApplicationController controller = new SIB_NewApplicationController();
		System.assertEquals(1, controller.themeNameToIdMap.size());
		Theme__c theme = [
			SELECT Name, Id
			FROM Theme__c
			LIMIT 1
		];
		// System.assertEquals(theme.Name, controller.themeNameToIdMap.values()[0]);
		System.assertEquals(theme.Id, controller.themeNameToIdMap.values()[0]);
		ApexPages.currentPage().getParameters().put('valueToSet', theme.Id);
		System.assertEquals(null, controller.selectedTheme);
		controller.setValue();
		System.assertEquals(theme.Id, controller.selectedTheme);
		//Will always equal null as we are testing with a logged in user!
		System.assertEquals(null, controller.checkLoggedInStatus());
		System.assertEquals(0, [
			SELECT COUNT()
			FROM Application__c
		]);
		String startApplicationURL = controller.startApplication().getUrl();
		List<Application__c> apps = [
			SELECT Id
			FROM Application__c
		];
		System.assertEquals(1, apps.size());
		System.assertEquals('/apex/SIB_ApplicationForm?formType=Financial+health+and+fraud+prevention&id=' + apps[0].Id,startApplicationURL);

	}
	
}