@isTest
private class SIB_ChangePasswordControllerTest {

	static testMethod void positiveTesting(){
		SIB_ChangePasswordController controller = new SIB_ChangePasswordController();
		controller.oldPassword = '123456';
		controller.newPassword = 'qwerty1'; 
		controller.verifyNewPassword = 'qwerty1';
		System.assertEquals(controller.changePassword(), null);
	}

	static testMethod void negativeTesting(){
		SIB_ChangePasswordController controller = new SIB_ChangePasswordController();
		controller.oldPassword = '123456';
		controller.newPassword = 'qwerty1'; 
		controller.verifyNewPassword = 'qwerty2';
		System.assertEquals(controller.changePassword(), null);
		System.assertEquals(null, controller.checkLoggedInStatus());
	}
}