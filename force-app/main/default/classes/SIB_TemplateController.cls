public with sharing class SIB_TemplateController {
	private static final String LCF = 'Life Chances Fund';
	public List<Footer_Link__mdt> footerLinks{get;set;}
	public SIB_Information__c sibInfo {get;set;}
	public Boolean isPdf {get;set;}
 
	/* 
		This method is used to set up the footer links on the visualforce page. These are stored in a custom metadata type.
		The only variable checked here is the checkbox "Active__c", to define whether these should show up. This is loaded on
		page load, as there will only need to be done the first time the template is loaded.
	*/
	public SIB_TemplateController(){
		this.footerLinks = [
			SELECT Label, URL__c, Target__c 
			FROM Footer_Link__mdt
			WHERE Active__c = true
		];
		
		// Michael Witchalls Feb 2018: Extract LCF rich text from the SIB_Information object		
		List<SIB_Information__c> sibList = [
			SELECT 
				Data_Protection_Text__c, Freedom_of_Information_Act_Text__c, 
				(SELECT Name, Key__c, Object_Name__c, Text__c FROM Section_Text__r) 		
			FROM 
				SIB_Information__c 
			WHERE
				Name = :LCF
		]; 
		if (sibList.size() > 0) { 
			this.sibInfo = sibList[0];
			// Prevent email links from popping a new screen
			for (SIB_Section_Text__c st: sibInfo.Section_Text__r) {
				st.Text__c = st.Text__c.replace('target="_blank"','target="_self"');
			}
		}
		
		// Michael Witchalls May 2018: Determine whether the page is to be rendered as pdf from the page name
		String pageName = ApexPages.currentPage().getUrl().substringAfterLast('/').substringBefore('?');
		this.isPdf = (pageName == 'Answers' || pageName.toLowerCase().contains('pdf'));
	}
}