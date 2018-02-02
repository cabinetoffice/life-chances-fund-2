@isTest
private class SIB_SelfRegControllerTest {

	@testSetup static void initData(){
		Theme__c theme = DataFactory.insertTheme('Test Theme');
	}

	static testMethod void pageNumberTesting() {
		SIB_SelfRegController controller = new SIB_SelfRegController();
		System.assertEquals(1, controller.pageNumber);
		System.assertEquals(1, controller.nameToCBW.get('themes').size());
		System.assertNotEquals(0, controller.types.size());
		System.assertNotEquals(0, controller.nameToCBW.get('regions').size());

		//Testing nextPage method on page 1
		controller.nextPage();
		System.assertEquals(1, controller.pageNumber);
		System.assertEquals('Please add email', ApexPages.getMessages()[0].getDetail());
		controller.email = 'test@test';
		controller.nextPage();
		System.assertEquals(1, controller.pageNumber);
		System.assertEquals('Please enter a valid email address', ApexPages.getMessages()[1].getDetail());
		controller.email = 'testemailaddress@testemailaddress.com';
		controller.nextPage();
		System.assertEquals(1, controller.pageNumber);
		System.assertEquals('Please add Organisation Name', ApexPages.getMessages()[2].getDetail());
		controller.pageNumber = 2;
		controller.typeSelected = 'Other';
		controller.nextPage();
		System.assertEquals(2, controller.pageNumber);
		System.assertEquals('Please fill out \'If you chose other, please explain\' if you selected \'Other\' for organisation type', ApexPages.getMessages()[3].getDetail());
		ApexPages.currentPage().getParameters().put('selectedType', 'Different');
		controller.setRadioAnswer();
		System.assertEquals(controller.typeSelected, 'Different');
		controller.nextPage();
		System.assertEquals(3, controller.pageNumber);
		controller.previousPage();
		System.assertEquals(2, controller.pageNumber);
	}

	static testMethod void registerUserTesting(){
		SIB_SelfRegController controller = new SIB_SelfRegController();
		controller.firstName = 'First';
		controller.lastName = 'Last';
		controller.typeSelected = 'Other';
		controller.organisationName = 'Testing';
		//Using this so we can check that a user has already been used with this email address;
		controller.email = UserInfo.getUserEmail();
		controller.registerUser();
		System.assertEquals(1, ApexPages.getMessages().size());
		System.assertEquals('This email has already been used to register on the community.', ApexPages.getMessages()[0].getDetail());
		controller.nameToCBW.get('themes')[0].isSelected = true;
		controller.email = 'testtesttesttesttesttesttest@test.com';
		controller.typeSelected = 'Different';
		controller.organisationName = 'Test Org';
		controller.registerUser();
		System.assertEquals(1, [
			SELECT COUNT()
			FROM Account
			WHERE Name = 'Test Org'
		]);
		System.assertEquals(1, [
			SELECT COUNT()
			FROM Theme_Interest__c
		]);
	}


}