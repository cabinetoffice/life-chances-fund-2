/**
 * COF_PageController
 * Cabinet Office Forms 1.0
 *
 * This abstract class is inherited by each Page Controller.
 */
public virtual class COF_PageController {
    
    //As with all the pages where we require a user to be logged in, we check here if the user is logged in, else return the homepage
    public PageReference checkLoggedInStatus(){
        return SIB_Utilities.checkLoggedInStatus();
    }

	/**
	 * Returns the application object based on the reference given in the "app" URL parameter
	 */
	public virtual SObject getApplication() {
        List<String> fields = new List<String>();
        fields.add('Name');
        fields.add('Theme__c');
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
	 * Returns the section identifier parameter
	 */
	public virtual String getPageIdentifierParam() {
		return this.getPageParam('page');
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