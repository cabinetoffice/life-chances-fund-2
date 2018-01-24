{
	"id": "lcf_full_app_financials_1",
	"target_object": "Form_LCF_Full_App_1__c",
	"parent_relationship": "application__r",
	"pages": [
		{
			"id": "1",
			"title": "What are the maximum cashable savings during project life?",
			"guidance": "A cashable saving is where the benefit is reflected in a budget line, and could include both fixed and variable costs. For example, if an intervention reduced youth offending to the extent where a youth offending institution could be closed this would generate cashable savings from both fixed (selling the building) and variable (utilities) costs.",
			"questions": [
				{ "target_field": "fn_max_savings_commissioners__c" },
				{ "target_field": "fn_max_savings_not_involved__c" },
				{ "target_field": "fn_max_savings_government__c" },
				{ "target_field": "fn_max_savings_other__c" },
				{ "target_field": "fn_max_savings_total__c" }
			],
			"routes": [
				{ "target_page": "2" }
			]
		},
		{
			"id": "2",
			"title": "What are the maximum cashable benefits through costs avoided?",
			"guidance": "Savings could be as a result of costs avoided, generating a longer term cashable benefit after the project finishes as well as cashable savings achieved during the project life.",
			"questions": [
				{ "target_field": "fn_max_benefits_commissioners__c" },
				{ "target_field": "fn_max_benefits_not_involved__c" },
				{ "target_field": "fn_max_benefits_government__c" },
				{ "target_field": "fn_max_benefits_other__c" },
				{ "target_field": "fn_max_benefits_total__c" }
			],
			"routes": [
				{ "target_page": "3" }
			]
		},
		{
			"id": "3",
			"title": "What are the maximum non-cashable savings or benefits?",
			"guidance": "A non-cashable saving is where the expected benefit does not directly correlate to a financial saving. This includes delivering better value for money services, reducing demand for a service (and thus future expenditure), improving outcomes for service users, and innovation.",
			"questions": [
				{ "target_field": "fn_max_non_cash_commissioners__c" },
				{ "target_field": "fn_max_non_cash_not_involved__c" },
				{ "target_field": "fn_max_non_cash_government__c" },
				{ "target_field": "fn_max_non_cash_other__c" },
				{ "target_field": "fn_max_non_cash_total__c" }
			],
			"routes": [
				{ "target_page": "4" }
			]
		},
		{
			"id": "4",
			"questions": [
				{ "target_field": "fn_saving_calculation_methodology__c" }
			],
			"routes": [
				{ "target_page": "5" }
			]
		},
		{
			"id": "5",
			"questions": [
				{
					"target_field": "fn_savings_exceed_contribution__c",
					"guidance": "By significantly, we mean by over £1m or by more than 25% of the total savings (whichever is the greatest). The LCF may still support your project, but we will need a stronger case from your project to warrant this support."
				}
			],
			"routes": [
				{
					"target_page": 6,
					"constraints": [
						{ "field": "fn_savings_exceed_contribution__c", "operator": "equals", "value": "Yes" }
					]
				},
				{ "target_page": "7" }
			]
		},
		{
			"id": "6",
			"questions": [
				{ "target_field": "fn_top_up_justification__c" }
			],
			"routes": [
				{ "target_page": "7" }
			]
		},
		{
			"id": "7",
			"title": "Please provide financial details of the next best alternative to your proposed SIB provision",
			"guidance": "It is acknowledged that it may be difficult to provide accurate figures where there is currently multiple and fractured delivery of services. Please provide your best estimates.",
			"questions": [
				{ "target_field": "fn_alternative_service_spend__c" },
				{ 
					"target_field": "fn_alternative_overhead_spend__c",
					"guidance": "This should include cost of raising funds if applicable."
				},
				{ "target_field": "fn_alternative_service_users_engage__c" },
				{ "target_field": "fn_alternative_service_users_alt__c" }
			],
			"routes": [
				{ "target_page": "8" }
			]
		},
		{
			"id": "8",
			"title": "Please provide financial details of your proposed SIB provision",
			"guidance": "It is acknowledged that it may be difficult to provide accurate figures where there is currently multiple and fractured delivery of services. Please complete to the best of your ability.",
			"questions": [
				{ "target_field": "fn_proposed_sib_service_spend__c" },
				{ 
					"target_field": "fn_proposed_sib_overhead_spend__c",
					"guidance": "This should include cost of raising funds."
				},
				{ "target_field": "fn_proposed_sib_service_users__c" },
				{ "target_field": "fn_proposed_sib_service_users_success__c" }
			],
			"routes": [
				{ "target_page": "9" }
			]
		},
		{
			"id": "9",
			"questions": [
				{ 
					"target_field": "fn_value_for_money__c",
					"guidance": "Considering the expected cost of your project, and based on the financial and non-financial benefits outlined above, briefly summarise how your project will deliver value for money. This should include consideration of how the costs, savings and wider benefits compare with existing services." 
				}
			],
			"routes": [
				{ "target_page": "10" }
			]
		},
		{
			"id": "10",
			"questions": [
				{ "target_field": "fn_costs_covered_outcomes__c" }
			],
			"routes": [
				{
					"target_page": 11,
					"constraints": [
						{ "field": "fn_costs_covered_outcomes__c", "operator": "equals", "value": "No" }
					]
				},
				{ "target_page": "14" }
			]
		},
		{
			"id": "11",
			"questions": [
				{ "target_field": "fn_additional_funding_required__c" }
			],
			"routes": [
				{ "target_page": "12" }
			]
		},
		{
			"id": "12",
			"questions": [
				{ "target_field": "fn_additional_funding_secured__c" }
			],
			"routes": [
				{
					"target_page": 13,
					"constraints": [
						{ "field": "fn_additional_funding_secured__c", "operator": "equals", "value": "No" }
					]
				},
				{ "target_page": "14" }
			]
		},
		{
			"id": "13",
			"questions": [
				{ "target_field": "fn_additional_funding_due__c" }
			],
			"routes": [
				{ "target_page": "14" }
			]
		},
		{
			"id": "14",
			"questions": [
				{ "target_field": "fn_planning_started__c" }
			],
			"routes": [
				{
					"target_page": 15,
					"constraints": [
						{ "field": "fn_planning_started__c", "operator": "equals", "value": "Yes" }
					]
				},
				{ "target_page": "16" }
			]
		},
		{
			"id": "15",
			"questions": [
				{ "target_field": "fn_planning_progress__c" }
			]
		},
		{
			"id": "16",
			"questions": [
				{ "target_field": "fn_planning_start_date__c" }
			]
		}
	]
}
