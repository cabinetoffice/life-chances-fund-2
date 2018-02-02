/**
 * COF_Config
 * Cabinet Office Forms 1.0
 *
 * This class represents the JSON config file which describes all available forms.
 */
public class COF_Config {

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
	public static COF_Config load() {
		try {
		    // Load JSON representation of form
			String configJsonPath = PageReference.forResource('config').getUrl();
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
'			"target_object": "Form_LCF_Full_App_1__c",'+
'			"sections": ['+
'				{'+
'					"id": "lcf_full_app_overview_1",'+
'					"title": "Overview of your project",'+
'					"summary": "This section asks for you to provide the key details of your project.",'+
'					"target_object": "Form_LCF_Full_App_1__c",'+
'					"status_field": "ov_section_status__c"'+
'				}'+
'			]'+
'		}'+
'	]'+
'}';
	    		return (COF_Config) System.JSON.deserialize(configJson, COF_Config.class);
			} else {
				throw new COF_Exception('Could not deserialize referenced form from JSON');
			}	
		}
	}
}