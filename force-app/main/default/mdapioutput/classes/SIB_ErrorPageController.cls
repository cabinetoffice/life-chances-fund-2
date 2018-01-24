public class SIB_ErrorPageController {
	/*
		M.Witchalls Jan 2018: Show error details if user flag has been set
	*/
	public Boolean showErrors {get;set;}
	
	public SIB_ErrorPageController() {
		User u = [SELECT Profile.Name, Enable_Salesforce_Error_Display__c FROM User WHERE Id = :UserInfo.getUserId()];
		showErrors = u.Enable_Salesforce_Error_Display__c;
		system.debug('###Profile.Name: '+u.Profile.Name);
		if (u.Profile.Name == 'System Administrator') showErrors = true;
	}
    
}