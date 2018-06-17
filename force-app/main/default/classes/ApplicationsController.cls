/* __________________________________________________________________________________________________________________
   Name:		ApplicationsController.cls
   Description: Controller class for Applications page
					
   Date         Version Author          		Summary of Changes 
   ___________  _______ __________________		_____________________________________________________________________
   2017		    1.0    	Cabinet Office			Initial Release 
   Jan 2018		1.1		M.Witchalls, Westbrook	Limit query to eligible applications
												and also limit to applications owned if a Customer user
   Feb 2018		1.2		M.Witchalls, Westbrook 	Inclusion of Setup form
   Mar 2018		1.3		M.Witchalls, Westbrook	Inclusion of new EOI form											
__________________________________________________________________________________________________________________ */        
public with sharing class ApplicationsController extends COF_PageController {

	public COF_Form form {get;set;}
	public List<SObject> applications {get;set;} 
	// M.Witchalls Feb 2018: Show Setup Form link if eligible
	public Boolean eligibleForSetup {get;set;}
	public Boolean eligibleForNewEOI {get;set;}
	public Boolean eligibleForGrant	{get;set;}
    public String idString {get;set;}
	
	public ApplicationsController() {			
		// M.Witchalls Jan 2018: Limit query to eligible applications
		//                       and also limit to applications owned if a Customer user
		//
		String constraint = 'WHERE (Eligible_for_Full_Application__c = TRUE OR Eligible_for_NEW_EOI_Form__c = TRUE)';
		User u = [SELECT ContactId, Eligible_for_Full_Application__c, Eligible_for_Full_Award_Setup__c, Eligible_for_NEW_EOI_Form__c, Eligible_for_LCF_Grant__c FROM User WHERE Id = :UserInfo.getUserId()];
		eligibleForSetup = u.Eligible_for_Full_Award_Setup__c;
		eligibleForNewEOI = u.Eligible_for_NEW_EOI_Form__c;
		eligibleForGrant = u.Eligible_for_LCF_Grant__c;
		system.debug('###eligibleForSetup: '+eligibleForSetup);
		
		this.idString = ApexPages.currentPage().getParameters().get('id');   		
		if (String.isNotBlank(this.idString)) {
			constraint = 'WHERE Id = \''+this.idString+'\'';
		} else {
			if (u.ContactId != null) {
				constraint += ' AND Contact__c = \''+u.ContactId+'\'';
			}
		}
		
		// Get the application
        List<String> fields = new List<String>();
        fields.add('Name');
        fields.add('Theme__c');
        fields.add('Full_Application_Status__c');
        fields.add('Full_Award_Setup_Status__c');
        fields.add('Status__c');
        fields.add('Application_Stage__c');
        this.applications = Query.objects('Application__c', fields, constraint);
        // throw exception
        System.debug('###applications: '+this.applications);
	}

//    public PageReference newApplication() {
//
//        PageReference nextPage = Page.new;
//        nextPage.setRedirect(true);
//        return nextPage;
//    }

}