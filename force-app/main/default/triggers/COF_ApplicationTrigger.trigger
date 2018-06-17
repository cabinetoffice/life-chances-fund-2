/* _______________________________________________________________________________________________________________
   Name:		COF_ApplicationTrigger.trigger
   Description: Trigger actions on LCF Application__c records
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Apr 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */  
      
trigger COF_ApplicationTrigger on Application__c (after insert, after update, before insert, before update) {
	
	COF_ApplicationTriggerHandler handler = new COF_ApplicationTriggerHandler();
	
	if (Trigger.isBefore && Trigger.isUpdate) {
	    handler.copyFieldsFromForms(Trigger.newMap); 
	}    
}