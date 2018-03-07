/* _______________________________________________________________________________________________________________
   Name:		COF_ContentVersionTrigger.trigger
   Description: Trigger actions on ContentVersion records
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Mar 2018     1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */  
      
trigger COF_ContentVersionTrigger on ContentVersion (after insert, after update, before insert, before update) {
	
	COF_ContentVersionTriggerHandler handler = new COF_ContentVersionTriggerHandler();
	
	if (Trigger.isAfter) {
	    if (Trigger.isInsert) {
	    	handler.linkShareContentVersion(Trigger.new);
	    }
	}    
}