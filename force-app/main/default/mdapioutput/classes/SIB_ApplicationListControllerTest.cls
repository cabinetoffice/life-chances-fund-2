@isTest
private class SIB_ApplicationListControllerTest {
	
	static testMethod void testing() {
		// This is being run by a logged in user so will always return null.
		SIB_ApplicationListController controller = new SIB_ApplicationListController();
		System.assertEquals(null, controller.checkLoggedInStatus());
		//We haven't set any applications up at this point as we are just testing a query returning things, there is no need!
		System.assertEquals(0, controller.getApplications().size());
	}
}