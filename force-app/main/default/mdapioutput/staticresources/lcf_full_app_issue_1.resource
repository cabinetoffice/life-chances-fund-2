{
	"id": "lcf_full_app_issue_1",
	"target_object": "Form_LCF_Full_App_1__c",
	"parent_relationship": "application__r",
	"pages": [
		{
			"id": "1",
			"questions": [
				{ 
					"target_field": "si_themes__c",
					"guidance": "Select all options that are relevant to you."
				}
			],
			"routes": [
				{ 
					"target_page": "2",
					"constraints": [
						{ "field": "si_themes__c", "operator": "equals", "value": "Other (please specify)" }
					]
				},
				{ 
					"target_page": "3"
				}
			]
		},
		{
			"id": "2",
			"questions": [
				{  "target_field": "si_themes_other__c" }
			],
			"routes": [
				{ "target_page": "3" }
			]
		},
		{
			"id": "3",
			"questions": [
				{ 
					"target_field": "si_specific_social_issue__c",
					"guidance": "What is your project's focal point? For example, for projects focused on young people, will you address a specific risk factor in 11-14 year olds who are at risk of becoming NEET, or will you work with 16-24 year old NEETs at risk of becoming homeless",
					"recommended_word_limit": 300
				}
			],
			"routes": [
				{ "target_page": "3" }
			]
		},
		{
			"id": "4",
			"questions": [
				{ 
					"target_field": "si_priority_explanation__c",
					"guidance": "Think about community, financial, research and social impact the project will have for the commissioner",
					"recommended_word_limit": 200
				}
			],
			"routes": [
				{ "target_page": "5" }
			]
		},
		{
			"id": "5",
			"questions": [
				{ 
					"target_field": "si_supporting_research__c",
					"guidance": "Summarise what research has been done and which stakeholders have been engaged. This is about your project as a whole, not specific interventions to be used in the project and may include a theory of change as well as or instead of other research.",
					"recommended_word_limit": 300
				}
			],
			"routes": [
				{ "target_page": "6" }
			]
		},
		{
			"id": "6",
			"questions": [
				{ 
					"target_field": "si_local_service_impact__c",
					"recommended_word_limit": 100
				}
			],
			"routes": [
				{ "target_page": "7" }
			]
		},
		{
			"id": "7",
			"questions": [
				{ 
					"target_field": "si_national_service_impact__c",
					"recommended_word_limit": 100
				}
			],
			"routes": [
				{ "target_page": "8" }
			]
		},
		{
			"id": "8",
			"questions": [
				{ 
					"target_field": "si_vcse_involvement__c",
					"recommended_word_limit": 100
				}
			]
		}
	]
}