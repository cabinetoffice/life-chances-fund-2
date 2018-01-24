{
	"id": "lcf_full_app_evaluation_1",
	"target_object": "Form_LCF_Full_App_1__c",
	"parent_relationship": "application__r",
	"pages": [
		{
			"id": "1",
			"questions": [
				{ "target_field": "ev_independent_evaluation__c" }
			],
			"routes": [
				{
					"target_page": 2,
					"constraints": [
						{ "field": "ev_independent_evaluation__c", "operator": "equals", "value": "Yes" }
					]
				},
				{ "target_page": "3" }
			]
		},
		{
			"id": "2",
			"questions": [
				{ "target_field": "ev_evaluation_commissioning_progress__c" }
			],
			"routes": [
				{ "target_page": "4" }
			]
		},
		{
			"id": "3",
			"questions": [
				{ "target_field": "ev_sharing_learning_approach__c" }
			],
			"routes": [
				{ "target_page": "4" }
			]
		},
		{
			"id": "4",
			"questions": [
				{ "target_field": "ev_evaluation_funding_allocated__c" }
			],
			"routes": [
				{
					"target_page": 5,
					"constraints": [
						{ "field": "ev_evaluation_funding_allocated__c", "operator": "equals", "value": "Yes" }
					]
				}
			]
		},
		{
			"id": "5",
			"questions": [
				{ "target_field": "ev_evaluation_funding__c" }
			]
		}
	]
}