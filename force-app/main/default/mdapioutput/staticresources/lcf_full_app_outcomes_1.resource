{
	"id": "lcf_full_app_outcomes_1",
	"target_object": "Form_LCF_Full_App_1__c",
	"parent_relationship": "application__r",
	"pages": [
		{
			"id": "1",
			"title": "Please provide details of the outcomes your project will deliver",
			"children": {
				"target_object": "Form_LCF_Outcome_1__c",
				"target_field": "ou_description__c",
				"child_relationship": "full_application_outcomes__r",
				"section": "lcf_full_app_outcomes_child_1"
			},
			"routes": [
				{ "target_page": "2" }
			]
		},
		{
			"id": "2",
			"questions": [
				{ 
					"target_field": "ou_relate__c",
					"guidance": "If your project has more than one outcome, explain how the outcomes are related to each other. For example, how do additional outcomes demonstrate progress towards the primary outcome (such as, completing training may serve as proxy for gaining employment, or improved scores on a wellbeing star indicate movement towards longer term reductions in GP visits)."
				}
			],
			"routes": [
				{ "target_page": "3" }
			]
		},
		{
			"id": "3",
			"questions": [
				{ 
					"target_field": "ou_perverse_incentives__c",
					"guidance": "Perverse incentives are incentives that could cause unintended and undesirable results, and will undermine the effectiveness of the project. Please explain how such incentives could arise and how you will manage them"
				}
			],
			"routes": [
				{ "target_page": "4" }
			]
		},
		{
			"id": "4",
			"questions": [
				{ 
					"target_field": "ou_attributable__c",
					"guidance": "Please explain how you will make sure that outcomes payments are only made for outcomes achieved because of your project and not arising from other interventions (i.e. the outcomes would have been achieved whether your project took place or not)"
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
					"target_field": "ou_justification__c",
					"guidance": "Explain why these outcomes were decided to be the most suitable for your project"
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
					"target_field": "ou_payment_determination__c",
					"guidance": "Set out how you arrived at the outcomes payments and how you have demonstrated value for money to the commissioner."
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
					"target_field": "ou_additional__c",
					"guidance": "If you intend to measure any additional outcomes which are not related to payments but which will further illustrate the impact your project is having, please provide details"
				}
			]
		}
	]
}
