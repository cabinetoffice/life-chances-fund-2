/* _______________________________________________________________________________________________________________
   Name:		COF_CommissionerTriggerHandler.cls
   Description: Trigger actions on Form_LCF_Commissioner records
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Mar 2018		1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */
      
public class COF_CommissionerTriggerHandler {
	
	/*
	 *	Purpose: Copy full application primary commissioner fields to parent application record
	 *	History: 
	 *		Mar 2018: Michael Witchalls: Initial Release
	 *
	 */
	public void copyPrimaryCommssionerFields(List<Form_LCF_Commissioner_1__c> itemList) {
		
		Map<ID, Application__c> applicationMap = new Map<ID, Application__c>();
		for (Form_LCF_Commissioner_1__c item: itemList) {
			if (item.primary__c && item.st_organisation_name__c != null) {
				Application__c a = new Application__c(
					Id = item.application__c
				);
				if (item.full_application__c != null) {
					a.Full_App_Primary_Commissioner__c = item.st_organisation_name__c;
					a.Full_App_Primary_Commissioner_Region__c = item.st_organisation_region__c;
				}
				if (item.eoi__c != null) {
					a.EOI_Primary_Commissioner__c = item.st_organisation_name__c;
					a.EOI_Primary_Commissioner_Region__c = item.st_organisation_region__c;
				}		
				if (item.full_award_setup__c != null) {
					a.Setup_Primary_Stakeholder__c = item.st_organisation_name__c;
					a.Setup_Primary_Stakeholder_Region__c = item.st_organisation_region__c;
				}		
				applicationMap.put(a.Id, a);
			}
		}
		
		system.debug('@@applicationMap: '+applicationMap);
		if (applicationMap.size() > 0) update applicationMap.values();
	}   
}