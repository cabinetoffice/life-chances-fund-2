/* _______________________________________________________________________________________________________________
   Name:		COF_OutcomeMetricTriggerHandler.cls
   Description: Trigger actions on LCF Outcome Metric records
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   May 2018		1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */
public class COF_OutcomeMetricTriggerHandler {
    	
	/*
	 *	Purpose: On insert/update/delete/undelete copy all records to the parent Grant Outcome record
	 *	History: 
	 *		May 2018: Michael Witchalls: Initial Release 
	 *
	 */
	public void copyRecordsToParents(List<Form_LCF_Outcome_Metric_1__c> items) {
		Set<ID> outcomeIdSet = new Set<ID>();
		for (Form_LCF_Outcome_Metric_1__c item: items) {
			outcomeIdSet.add(item.grant_outcome__c);
		}
		Map<ID, Form_LCF_Grant_Outcome_1__c> outcomeMap = new Map<ID, Form_LCF_Grant_Outcome_1__c>([
			SELECT 
				Id, (SELECT om_description__c, om_individual_cohort__c FROM outcome_metrics__r WHERE isDeleted = false)
			FROM	
				Form_LCF_Grant_Outcome_1__c
			WHERE
				Id IN :outcomeIdSet
		]);
		
		List<Form_LCF_Grant_Outcome_1__c> outcomeList = new List<Form_LCF_Grant_Outcome_1__c>();
		for (ID outcomeId: outcomeMap.keySet()) {
			String outcomeMetricString = '<table><tr><th><b>Description</b></th><th><b>Individual/Cohort</b></th><tr>';
			for (Form_LCF_Outcome_Metric_1__c item: outcomeMap.get(outcomeId).outcome_metrics__r) {
				outcomeMetricString += '<tr><td>'+item.om_description__c+'</td><td>'+item.om_individual_cohort__c+'</td></tr>';
			}
			outcomeMetricString += '</table>';
			outcomeList.add(
				new Form_LCF_Grant_Outcome_1__c(
					Id = outcomeId,
					ou_outcome_metrics__c = outcomeMetricString					
				)
			);
			system.debug('@@@@outcomeList: '+outcomeList);
		}
		update outcomeList;
	}
    
}