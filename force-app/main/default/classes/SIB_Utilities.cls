/* __________________________________________________________________________________________________________________
   Name:		SIB_Utilities.cls
   Description: General Utility Class
					
   Date         Version Author          		Summary of Changes 
   ___________  _______ __________________		_____________________________________________________________________
   2017		    1.0    	Cabinet Office			Initial Release 
   Feb 2018		1.1		M.Witchalls, Westbrook	Extraction of field metadata and section text
__________________________________________________________________________________________________________________ */        
public class SIB_Utilities {
	public static Map<String, Map<String, Id>> recordTypeIdCache = new Map<String, Map<String, Id>>();
	public static Map<String, SIB_Field_Metadata__c> fieldMetadataCache = new Map<String, SIB_Field_Metadata__c>();
	public static Map<String, SIB_Section_Text__c> sectionTextCache = new Map<String, SIB_Section_Text__c>();

	/*
		Utility method to query LCF field descriptions.
		LCF field descriptions and other metadata are extracted by a Visualforce Page button via the Metadata API 
		and stored in the custom object SIB_Field_Metadata__c so as to be available to end users.
		
		M.Witchalls Feb 2018		
	*/
	public static SIB_Field_Metadata__c getFieldMetadata(String objectName, String fieldName) {
		String fieldKey = objectName+'.'+fieldName;
		if(fieldMetadataCache.size() == 0 && !Test.isRunningTest()) {
			fieldMetadataCache = new Map<String, SIB_Field_Metadata__c>();
			for (List<SIB_Field_Metadata__c> fdList: [
				SELECT 
					Name, Field_Key__c, Description__c, Help_Text__c, Relationship_Name__c,
					Rich_Text__c, Recommended_Word_Limit__c, Warning_Text__c, Warning_Value__c, Page_Title__c 
				FROM 
					SIB_Field_Metadata__c
			]) {
				for (SIB_Field_Metadata__c fm: fdList) {
					fieldMetadataCache.put(fm.Field_Key__c, fm);
				} 
			}
		}
		return fieldMetadataCache.get(fieldKey);
	}

	/*
		Utility method to extract rich text for LCF sections.
		LCF section text is stored in the SIB Section Text object and accessed via title_id, guidance_id, warning_id etc
		
		M.Witchalls Feb 2018		
	*/
	public static SIB_Section_Text__c getSectionText(String textKey) {
		return SIB_Utilities.getSectionText(textKey, false);
	}
	public static SIB_Section_Text__c getSectionText(String textKey, Boolean ignoreNulls) { 
		SIB_Section_Text__c returnObject;
		if (sectionTextCache.size() == 0) {
			sectionTextCache = new Map<String, SIB_Section_Text__c>();
			
	        SIB_TemplateController con = new SIB_TemplateController();
	        for (SIB_Section_Text__c st: con.sibInfo.Section_Text__r) {
	        	sectionTextCache.put(st.Key__c, st);
	        } 
		}
		returnObject = sectionTextCache.get(textKey);
		if (returnObject == null) {
			if (ignoreNulls) return null;
			throw new COF_Exception('Could not find custom text with key: '+textKey);
		}
		return returnObject;
	}

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