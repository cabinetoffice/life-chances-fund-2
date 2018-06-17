/**
 * COF_Config
 * Cabinet Office Forms 1.0
 *
 * This class represents the JSON config file which describes all available forms.
 */
public class COF_Config {

	private static final Map<String, String> configResourceMap = new Map<String, String>{
		'lcf_full_app_1'=>'lcf_full_app_config_1',
		'lcf_setup_1'=>'lcf_setup_config_1',
		'lcf_eoi_1'=>'lcf_eoi_config_1',
		'lcf_grant_1'=>'lcf_grant_config_1',
		'lcf_grant_baseline_1'=>'lcf_grant_config_1',
		'lcf_grant_achievement_1'=>'lcf_grant_config_1',
		'lcf_grant_payment_profile_1'=>'lcf_grant_config_1',
		'lcf_grant_annual_monitor_1'=>'lcf_grant_config_1',
		'lcf_test'=>'configtest'
	};
	private static String resourceName; 

	public List<COF_Form> forms {get;set;}

	/**
	 * Returns a Form given an identifier
	 */
	public COF_Form getForm(String identifier) {
		for (COF_Form form : this.forms) {
			if (form.id == identifier) {
				return form;
			}
		}
		
		throw new COF_Exception('Could not find form '+identifier+' in config.resource');	
		return null;
	}

	/**
	 * Instantiates a new COF_Config object given an identifier, deserializing
	 * the relevant JSON configuration definition
	 */
	public static COF_Config load(String identifier) {
		try {
			resourceName = configResourceMap.get(identifier);
			if (resourceName == null) {
				throw new COF_Exception('Could not obtain config resource file for form '+identifier);
			}
		    // Load JSON representation of form
			String configJsonPath = PageReference.forResource(resourceName).getUrl();
	        PageReference configJsonReference = new PageReference(configJsonPath);
	    	String configJson = configJsonReference.getContent().toString();
	    	system.debug('configJson: '+configJson);
	    	// Instantiate form from JSON
	    	return (COF_Config) System.JSON.deserialize(configJson, COF_Config.class);
		} catch(Exception ex) {
		    if (Test.isRunningTest()) { 
		    	String configJson = 
'{'+
'	"forms": ['+
'		{'+
'			"id": "lcf_full_app_1",'+ 
'			"title": "Full application",'+
'			"short_title": "Full application",'+
'			"target_object": "Form_LCF_Full_App_1__c",'+ 
'			"application_status_field": "Full_Application_Status__c",'+
'			"questions": ['+
'				{ "target_field": "ov_project_name__c" },'+
'				{ "target_field": "ov_project_summary__c" }'+
'			],'+
'			"sections": ['+
'				{'+
'					"id": "lcf_full_app_overview_1",'+
'					"title": "Overview of your project",'+
'					"summary": "This section asks for you to provide the key details of your project.",'+
'					"target_object": "Form_LCF_Full_App_1__c",'+
'					"status_field": "ov_section_status__c"'+
'				}'+
'			]'+
'		},'+
'		{'+
'			"id": "lcf_grant_achievement_1",'+
'			"title": "Outcome achievement and payment",'+
'			"short_title": "Outcome achievement",'+
'			"target_object": "Form_LCF_Grant_Achievement_1__c",'+
'			"users_able_to_edit": "Project users + Admin users",'+
'			"block_status_field": "ab_block_status__c",'+
'			"approval_status_field": "ab_approval_status__c",'+
'			"period_title_field": "ab_claim_period__c",'+
'			"reviewer_field": "reviewer__c",'+
'			"questions": ['+
'				{ "target_field": "ab_claim_period_start__c" },'+
'				{ "target_field": "ab_claim_period_end__c" }'+
'			],'+
'			"sections": ['+
'				{'+
'					"id": "lcf_grant_user_referral_1",'+
'					"title": "Service user referrals",'+
'					"short_title": "Referrals",'+
'					"status_field": "ur_section_status__c"'+
'				}'+
'			]'+
'		}'+
'	]'+
'}';
	    		return (COF_Config) System.JSON.deserialize(configJson, COF_Config.class);
			} else {
				throw new COF_Exception('Could not deserialize referenced form from JSON file: '+resourceName);
			}	
		}
	}
}