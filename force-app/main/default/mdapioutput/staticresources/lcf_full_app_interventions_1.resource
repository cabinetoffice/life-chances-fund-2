{
	"id": "lcf_full_app_interventions_1",
	"target_object": "Form_LCF_Full_App_1__c",
	"parent_relationship": "application__r",
	"pages": [
		{
			"id": "1",
			"questions": [
				{ 
					"target_field": "iv_interventions_outline__c",
					"guidance": "If you don’t know the specific intervention at this stage, please give indicative examples of the types of intervention you expect to see (which could be based on current interventions)"
				}
			],
			"routes": [
				{ "target_page": "2" }
			]
		},
		{
			"id": "2",
			"questions": [
				{ 
					"target_field": "iv_interventions_approach__c",
					"guidance": "What is the evidence that supports your approach (e.g. existing provision, academic evidence, experts in the field)"
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
					"target_field": "iv_interventions_additional__c",
					"guidance": "A statutory service is one that a commissioner is required to provide by law."
				}
			]
		}
	]
}
