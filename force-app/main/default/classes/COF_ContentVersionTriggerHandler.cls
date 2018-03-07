/* _______________________________________________________________________________________________________________
   Name:		COF_ContentVersionTriggerHandler.cls
   Description: Trigger actions on ContentVersion records
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Mar 2018		1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */
      
public class COF_ContentVersionTriggerHandler {
	
	/*
	 *	Purpose: Connect uploaded files to Form record
	 *	History: 
	 *		Mar 2018: Michael Witchalls: Initial Release
	 *
	 */
	public void linkShareContentVersion(List<ContentVersion> cvList) {
		
		Map<ID, ContentDocumentLink> linkMap = new Map<ID, ContentDocumentLink>();
		for (ContentVersion cv: cvList) {
			if (cv.SIB_Form_ID__c != null) {
				linkMap.put(
					cv.ContentDocumentId,
					new ContentDocumentLink(
						ContentDocumentId = cv.ContentDocumentId,
						LinkedEntityId = cv.SIB_Form_ID__c,
						ShareType = 'V',
						Visibility = 'AllUsers'
					)
				);
			}
		}
		
		system.debug('@@linkMap: '+linkMap);
		if (linkMap.size() > 0) insert linkMap.values();
	}   
}