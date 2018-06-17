/**
 * COF_PageController
 * Cabinet Office Forms 1.0
 *
 * This abstract class is inherited by each Page Controller.
 */
public virtual class COF_PageController {
	private static final String CONTENTDOCURL = '/communityprefix/sfc/servlet.shepherd/version/download';
	private static final String EOISTATUS = 'Status__c';
	private static final String FULLAPPSTATUS = 'Full_Application_Status__c';
	private static final String SETUPSTATUS = 'Full_Award_Setup_Status__c';
	private static final String DRAFT = 'DRAFT';
	private static final String NOTSTARTED = 'NOT STARTED';
	private static final String SUBMITTED = 'Submitted';
	private static final String APPROVED = 'Approved';
	private static final String ISSUED = 'Issued';
    private static final String PARTNERUSERTYPE = 'PowerPartner';
    private static final String CUSTOMERUSERTYPE = 'PowerCustomerSuccess';
    private static final List<String> FINANCEFIELDS = new List<String>{
    	'Full_App_Commissioner_Savings__c',
    	'Full_App_Commissioner_Benefits__c',
    	'Full_App_Other_Party_Savings__c',
    	'Full_App_Other_Party_Benefits__c',
    	'Full_App_Outcome_Payments__c',
    	'Full_App_LCF_Contribution__c'
    };
    private static final String PROJECT = 'PROJECT';
    private static final String FUNDING = 'FUNDING';
    private static final List<String> BLOCKSTATUSFIELDS = new List<String>{
    	'bb_block_status__c',
    	'ab_block_status__c',
    	'pp_block_status__c',
    	'am_block_status__c'
    };
    private String userType; 
    private String communityURLPrefix;
    
    public String getContentURL() {
    	if (this.getCommunityPrefix() != null) {
    		return CONTENTDOCURL.replace('communityprefix', this.getCommunityPrefix());
    	} else {
    		return CONTENTDOCURL.replace('communityprefix/','');
    	}
    }
    
    public String getCommunityPrefix() {
    	if (this.getCustomerUser() || this.getPartnerUser()) {
	    	if (this.communityURLPrefix == null) {
	    		this.communityURLPrefix = [SELECT Network.UrlPathPrefix FROM NetworkMember WHERE MemberId = :UserInfo.getUserId()].Network.UrlPathPrefix;
	    	}
	    	//system.assert(false, communityURLPrefix);
	    	return communityURLPrefix;
    	} else {
    		return null;
    	}
    }

	public Boolean getPartnerUser() {
		if (this.userType == null) {
    		this.userType = [SELECT UserType FROM User WHERE Id = :UserInfo.getUserId()].UserType;
		}
    	return (userType == PARTNERUSERTYPE);	
	}

	public Boolean getCustomerUser() {
		if (this.userType == null) {
    		this.userType = [SELECT UserType FROM User WHERE Id = :UserInfo.getUserId()].UserType;
		}
		system.debug('@@@@@userType: '+userType+' '+(userType==CUSTOMERUSERTYPE));
    	return (userType == CUSTOMERUSERTYPE);	
	}
	
	public String getPageName() {
		return ApexPages.currentPage().getUrl().substringAfterLast('/').substringBefore('?');
	}
    
    //As with all the pages where we require a user to be logged in, we check here if the user is logged in, else return the homepage
    public PageReference checkLoggedInStatus(){
    	return SIB_Utilities.checkLoggedInStatus();
    }
    
    // M.Witchalls Apr 2018: for readonly view (if application form not in 'Draft' status, or for grant forms, not submitted for approval or approved)        
   	public Boolean getReadOnlyMode(SObject application, COF_Form form, SObject grantObject) {
   		return getReadOnlyMode(application, form, grantObject, null);
   	}
   	
   	public Boolean getReadOnlyMode(SObject application, COF_Form form, SObject grantObject, String parentRelationship) {
        String grantIdentifier = this.getGrantIdentifierParam();
   		if (String.isBlank(grantIdentifier)) {
   			return getAppReadOnlyMode(application, form);
   		} else {
   			return getGrantReadOnlyMode(grantObject, form, parentRelationship);
   		}
   	}
   	
    public Boolean getAppReadOnlyMode(SObject application, COF_Form form) {
		return (this.getFormStatus(application, form)!= DRAFT);
    } 
   	
    public Boolean getGrantReadOnlyMode(SObject grantObject, COF_Form form, String parentRelationship) {
    	String editUsers = form.users_able_to_edit;
		if (editUsers != null) {
			editUsers = editUsers.toUpperCase();
	   		if (this.getCustomerUser() && !editUsers.contains(PROJECT)) {
	   			return true;
	   		} else if (this.getPartnerUser() && !editUsers.contains(FUNDING)) {
	   			return true;
			}
   		}   		
		if (grantObject != null) {
			String status;
			system.debug('@@@@parentRelationship: '+parentRelationship);
			if (parentRelationship != null) {
				if (form.issue_status_field != null) { 
					status = (String)grantObject.getSObject(parentRelationship).get(form.issue_status_field);
				} else {
					status = (String)grantObject.getSObject(parentRelationship).get(form.approval_status_field);
				}
			} else {
				if (form.issue_status_field != null) { 
		        	status = (String)grantObject.get(form.issue_status_field);
				} else {
		        	status = (String)grantObject.get(form.approval_status_field);
				}
			}
	    	return (status == SUBMITTED || status == APPROVED || status == ISSUED);
		} else {
			return false;
		}
    } 

    public virtual String getFormStatus(SObject record, COF_Form form) {
    	String status;
    	if (record.getSObjectType() == Application__c.sObjectType) {
	    	status = (String)record.get(form.application_status_field);
	    	if (status == null) status = DRAFT;
    	} else if (record.getSObjectType() == LCF_Grant__c.sObjectType) {
	    	status = (String)record.get(form.block_status_field);
	    	if (status == null) status = NOTSTARTED;    		
    	}
    	return status.toUpperCase(); 
    }

	/**
	 * Returns the application object based on the reference given in the "app" URL parameter
	 */
	public virtual SObject getApplication() {
        List<String> fields = new List<String>();
        fields.add('Name');
        fields.add('Theme__c');
        fields.add(EOISTATUS);
        fields.add(FULLAPPSTATUS);
        fields.add(SETUPSTATUS);
        fields.add('Contact__r.Name');
        fields.addAll(FINANCEFIELDS);
        
        String applicationIdentifier = this.getApplicationIdentifierParam();
        String grantIdentifier = this.getGrantIdentifierParam();
        if (!String.isBlank(applicationIdentifier)) {
        	return Query.object('Application__c', fields, 'WHERE Name = \'' + applicationIdentifier + '\'');
        } else if (!String.isBlank(grantIdentifier)) {
        	return Query.object('Application__c', fields, 'WHERE Id IN (SELECT Application__c FROM LCF_Grant__c WHERE Name = \'' + grantIdentifier + '\')');
        } else {
        	return null;
        }
        // Query class will throw exception if no matches
	}

	/**
	 * Returns the grant object based on the reference given in the "grant" URL parameter
	 */
	public virtual SObject getGrant() {
		String grantIdentifier = this.getGrantIdentifierParam();
		if (!String.isBlank(grantIdentifier)) {
	        List<String> fields = new List<String>();
	        fields.add('Name');
	        fields.add('Theme__c');
	        fields.add('Status__c');
	        fields.add('Application__c');
	        fields.add('Application_ID__c');
	        fields.addAll(BLOCKSTATUSFIELDS);
	        fields.add('Contact__r.Name');
	        fields.add('OwnerId');
	        return Query.object('LCF_Grant__c', fields, 'WHERE Name = \'' + grantIdentifier + '\'');
	        // Query class will throw exception if no matches
		} else {
			return null;
		}
	}

	/**
	 * Returns the application identifier parameter value
	 */
	public virtual String getApplicationIdentifierParam() {
		return this.getPageParam('app');
	}

	/**
	 * Returns the grant identifier parameter value
	 */
	public virtual String getGrantIdentifierParam() {
		return this.getPageParam('grant');
	}

	/**
	 * Returns the record identifier parameter value
	 */
	public virtual String getRecordIdentifierParam() {
		return this.getPageParam('id');
	}

	/**
	 * Returns the form identifier parameter value
	 */
	public virtual String getFormIdentifierParam() {
		return this.getPageParam('form');
	}

	/**
	 * Returns the section identifier parameter value
	 */
	public virtual String getSectionIdentifierParam() {
		return this.getPageParam('section');
	}

	/**
	 * Returns the page identifier parameter value
	 */
	public virtual String getPageIdentifierParam() {
		return this.getPageParam('page');
	}

	/**
	 * Returns the previous page identifier parameter value
	 */
	public virtual String getPreviousPageIdentifierParam() {
		return this.getPageParam('previousPage');
	}

	/**
	 * Returns the fromForm identifier parameter value
	 */
	public virtual String getFromFormIdentifierParam() {
		return this.getPageParam('fromForm');
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