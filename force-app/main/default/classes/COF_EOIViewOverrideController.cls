/* _______________________________________________________________________________________________________________________
   Name:        COF_EOIViewOverrideController.cls
   Description: Extension controller class for COF_EOIViewOverride page (detail view override for Partner Users)
   				and COF_EOIFormView page (direct access to form)
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________________
   Apr 2018     1.0     Michael Witchalls	Initial Release 
________________________________________________________________________________________________________________________ */        
public without sharing class COF_EOIViewOverrideController {
    private String FORM = 'lcf_eoi_1';
    private String PARTNERUSER = 'PowerPartner';
    public String appId;
    private String idString;
    private String userType; 
    private ApexPages.StandardController stdCon;
	     
    public COF_EOIViewOverrideController(ApexPages.StandardController stdController) { 
    	this.stdCon = stdController;
		this.idString = ApexPages.currentPage().getParameters().get('id');   		
    	List<Form_LCF_EOI_1__c> forms = [SELECT Application__r.Name FROM Form_LCF_EOI_1__c WHERE Id = :this.idString];
    	if (forms.size() > 0) {
    		this.appId = forms[0].Application__r.Name;
    		system.debug('@@@@this.appId: '+this.appId);
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
    	PageReference nextPage = Page.Sections;
	    nextPage.getParameters().put('app', this.appId);
	    nextPage.getParameters().put('form', this.FORM);
        nextPage.setRedirect(true);
        return nextPage;
   }
}