{
	"id": "lcf_full_app_overview_1",
	"target_object": "Form_LCF_Full_App_1__c",
	"parent_relationship": "application__r",
	"pages": [
		{
			"id": "1",
			"questions": [
				{ "target_field": "ov_project_name__c" },
				{ 
					"target_field": "ov_project_summary__c",
					"guidance": "Who do you intend to work with, what outcomes you intend to deliver for them, what sorts of interventions you will deliver and what are the expected benefits?",
					"recommended_word_limit": 400
				}
			],
			"routes": [
				{ "target_page": "2" }
			]
		},
		{
			"id": "2",
			"questions": [
				{ "target_field": "ov_services_start_date__c" }
			],
			"routes": [
				{ "target_page": "3" }
			]
		},
		{
			"id": "3",
			"questions": [
				{ "target_field": "ov_services_end_date__c" }
			],
			"routes": [
				{ "target_page": "4" }
			]
		},
		{
			"id": "4",
			"questions": [
				{ "target_field": "ov_payments_end_date__c" }
			],
			"routes": [
				{ "target_page": "5" }
			]
		},
		{
			"id": "5",
			"questions": [
				{ "target_field": "ov_applicant_organisation_name__c" }
			],
			"routes": [
				{ "target_page": "6" }
			]
		},
		{
			"id": "6",
			"questions": [
				{ "target_field": "ov_organisation_type__c" }
			],
			"routes": [
				{ 
					"target_page": "11",
					"constraints": [
						{ "field": "ov_organisation_type__c", "operator": "equals", "value": "Intermediary" }
					]
				},
				{ "target_page": "7" }
			]
		},
		{
			"id": "7",
			"questions": [
				{ "target_field": "ov_intermediary_assisting__c" }
			],
			"routes": [
				{ 
					"target_page": "8",
					"constraints": [
						{ "field": "ov_intermediary_assisting__c", "operator": "equals", "value": "Yes" }
					]
				},
				{ "target_page": "11" }
			]
		},
		{
			"id": "8",
			"title": "Please provide the contact details of the intermediary",
			"guidance": "We will contact intermediaries as part of our assessment of your application.",
			"questions": [
				{ "target_field": "ov_intermediary_name__c" }
			],
			"routes": [
				{ "target_page": "9" }
			]
		},
		{
			"id": "9",
			"title": "Please provide the contact details of the intermediary",
			"guidance": "We will contact intermediaries as part of our assessment of your application.",
			"questions": [
				{ "target_field": "ov_intermediary_sector__c" }
			],
			"routes": [
				{ "target_page": "10" }
			]
		},
		{
			"id": "10",
			"title": "Please provide the contact details of the intermediary",
			"guidance": "We will contact intermediaries as part of our assessment of your application.",
			"questions": [
				{ "target_field": "ov_intermediary_contact_name__c" },
				{ "target_field": "ov_intermediary_email__c" },
				{ "target_field": "ov_intermediary_contact_number__c" }
			],
			"routes": [
				{ "target_page": "11" }
			]
		},
		{
			"id": "11",
			"title": "Please add the commissioner(s) who will pay for the outcomes",
			"guidance": "You may add multiple commissioners, but if your project has a primary commissioner please ensure they are listed first. If the applicant is a commissioner you need not repeat contact details here, but reference the fact you are a commissioner so this is clear to us. ",
			"children": {
				"target_object": "Form_LCF_Commissioner_1__c",
				"target_field": "co_organisation_name__c",
				"child_relationship": "full_application_commissioners__r",
				"section": "lcf_full_app_overview_child_1"
			},
			"routes": [
				{ 
					"target_page": "12",
					"constraints": [
						{ "field": "ov_organisation_type__c", "operator": "equals", "value": "Local commissioner" }
					]
				},
				{ 
					"target_page": "13",
					"constraints": [
						{ "field": "ov_organisation_type__c", "operator": "equals", "value": "Service provider" }
					]
				},
				{ 
					"target_page": "14",
					"constraints": [
						{ "field": "ov_organisation_type__c", "operator": "equals", "value": "Intermediary" }
					]
				},
				{ "target_page": "15" }
			]
		},
		{
			"id": "12",
			"questions": [
				{ "target_field": "ov_service_provider_social_investment__c" }
			],
			"routes": [
				{ "target_page": "15" }
			]
		},
		{
			"id": "13",
			"questions": [
				{ "target_field": "ov_take_social_investment__c" }
			],
			"routes": [
				{ "target_page": "15" }
			]
		},
		{
			"id": "14",
			"questions": [
				{ "target_field": "ov_assist_sourcing_investment__c" }
			],
			"routes": [
				{ "target_page": "15" }
			]
		},
		{
			"id": "15",
			"questions": [
				{ "target_field": "ov_engaged_social_investors__c" }
			],
			"routes": [
				{ 
					"target_page": "16",
					"constraints": [
						{ "field": "ov_engaged_social_investors__c", "operator": "equals", "value": "Yes" }
					]
				},
				{ "target_page": "19" }
			]
		},
		{
			"id": "16",
			"questions": [
				{ "target_field": "ov_investor_involvement_confirmed__c" }
			],
			"routes": [
				{ "target_page": "17" }
			]
		},
		{
			"id": "16",
			"questions": [
				{ "target_field": "ov_investor_sector__c" }
			],
			"routes": [
				{ "target_page": "17" }
			]
		},
		{
			"id": "18",
			"questions": [
				{ "target_field": "ov_investor_commitment__c" }
			],
			"routes": [
				{ "target_page": "19" }
			]
		},
		{
			"id": "19",
			"questions": [
				{ "target_field": "ov_engaged_service_providers__c" }
			],
			"routes": [
				{ 
					"target_page": "20",
					"constraints": [
						{ "field": "ov_engaged_service_providers__c", "operator": "equals", "value": "Yes" }
					]
				},
				{ "target_page": "23" }
			]
		},
		{
			"id": "20",
			"questions": [
				{ "target_field": "ov_service_provider_identified__c" }
			],
			"routes": [
				{ "target_page": "21" }
			]
		},
		{
			"id": "21",
			"questions": [
				{ "target_field": "ov_service_provider_sector__c" }
			],
			"routes": [
				{ "target_page": "22" }
			]
		},
		{
			"id": "22",
			"questions": [
				{ "target_field": "ov_service_provider_plans__c" }
			],
			"routes": [
				{ "target_page": "23" }
			]
		},
		{
			"id": "23",
			"questions": [
				{ "target_field": "ov_vcse_involvement__c" }
			],
			"routes": [
				{ "target_page": "24" }
			]
		},
		{
			"id": "24",
			"title": "Details of the project's estimated outcomes payments",
			"questions": [
				{ "target_field": "ov_max_estimated_outcomes_payments__c" },
				{ "target_field": "ov_max_requested_funds__c" }
			],
			"routes": [
				{ "target_page": "25" }
			]
		},
		{
			"id": "25",
			"title": "Details of the project's estimated outcomes payments",
			"questions": [
				{ "target_field": "ov_services_paid_by_outcomes__c" }
			]
		}
	]
}
