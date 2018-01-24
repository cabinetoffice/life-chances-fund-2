public with sharing class SIB_Utilities {
	public static Map<String, Map<String, Id>> recordTypeIdCache = new Map<String, Map<String, Id>>();

	/*
		This method will be used in SIB_SelfRegController and SIB_ApplicationFormExtension. 
		Using this method here will allow one regex in multiple places and will give an easier way to maintain this.
	*/
	public static Boolean isValidEmail(String email) {
		String emailRegex = '^[a-zA-Z0-9\\.\\!\\#\\$\\%\\&\\*\\/\\=\\?\\^\\_\\+\\-\\`\\{\\|\\}\\~\'._%+-]+@[a-zA-Z0-9\\-.-]+\\.[a-zA-Z]+';
		Pattern myPattern = Pattern.compile(emailRegex);
		Matcher myMatcher = myPattern.matcher(email);
		return myMatcher.matches();
	}

	/*
		This method retrieves all questions where there is a "Field From Contact Record" value populated and returns these in
		a string to be used in a query.
	*/
	public static String generateDefaultFields(Id applicationWindowTemplateId){
		String fieldsToReturn = '';
		for(Application_Question_Template__c singleQuestionTemplate : [
			SELECT Application_Question__r.Field_From_Contact_Record__c, Application_Question__r.Field_To_Set_On_Answer__c
			FROM Application_Question_Template__c
			WHERE Application_Window_Template__r.Id = :applicationWindowTemplateId
			AND Application_Question__r.Field_From_Contact_Record__c != null
			ORDER BY CreatedDate ASC
		]){
			fieldsToReturn += singleQuestionTemplate.Application_Question__r.Field_From_Contact_Record__c + ',';
		}
		fieldsToReturn += 'Id';
		return fieldsToReturn;
	}

	/*
		Utility method to query record type Id's. It stores all record types for a particular object to store them for later use,
		which allows a more effective use than querying the record type each time.
	*/
	public static Id getRecordTypeId(String objName, String rtName) {
		if(!recordTypeIdCache.containsKey(objName)){
			Map<String, Id> valuesToPut = new Map<String, Id>();
			Map<String,Schema.RecordTypeInfo> recordTypeInfo = Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByName();
			for(String recordTypeInfoName : recordTypeInfo.keySet()){
				valuesToPut.put(recordTypeInfoName, recordTypeInfo.get(recordTypeInfoName).getRecordTypeId());
			}
			recordTypeIdCache.put(objName, valuesToPut);
		}
		return recordTypeIdCache.get(objName).get(rtName);
	}

	/*
		This method is used on every page to check if the user is logged in, therefore shielding these pages from external views.
		We need to check that the is no user AND that the user is not the community user.
	*/
	public static PageReference checkLoggedInStatus(){
		PageReference pageReferenceToReturn = 
		UserInfo.getUserId() == null || UserInfo.getUserName().startsWith('social_impact_bonds@') ? 
			returnHomePage() : 
			null;
        return pageReferenceToReturn;
	}   

	/*
		Single method to return the base URL of the site. This can be used in multiple places and allows easier upkeep.
	*/
	public static PageReference returnHomePage(){
		return Page.SIB_Login;
	}
}