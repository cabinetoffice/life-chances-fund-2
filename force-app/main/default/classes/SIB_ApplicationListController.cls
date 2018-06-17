public with sharing class SIB_ApplicationListController {
	/*
		M.Witchalls Jan 2018: Divert to new Applications page if eligible for Full Application
	*/
	private Boolean eligible = true;
	private Boolean eligibleForGrant = false;
	private ID contactId;
	
	public SIB_ApplicationListController() {
		User u = [SELECT ContactId, Eligible_for_Full_Application__c, Eligible_for_Full_Award_Setup__c, Eligible_for_NEW_EOI_Form__c, Eligible_for_LCF_Grant__c FROM User WHERE Id = :UserInfo.getUserId()];
		eligible = u.Eligible_for_Full_Application__c;
		eligibleForGrant = u.Eligible_for_LCF_Grant__c;
		contactId = u.ContactId;
	}
	
    //As with all the pages where we require a user to be logged in, we check here if the user is logged in, else return the homepage
    public PageReference checkLoggedInStatus(){
    	PageReference nextPage = SIB_Utilities.checkLoggedInStatus();
    	if (nextPage == Page.SIB_Login || !eligible) {
    		return nextPage;
    	} else if (eligibleForGrant) {
    		return Page.LCFGrants;
    	} else {
    		return Page.Applications;
    	}
    }
    /*
        This method returns all applications. Because of how security is set up and the "with sharing" setting, 
        we dont need to worry about hiding other applications from other users.
    */
    public List<Application__c> getApplications(){
    	if (contactId != null) {// Customer user
	    	return [
	            SELECT Id, Status__c, Theme__c, Application_Stage__c, Name, 
	            EOI_External_Status__c, Dev_Form_External_Status__c, Full_Application_External_Status__c, Identity_Check_External_Status__c
	            FROM Application__c
	            WHERE Contact__c = :contactId
	            ORDER BY Theme__c
	    	];
    	} else {// internal user (testing on limited data)
	        return [
	            SELECT Id, Status__c, Theme__c, Application_Stage__c, Name, 
	            EOI_External_Status__c, Dev_Form_External_Status__c, Full_Application_External_Status__c, Identity_Check_External_Status__c
	            FROM Application__c
	            ORDER BY Theme__c
	        ];
    	}
    }
}