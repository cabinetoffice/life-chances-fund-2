/* _______________________________________________________________________________________________________________
   Name:		COF_OutcomeMetricTrigger.trigger
   Description: Trigger actions on LCF Outcome Metric records
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   May 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */  
      
trigger COF_OutcomeMetricTrigger on Form_LCF_Outcome_Metric_1__c (after delete, after insert, after undelete, after update) {
	
	COF_OutcomeMetricTriggerHandler handler = new COF_OutcomeMetricTriggerHandler();
	
	if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)) {
	    handler.copyRecordsToParents(Trigger.new); 
	}   
	
	if (Trigger.isAfter && Trigger.isDelete) {
		handler.copyRecordsToParents(Trigger.old);
	} 
    
}