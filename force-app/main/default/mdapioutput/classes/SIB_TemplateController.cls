public with sharing class SIB_TemplateController {
	public List<Footer_Link__mdt> footerLinks{get;set;}

	/* 
		This method is used to set up the footer links on the visualforce page. These are stored in a custom metadata type.
		The only variable checked here is the checkbox "Active__c", to define whether these should show up. This is loaded on
		page load, as there will only need to be done the first time the template is loaded.
	*/
	public SIB_TemplateController(){
		footerLinks = [
			SELECT Label, URL__c, Target__c
			FROM Footer_Link__mdt
			WHERE Active__c = true
		];
	}
}