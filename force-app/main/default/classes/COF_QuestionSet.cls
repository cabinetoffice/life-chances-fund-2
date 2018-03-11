/**
 * COF_QuestionSet
 * Cabinet Office Forms 1.0
 *
 * This class represents a question set (a list of pages, questions and branching logic) in a section.
 */
public class COF_QuestionSet {

	public String id;
	public String target_object;
	public String target_field;
	public String status_field;
	public String child_count_field;
	public String page_status_field;
	public String parent_relationship;
	public String short_title; 
	public List<COF_Page> pages;

	public class COF_Children {
		public String target_field {get;set;}
		public String target_field2 {get;set;}
		public String target_object {get;set;}
		public String parent_field {get; set;}
		public String child_relationship {get;set;}
		public String parent_relationship {get;set;}
		public String title {get;set;}
		public String section {get;set;}
		public String add_label {get;set;}
		public String primary_label {get;set;}
		public List<COF_Page> childPages {get;set;}
	}

	public class COF_Constraint {
		public String field;
		public String operator;
		public String value;
	}

	public class COF_Question {
		public String target_field {get;set;}
		public String guidance {get;set;}
		public Integer recommended_word_limit {get;set;}
	}

	public class COF_Files {
		public String target_field {get;set;}
		public String maximum_file_size {get;set;}
	}

	public class COF_Route {
		public String target_page;
		public List<COF_Constraint> constraints;
	}

	public COF_Page getPage(String pageId) {
		if (pageId == '0') return null;
		for (COF_Page page : this.pages) {
			if (page.id == pageId) {
				return page;
			}
		}
		throw new COF_Exception('Could not get referenced page');
		return null;
	}

	/**
	 * Instantiates a new COF_QuestionSet object given an identifier, deserializing
	 * the relevant JSON configuration definition
	 */
	public static COF_QuestionSet load(String identifier) {
		String questionSetJson;
		COF_QuestionSet qs;
        try {
		    // Load JSON representation of form
			String questionSetUrl = PageReference.forResource(identifier).getUrl();
        	PageReference questionSetReference = new PageReference(questionSetUrl);
    		questionSetJson = questionSetReference.getContent().toString();
	    	// Instantiate form from JSON
	        qs = (COF_QuestionSet)System.JSON.deserialize(questionSetJson, COF_QuestionSet.class);
		} catch(Exception ex) {
		    if (Test.isRunningTest()) { 
		    	if (identifier == 'lcf_full_app_overview_1') { 
		    		questionSetJson = 
'{'+
'	"id": "lcf_full_app_overview_1",'+
'	"target_object": "Form_LCF_Full_App_1__c",'+
'	"parent_relationship": "application__r",'+
'	"pages": ['+
'		{'+
'			"id": "1",'+
'			"questions": ['+
'				{ "target_field": "ov_project_name__c" },'+
'				{ "target_field": "ov_project_summary__c" },'+
'				{ "target_field": "ov_services_start_date__c" },'+			
'				{ "target_field": "si_themes__c" }'+			
'			],'+
'			"routes": ['+
'				{ "target_page": "2" }'+
'			]'+
'		},'+
'		{'+
'			"id": "2",'+
'			"children": {'+
'				"target_object": "Form_LCF_Commissioner_1__c",'+
'				"target_field": "co_organisation_name__c",'+
'				"child_relationship": "full_application_commissioners__r",'+
'				"parent_field": "full_application__c",'+
'				"title": "Outcome Commissioners",'+
'				"section": "lcf_full_app_overview_child_1"'+
'			},'+
'			"routes": ['+
'				{'+ 
'					"target_page": "12",'+
'					"constraints": ['+
'						{ "field": "ov_organisation_type__c", "operator": "equals", "value": "Local commissioner" }'+
'					]'+
'				}'+
'			]'+
'		}'+
'	]'+
'}';
		    	} else if (identifier == 'lcf_full_app_overview_child_1') { 
		    		questionSetJson =
'{'+
'	"id": "lcf_full_app_overview_child_1",'+
'	"target_object": "Form_LCF_Commissioner_1__c",'+
'	"target_field": "co_organisation_name__c",'+
'	"status_field": "ov_section_status__c",'+
'	"short_title": "Commissioner",'+
'	"parent_relationship": "full_application__r",'+
'	"pages": ['+
'		{'+
'			"id": "1",'+
'			"questions": ['+
'				{ "target_field": "co_organisation_name__c" }'+
'			]'+
'		}'+
'	]'+
'}';
		    	}
	    		qs = (COF_QuestionSet) System.JSON.deserialize(questionSetJson, COF_QuestionSet.class);
			} else {
		    	throw new COF_Exception('Could not deserialize referenced question set from JSON file: '+identifier);
		    }
		}
		// M.Witchalls Feb 2018
		for (COF_Page pg: qs.pages) {
			pg.prepareFields(qs.target_object);
		}
		return qs;
	}
}