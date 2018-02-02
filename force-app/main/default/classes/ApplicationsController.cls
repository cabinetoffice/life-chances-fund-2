/**
 * Applications Controller
 */
public with sharing class ApplicationsController extends COF_PageController {

	public COF_Form form {get;set;}
	public List<SObject> applications {get;set;} 

	public ApplicationsController() {			
		// M.Witchalls Jan 2018: Limit query to eligible applications
		//                       and also limit to applications owned if a Customer user
		//
		String constraint = 'WHERE Eligible_for_Full_Application__c = TRUE';
		User u = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
		if (u.ContactId != null) {
			constraint += ' AND Contact__c = \''+u.ContactId+'\'';
		}

		// Get the application
        List<String> fields = new List<String>();
        fields.add('Name');
        fields.add('Theme__c');
        fields.add('Full_Application_Status__c');
        this.applications = Query.objects('Application__c', fields, constraint);
        // throw exception
        System.debug(this.applications);
	}

//    public PageReference newApplication() {
//
//        PageReference nextPage = Page.new;
//        nextPage.setRedirect(true);
//        return nextPage;
//    }

}