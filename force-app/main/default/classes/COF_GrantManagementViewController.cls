/* _______________________________________________________________________________________________________________________
   Name:        COF_GrantManagementViewController.cls
   Description: Extension controller class for COF_GrantManagementView page (LCF Grant view override for Partner Users)
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________________
   Apr 2018     1.0     Michael Witchalls	Initial Release 
________________________________________________________________________________________________________________________ */        
public without sharing class COF_GrantManagementViewController {
    private String PARTNERUSER = 'PowerPartner';
    public String applicationId;
    public String idString {get;set;}
    private String userType; 
    private ApexPages.StandardController stdCon;
	     
    public COF_GrantManagementViewController(ApexPages.StandardController stdController) { 
    	this.stdCon = stdController;
		this.idString = ApexPages.currentPage().getParameters().get('id');   		
    	List<LCF_Grant__c> grants = [SELECT Name, Application__c, Application_ID__c FROM LCF_Grant__c WHERE Id = :this.idString];
    	if (grants.size() > 0) {
    		this.applicationId = grants[0].Application__c;
    		system.debug('@@@@this.applicationI: '+this.applicationId);
    	}
    	this.userType = [SELECT UserType FROM User WHERE Id = :UserInfo.getUserId()].UserType;
    }

    public PageReference getViewAction() {
    	if (this.userType != PARTNERUSER) {
    		PageReference nextPage = this.stdCon.view();
    		nextPage.getParameters().put('nooverride', '1');
	        nextPage.setRedirect(true);
	        return nextPage;
    	} else {
	        return viewForm();
    	}
	}

    public PageReference viewForm() {
    	PageReference nextPage = Page.LCFGrants;
	    nextPage.getParameters().put('id', this.applicationId);
        nextPage.setRedirect(true);
        return nextPage;
   }
}