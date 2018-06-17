/* _______________________________________________________________________________________________________________
   Name:		COF_CommissionerTrigger.trigger
   Description: Trigger actions on Form LCF Commissioner records
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Mar 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */  
      
trigger COF_CommissionerTrigger on Form_LCF_Commissioner_1__c (after insert, after update, before insert, before update) {
	
	COF_CommissionerTriggerHandler handler = new COF_CommissionerTriggerHandler();
	
	if (Trigger.isAfter) {
	    if (Trigger.isInsert || Trigger.isUpdate) {
	    	handler.copyPrimaryCommssionerFields(Trigger.new);
	    }
	}    
}