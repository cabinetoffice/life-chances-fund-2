/* _______________________________________________________________________________________________________________________
   Name:        COF_EOIDataConversion.cls
   Description: EOI Data Conversion
                    
   Date         Version Author              Summary of Changes 
   ___________  _______ __________________  ______________________________________________________________________________
   Apr 2018     1.0     Michael Witchalls   Initial Release 
__________________________________________________________________________________________________________________________ */        
public without sharing class COF_EOIDataConversion {
	private static final String OBJECTNAME = 'Form_LCF_EOI_1__c';
	private static final String RECORDTYPE = 'EOI';
	private static final String DRAFT = 'Draft';
	private static final String COMPLETE = 'COMPLETE';
	private static final String INCOMPLETE = 'INCOMPLETE';
    private static final String VALIDATION_EXCEPTION = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    private static Map<ID, Application__c> appMap;
    private static Map<String, Form_LCF_EOI_1__c> appEOIMap;
    private static Map<String, SIB_Field_Metadata__c> metadataMap; 
    
    private static void populateAppEOIMap() {
    	appMap = new Map<ID, Application__c>();
		appEOIMap = new Map<String, Form_LCF_EOI_1__c>();
		
		// Retrieve list of Applications and initialise eoi map
		for (Application__c a: [
			SELECT 
				Id, Name, Status__c, 
				(SELECT Organisation_Name__c, Organisation_Region__c, Is_Lead_Commissioner__c, 
				First_Name__c, Last_Name__c, Phone_Number__c, Email__c FROM Application_Commissioners__r ORDER BY CreatedDate),
				(SELECT Name, Outcome_summary__c, Measure__c, Key_Change__c FROM Outcomes__r ORDER BY CreatedDate),
				(SELECT Name, Was_It_Successful__c, Not_Successful_Reasons__c FROM Previous_Applications__r)
			FROM Application__c
		]) {
			appMap.put(a.Id, a);
			Form_LCF_EOI_1__c eoiForm = new Form_LCF_EOI_1__c(
				application__c = a.Id,
				EOI_Key__c = a.Name,
				lc_section_status__c = (a.Status__c == DRAFT) ? INCOMPLETE : COMPLETE,
				or_section_status__c = (a.Status__c == DRAFT) ? INCOMPLETE : COMPLETE,
				pr_section_status__c = (a.Status__c == DRAFT) ? INCOMPLETE : COMPLETE,
				ou_section_status__c = (a.Status__c == DRAFT) ? INCOMPLETE : COMPLETE,
				rs_section_status__c = (a.Status__c == DRAFT) ? INCOMPLETE : COMPLETE,
				co_section_status__c = (a.Status__c == DRAFT) ? INCOMPLETE : COMPLETE,
				pa_section_status__c = (a.Status__c == DRAFT) ? INCOMPLETE : COMPLETE,
				de_section_status__c = (a.Status__c == DRAFT) ? INCOMPLETE : COMPLETE
			);
			appEOIMap.put(eoiForm.EOI_Key__c, eoiForm); 
		}
    }
   
    private static void populateMetadataMap() {
		metadataMap = new Map<String, SIB_Field_Metadata__c>();
		
		for (SIB_Field_Metadata__c md: [
			SELECT 
				Name, Field_Name__c, Type__c, Length__c, Description__c, Help_Text__c, Relationship_Name__c,
				Rich_Text__c, Recommended_Word_Limit__c, Warning_Text__c, Warning_Value__c, Page_Title__c 
			FROM 
				SIB_Field_Metadata__c
			WHERE
				Object_Name__c = :OBJECTNAME
		]) {
			if (md.Help_Text__c != null) {
				if (md.Type__c == 'Currency' && md.Length__c < 18) {
					// if length < 18 append to key to distinguish questions with same text
					metadataMap.put(md.Help_Text__c + md.Length__c, md);
				} else {
					metadataMap.put(md.Help_Text__c, md);	
				}
			}
						
		}   
		system.debug('@@@@metadataMap: '+metadataMap); 	
    }
	     
	/*
		This method creates and upserts EOI Form records
		1) Process application answers
		2) Upsert form records
	*/
    public static String convertEOI() { 
    	if (appEOIMap == null) populateAppEOIMap();
    	if (metadataMap == null) populateMetadataMap();
		
    	for (List<Application_Answer__c> answerList: [
	    	SELECT 
	    		Id, Name, Application_Question__c, Application_Question__r.Question_Qualifier__c, Application__c, Application__r.Name, Question__c, 
	    		Checkboxes_Answer__c, Currency_Answer__c, Short_Text_Answer__c, Text_Answer__c, 
	    		Date_Day_Answer__c, Date_Month_Answer__c, Date_Year_Answer__c, Date_Formula__c, 
	    		Email_Answer__c, Percent_Answer__c, Radio_Answer__c, Answer_Key__c, EOI_Status__c 
	    	FROM 
	    		Application_Answer__c 
	    	WHERE
	    		Form__c = 'Expression of Interest' AND Application__c != null AND Is_Question__c = true
	    ]) {
	    	for (Application_Answer__c answer: answerList) {
	    		Form_LCF_EOI_1__c form = appEOIMap.get(answer.Application__r.Name);
	    		SIB_Field_Metadata__c md;
	    		if (answer.Application_Question__r.Question_Qualifier__c != null) {
	    			md = metadataMap.get(answer.Question__c + answer.Application_Question__r.Question_Qualifier__c);
	    		} else {
	    			md = metadataMap.get(answer.Question__c);
	    		}
	    		system.debug('@@@@answer: '+answer);
	    		system.debug('@@@@md: '+md);
    			String textValue = null;
    			Double numberValue = null;
    			Date dateValue = null;
    			Boolean booleanValue = null;
    			
	    		if (form != null && md != null) {
	    			if (md.Type__c == 'Text' || md.Type__c == 'TextArea' || md.Type__c == 'LongTextArea' || md.Type__c == 'Email') {
	    				if (answer.Email_Answer__c != null) {
	    					textValue = answer.Email_Answer__c;
	    				}else if (answer.Short_Text_Answer__c != null) {
	    					textValue = answer.Short_Text_Answer__c; 
	    				} else if (answer.Text_Answer__c != null) {
	    					textValue = answer.Text_Answer__c;
	    				}
	    			} else if (md.Type__c == 'Picklist') {
	    				textValue = answer.Radio_Answer__c;
	    			} else if (md.Type__c == 'MultiselectPicklist') {
	    				textValue = answer.Checkboxes_Answer__c;
	    			} else if (md.Type__c == 'Currency') {
	    				numberValue = answer.Currency_Answer__c;
	    			} else if (md.Type__c == 'Percent') {
	    				numberValue = answer.Percent_Answer__c;
	    			} else if (md.Type__c == 'Date' && answer.Date_Formula__c != null && Integer.valueOf(answer.Date_Year_Answer__c)>1990) {
	    				dateValue = Date.newInstance(
	    					Integer.valueOf(answer.Date_Year_Answer__c),
	    					Integer.valueOf(answer.Date_Month_Answer__c),
	    					Integer.valueOf(answer.Date_Day_Answer__c)
	    				);
	    			} else if (md.Type__c == 'Checkbox') {
	    				booleanValue = true;    				
	    			}
	    		}
    			
    			if (textValue != null) {
    				textValue = textValue.replace('&','and');
    				textValue = textValue.replace('Local commissioner','Commissioner');
    				form.put(md.Field_Name__c, textValue);
    			} else if (numberValue != null) {
    				form.put(md.Field_Name__c, numberValue);
    			} else if (dateValue != null) {
    				form.put(md.Field_Name__c, dateValue);
    			} else if (booleanValue != null) {
    				form.put(md.Field_Name__c, booleanValue);
    			}
	    	}
	    }
    	
    	if (appEOIMap.size() > 0) {    	
			try {
	        	upsert appEOIMap.values() EOI_Key__c;
	   			return 'Form_LCF_EOI_1__c record count: '+appEOIMap.size();
			} catch (Exception e) {
	    		return exceptionMessage(e);
	   		}
    	}
        return null;
    }

	/*
		This method creates and upserts EOI Commissioner records
		1) Process application commissioners
		2) Upsert Form_LCF_Commissioner_1__c records
	*/
	public static String convertCommissioners() {
		ID recordTypeId = Schema.SObjectType.Form_LCF_Commissioner_1__c.getRecordTypeInfosByName().get(RECORDTYPE).getRecordTypeId();
		
		Map<String, Form_LCF_Commissioner_1__c> commsMap = new Map<String, Form_LCF_Commissioner_1__c>();
    	if (appEOIMap == null) populateAppEOIMap();
    	
    	for (Form_LCF_EOI_1__c form: appEOIMap.values()) { 
    		Application__c app = appMap.get(form.application__c);
    		Form_LCF_EOI_1__c formRef = new Form_LCF_EOI_1__c(EOI_Key__c = form.EOI_Key__c);
    		
    		for (Application_Commissioner__c c: app.Application_Commissioners__r) {
    			if (c.Organisation_Name__c != null) {
    				String keyString = app.Name + ':' + RECORDTYPE + ':' + 
    					c.Organisation_Name__c.left(100) + ':' +
						(c.First_Name__c == null ? '' : c.First_Name__c.left(50)) + ' ' +
						(c.Last_Name__c == null ? '' : c.Last_Name__c.left(50));
	    			commsMap.put(
	    				keyString,
	    				new Form_LCF_Commissioner_1__c(
	    					RecordTypeId = recordTypeId,
	    					application__c = form.application__c,
	    					eoi__r = formRef,
	   						primary__c = (c.Is_Lead_Commissioner__c == 'Yes'),
	    					st_organisation_name__c = c.Organisation_Name__c,
	    					st_organisation_region__c = c.Organisation_Region__c,
	     					st_lead_contact_last_name__c = c.Last_Name__c,
	    					st_lead_contact_first_name__c = c.First_Name__c,
	    					st_lead_contact_email__c = c.Email__c,
	    					st_lead_contact_phone__c = c.Phone_Number__c,
	    					key__c = keyString
	    				)
    				); 
    			}
    		}
    	}
    	if (commsMap.size() > 0) {
			try {
	        	upsert commsMap.values() key__c;
	   			return 'Form_LCF_Commissioner_1__c record count: '+commsMap.size();
			} catch (Exception e) {
	    		return exceptionMessage(e);
	   		}
    	}
		return null;
	}
	
	/*
		This method creates and upserts EOI Outcome records
		1) Process application outcomes
		2) Upsert Form_LCF_Outcome_1__c records
	*/
	public static String convertOutcomes() {
		ID recordTypeId = Schema.SObjectType.Form_LCF_Outcome_1__c.getRecordTypeInfosByName().get(RECORDTYPE).getRecordTypeId();
		
		Map<String, Form_LCF_Outcome_1__c> outcomesMap = new Map<String, Form_LCF_Outcome_1__c>();
    	if (appEOIMap == null) populateAppEOIMap();
    	
    	for (Form_LCF_EOI_1__c form: appEOIMap.values()) { 
    		Application__c app = appMap.get(form.application__c);
    		Form_LCF_EOI_1__c formRef = new Form_LCF_EOI_1__c(EOI_Key__c = form.EOI_Key__c);

    		Integer n = 0;
    		for (Outcome__c o: app.Outcomes__r) {
    			String keyString = app.Name + ':' + RECORDTYPE + ':' + o.Name;
    			outcomesMap.put(
    				keyString,
    				new Form_LCF_Outcome_1__c(
    					RecordTypeId = recordTypeId,
    					application__c = form.application__c,
     					eoi__r = formRef,
    					primary__c = (n == 0) ? true : false,
    					ou_description__c = o.Name,
    					ou_baseline__c = o.Outcome_summary__c,
    					ou_measure__c = o.Measure__c,
    					key__c = keyString
   					)
    			); 
    			n++;
    		}
    	}
    	if (outcomesMap.size() > 0) {
			try {
	        	upsert outcomesMap.values() key__c;
	   			return 'Form_LCF_Outcome_1__c> record count: '+outcomesMap.size();
			} catch (Exception e) {
	    		return exceptionMessage(e);
	   		}
    	}
		return null;
	}
	
	/*
		This method creates and upserts EOI Previous App records
		1) Process application previous applications
		2) Upsert Form_LCF_Previous_App_1__c records
	*/
	public static String convertPreviousApps() {
		
		Map<String, Form_LCF_Previous_App_1__c> prevAppsMap = new Map<String, Form_LCF_Previous_App_1__c>();
    	if (appEOIMap == null) populateAppEOIMap();
    	
    	for (Form_LCF_EOI_1__c form: appEOIMap.values()) { 
    		Application__c app = appMap.get(form.application__c);
    		Form_LCF_EOI_1__c formRef = new Form_LCF_EOI_1__c(EOI_Key__c = form.EOI_Key__c);
    		
    		for (Previous_Application__c p: app.Previous_Applications__r) {
    			String keyString = app.Name + ':' + p.Name;
    			prevAppsMap.put(
    				keyString,
    				new Form_LCF_Previous_App_1__c(
    					application__c = form.application__c,
     					eoi__r = formRef,
     					pa_project_name__c = p.Name,
    					pa_successful__c = p.Was_It_Successful__c,
    					pa_reasons_not_successful__c = p.Not_Successful_Reasons__c,
    					key__c = keyString					
   					)
    			); 
     		}
    	}
    	if (prevAppsMap.size() > 0) {
			try {
	        	upsert prevAppsMap.values() key__c;
	   			return 'Form_LCF_Previous_App_1__c> record count: '+prevAppsMap.size();
			} catch (Exception e) {
	    		return exceptionMessage(e);
	   		}
    	}
		return null;
	}
	
    private static String exceptionMessage(Exception e) {   	
    	String msg = e.getMessage();
        if (msg.contains(VALIDATION_EXCEPTION)) {
            String validationError = msg.substringBetween(VALIDATION_EXCEPTION+', ',':');
            return 'Error: '+validationError;
		} else {
            return 'Error: '+msg;
        }
    }    
}