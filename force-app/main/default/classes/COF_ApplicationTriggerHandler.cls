/* _______________________________________________________________________________________________________________
   Name:		COF_ApplicationTriggerHandler.cls
   Description: Trigger actions on Application records
					
   Date         Version Author          	Summary of Changes 
   ___________  _______ __________________	______________________________________________________________________
   Apr 2018		1.0     Michael Witchalls	Initial Release 
__________________________________________________________________________________________________________________ */
      
public class COF_ApplicationTriggerHandler {
	
	/*
	 *	Purpose: On update of Application__c, copy fields from EOI, Full Application and Full Award Setup forms
	 *	History: 
	 *		Apr 2018: Michael Witchalls: Initial Release 
	 *
	 */
	public void copyFieldsFromForms(Map<ID,Application__c> itemMap) {
		Map<ID, Form_LCF_EOI_1__c> eoiMap = new Map<ID, Form_LCF_EOI_1__c>();
		Map<ID, Form_LCF_Full_App_1__c> fullAppMap = new Map<ID, Form_LCF_Full_App_1__c>();
		Map<ID, Form_LCF_Setup_1__c> setupMap = new Map<ID, Form_LCF_Setup_1__c>();
		
		for (Form_LCF_EOI_1__c eoiForm: [
			SELECT 
				Id, application__c, pr_project_name__c, pr_project_region__c,
				or_organisation_name__c, or_organisation_type__c, or_organisation_sector__c 
			FROM
				Form_LCF_EOI_1__c
			WHERE
				application__c IN :itemMap.keySet()
		]) {
			eoiMap.put(eoiForm.application__c, eoiForm);
		}
		
		for (Form_LCF_Full_App_1__c fullAppForm: [
			SELECT 
				Id, application__c, ov_project_name__c, ov_project_region__c, Project_Value__c, 
				or_name__c, ov_organisation_type__c, ov_organisation_sector__c
			FROM
				Form_LCF_Full_App_1__c
			WHERE
				application__c IN :itemMap.keySet()
		]) {
			fullAppMap.put(fullAppForm.application__c, fullAppForm);
		}
		
		for (Form_LCF_Setup_1__c setupForm: [
			SELECT 
				Id, application__c, ap_project_name__c, Project_Value__c, 
				ap_lead_applicant_organisation__c, ap_organisation_type__c, ap_organisation_sector__c
			FROM
				Form_LCF_Setup_1__c
			WHERE
				application__c IN :itemMap.keySet()
		]) {
			setupMap.put(setupForm.application__c, setupForm);
		}
		
		for (Application__c app: itemMap.values()) {
			Form_LCF_EOI_1__c eoiForm = eoiMap.get(app.Id);
			Form_LCF_Full_App_1__c fullAppForm = fullAppMap.get(app.Id);
			Form_LCF_Setup_1__c setupForm = setupMap.get(app.Id);
			
			if (setupForm != null && setupForm.ap_project_name__c != null) {
				app.Project_Name__c = setupForm.ap_project_name__c;
			} else if (fullAppForm != null && fullAppForm.ov_project_name__c != null) {
				app.Project_Name__c = fullAppForm.ov_project_name__c;
			} else if (eoiForm != null && eoiForm.pr_project_name__c != null) {
				app.Project_Name__c = eoiForm.pr_project_name__c;
			}
			
			if (fullAppForm != null && fullAppForm.ov_project_region__c != null) {
				app.Project_Region__c = fullAppForm.ov_project_region__c;
			} else if (eoiForm != null && eoiForm.pr_project_region__c != null) {
				app.Project_Region__c = eoiForm.pr_project_region__c; 
			}
			
			if (setupForm != null && setupForm.Project_Value__c != null) {
				app.Project_Value__c = setupForm.Project_Value__c;
			} else if (fullAppForm  != null && fullAppForm.Project_Value__c != null) {
				app.Project_Value__c = fullAppForm.Project_Value__c; 
			}
			
			if (setupForm != null && setupForm.ap_lead_applicant_organisation__c != null) {
				app.Applicant_Organisation_Name__c = setupForm.ap_lead_applicant_organisation__c;
			} else if (fullAppForm != null && fullAppForm.or_name__c != null) {
				app.Applicant_Organisation_Name__c = fullAppForm.or_name__c;
			} else if (eoiForm != null && eoiForm.or_organisation_name__c != null) {
				app.Applicant_Organisation_Name__c = eoiForm.or_organisation_name__c;
			}
			
			if (setupForm != null && setupForm.ap_organisation_type__c != null) {
				app.Applicant_Organisation_Type__c = setupForm.ap_organisation_type__c;
			} else if (fullAppForm != null && fullAppForm.ov_organisation_type__c != null) {
				app.Applicant_Organisation_Type__c = fullAppForm.ov_organisation_type__c;
			} else if (eoiForm != null && eoiForm.or_organisation_type__c != null) {
				app.Applicant_Organisation_Type__c = eoiForm.or_organisation_type__c;
			}
			
			if (setupForm != null && setupForm.ap_organisation_sector__c != null) {
				app.Applicant_Organisation_Sector__c = setupForm.ap_organisation_sector__c;
			} else if (fullAppForm != null && fullAppForm.ov_organisation_sector__c != null) {
				app.Applicant_Organisation_Sector__c = fullAppForm.ov_organisation_sector__c;
			} else if (eoiForm != null && eoiForm.or_organisation_sector__c != null) {
				app.Applicant_Organisation_Sector__c = eoiForm.or_organisation_sector__c;
			}
		}
		
	}
}