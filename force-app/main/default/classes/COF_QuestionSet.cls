/**
 * COF_QuestionSet
 * Cabinet Office Forms 1.0
 *
 * This class represents a question set (a list of pages, questions and branching logic) in a section.
 */
public class COF_QuestionSet {

	public String id;
	public String target_object;
	public String copy_object;
	public String target_field;
	public String status_field;
	public String child_count_field;
	public String primary_count_field;
	public String page_status_field;
	public String parent_object;
	public String parent_relationship;
	public String status_relationship;
	public String short_title; 
	public List<COF_Page> pages;

	public class COF_Children {
		public String optional			{get;set;}
		public String target_field  	{get;set;}
		public String target_field2 	{get;set;}
		public String target_field3 	{get;set;}
		public String target_field4 	{get;set;}
		public String target_field5 	{get;set;}
		public String target_field6 	{get;set;}
		public String width_class		{get;set;}
		public String field_width  		{get;set;}
		public String field_width2 		{get;set;}
		public String field_width3 		{get;set;}
		public String field_width4 		{get;set;}
		public String field_width5 		{get;set;}
		public String field_width6 		{get;set;}
		public String total_field2 		{get;set;}
		public String total_field3 		{get;set;}
		public String total_field4 		{get;set;}
		public String total_field5 		{get;set;}
		public String total_field6 		{get;set;}
		public String field_head2 		{get;set;}
		public String field_head3 		{get;set;}
		public String field_head4 		{get;set;}
		public String field_head5 		{get;set;}
		public String field_head6 		{get;set;}
		public String target_object 	{get;set;}
		public String target_filter 	{get;set;}
		public String parent_field  	{get;set;} 
		public String child_parent_object	{get;set;}
		public String child_parent_field	{get;set;}
		public String child_parent_primary	{get;set;}
		public String grandparent_field {get;set;}
		public String child_relationship	{get;set;}
		public String parent_relationship	{get;set;}
		public String title 			{get;set;}
		public String section 			{get;set;}
		public String copy_label 		{get;set;}
		public String add_label 		{get;set;}
		public String primary_label 	{get;set;}
		public String primary_field 	{get;set;}
		public String child_count_field {get;set;}
		public String primary_count_field	{get;set;}
		public String record_type 		{get;set;}
		public String grandchildren_page	{get;set;}
		public String grandchildren_title	{get;set;}
		public String display_field		{get;set;} 
		public String remove_reqd		{get;set;}
		public List<COF_Page> childPages{get;set;}
		public List<SObject> childRecs	{get;set;}
	}

	public class COF_Constraint {
		public String field;
		public String operator;
		public String value;
	}

	public class COF_Question {
		public String target_field {get;set;}
		public String is_display {get;set;}
		public String application_field {get;set;}
		public String add_to {get;set;}
		public String copy_from_field {get;set;}
		public String calculated {get;set;}
		public String guidance {get;set;}
		public Integer recommended_word_limit {get;set;}
		public List<COF_Constraint> constraints {get;set;}
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
	        system.debug('@@@@qs: '+qs);
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
'				"target_field": "st_organisation_name__c",'+
'				"child_relationship": "full_application_commissioners__r",'+
'				"parent_field": "full_application__c",'+
'				"title": "Outcome Commissioners",'+
'				"section": "lcf_full_app_overview_child_1",'+
'				"add_label": "+ Add another commissioner",'+
'				"primary_label": "+ Add primary commissioner",'+
'				"primary_field": "primary__c",'+
'				"child_count_field": "ov_number_of_commissioners__c",'+
'				"primary_count_field": "ov_primary_commissioner_count__c",'+
'				"record_type": "Full Application"'+
'			},'+
'			"routes": ['+
'				{'+ 
'					"target_page": "12",'+
'					"constraints": ['+
'						{ "field": "ov_organisation_type__c", "operator": "equals", "value": "Commissioner" }'+
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
'	"target_field": "st_organisation_name__c",'+
'	"status_field": "ov_section_status__c",'+
'	"child_count_field": "ov_number_of_commissioners__c",'+
'	"primary_count_field": "ov_primary_commissioner_count__c",'+
'	"primary_field": "primary__c",'+
'	"short_title": "Commissioner",'+
'	"parent_relationship": "full_application__r",'+
'	"pages": ['+
'		{'+
'			"id": "1",'+
'			"questions": ['+
'				{ "target_field": "st_organisation_name__c" },'+
'				{ "target_field": "primary__c" }'+
'			]'+
'		}'+
'	]'+
'}';
		    	} else if (identifier == 'lcf_grant_user_referral_1') { 
		    		questionSetJson =

'{'+
'	"id": "lcf_grant_user_referral_1",'+
'	"target_object": "Form_LCF_Grant_Achievement_1__c",'+
'	"parent_relationship": "lcf_grant__r",'+
'	"pages": ['+
'		{'+
'			"id": "1",'+
'			"questions": ['+
'				{ "target_field": "ur_period_referral_target__c" },'+
'				{ "target_field": "ur_period_referral_actual__c" },'+
'				{ "target_field": "ur_period_participant_starters__c" }'+
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
			system.debug('@@@@pg: '+pg);
			pg.prepareFields(qs.target_object);
		}
		return qs;
	}
}