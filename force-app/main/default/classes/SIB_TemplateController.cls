public with sharing class SIB_TemplateController {
	private static final String LCF = 'Life Chances Fund';
	public List<Footer_Link__mdt> footerLinks{get;set;}
	public Project__c project {get;set;}

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
		
		List<Project__c> projectList = [
			SELECT 
				Data_Protection_Text__c, Freedom_of_Information_Act_Text__c, Declaration_Text__c 
			FROM 
				Project__c 
			WHERE
				Name = :LCF
		];
		if (projectList.size() > 0) project = projectList[0];
	}
}