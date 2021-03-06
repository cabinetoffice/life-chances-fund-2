/**
 * COF_PageController
 * Cabinet Office Forms 1.0
 *
 * This abstract class is inherited by each Page Controller.
 */
public virtual class COF_PageController {
	private static final String DRAFT = 'DRAFT';

	public String getPageName() {
		return ApexPages.currentPage().getUrl().substringAfterLast('/').substringBefore('?');
	}
    
    //As with all the pages where we require a user to be logged in, we check here if the user is logged in, else return the homepage
    public PageReference checkLoggedInStatus(){
    	return SIB_Utilities.checkLoggedInStatus();
    }
    
    public PageReference checkLoggedInAndApplicationStatus() {
    	if (SIB_Utilities.checkLoggedInStatus() != null) {
    		return SIB_Utilities.checkLoggedInStatus();
    	// Disallow access to pages if Full Application Form is not in 'Draft' status: go to Sections page
    	} else if (this.getApplicationIdentifierParam()!= null && this.getFormIdentifierParam()!= null) {
    		SObject application = this.getApplication();
	    	if (this.getFullApplicationStatus(application)!= DRAFT) {
		        PageReference nextPage = Page.Sections;
		        nextPage.getParameters().put('form', this.getFormIdentifierParam());
		        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
		        return nextPage;
	    	}
    	}
		return null;
    }

    public virtual String getFullApplicationStatus(SObject application) {
    	String status = (String)application.get('Full_Application_Status__c');
    	return (status == null) ? DRAFT : status.toUpperCase();
    }

	/**
	 * Returns the application object based on the reference given in the "app" URL parameter
	 */
	public virtual SObject getApplication() {
        List<String> fields = new List<String>();
        fields.add('Name');
        fields.add('Theme__c');
        fields.add('Full_Application_Status__c');
        // need to ensure this respects permissions - only the owner of an application should be able to access it
        return Query.object('Application__c', fields, 'WHERE Name = \'' + this.getApplicationIdentifierParam() + '\'');
        // Query class will throw exception if no matches
	}

	/**
	 * Returns the section identifier parameter
	 */
	public virtual String getApplicationIdentifierParam() {
		return this.getPageParam('app');
	}

	/**
	 * Returns the section identifier parameter
	 */
	public virtual String getRecordIdentifierParam() {
		return this.getPageParam('id');
	}

	/**
	 * Returns the form identifier parameter
	 */
	public virtual String getFormIdentifierParam() {
		return this.getPageParam('form');
	}

	/**
	 * Returns the section identifier parameter
	 */
	public virtual String getSectionIdentifierParam() {
		return this.getPageParam('section');
	}

	/**
	 * Returns the page identifier parameter
	 */
	public virtual String getPageIdentifierParam() {
		return this.getPageParam('page');
	}

	/**
	 * Returns the previous page identifier parameter
	 */
	public virtual String getPreviousPageIdentifierParam() {
		return this.getPageParam('previousPage');
	}

	/**
	 * Returns a page URL parameter given an identifier
	 */
	public virtual String getPageParam(String identifier) {
		String param = ApexPages.currentPage().getParameters().get(identifier);
		if (param != null)
			return param;
		return null;
	}

	/**
	 * Determines whether the current user has successfully logged in 
	 */
	public Boolean isAuthorisedUser() {
		return true;
	}
}