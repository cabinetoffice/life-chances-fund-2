public with sharing class SIB_ChangePasswordController {
	public String oldPassword {get; set;}
	public String newPassword {get; set;}
	public String verifyNewPassword {get; set;}
	
	//As with all the pages where we require a user to be logged in, we check here if the user is logged in, else return the homepage
	public PageReference checkLoggedInStatus(){
        return SIB_Utilities.checkLoggedInStatus();
    }

    /*
    	Uses standard Salesforce Site "ChangePassword" method to change password. This has been used to maintain consistency if anything
    	in the Salesforce methods change and also to reduce on code overheads and maintenance.
	*/
	public PageReference changePassword() {
		return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
	}
}