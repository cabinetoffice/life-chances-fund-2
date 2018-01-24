{
	"id": "lcf_full_app_outcomes_child_1",
	"target_object": "Form_LCF_Outcome_1__c",
	"status_field": "ou_section_status__c",
	"parent_relationship": "full_application__r",
	"pages": [
		{
			"id": "1",
			"questions": [
				{ "target_field": "ou_description__c" }
			],
			"routes": [
				{ "target_page": "2" }
			]
		},
		{
			"id": "2",
			"questions": [
				{ "target_field": "ou_baseline__c" }
			],
			"routes": [
				{ "target_page": "3" }
			]
		},
		{
			"id": "3",
			"questions": [
				{ "target_field": "ou_social_impact__c" }
			],
			"routes": [
				{ "target_page": "4" }
			]
		},
		{
			"id": "4",
			"questions": [
				{ "target_field": "ou_timescale__c" }
			],
			"routes": [
				{ "target_page": "5" }
			]
		},
		{
			"id": "5",
			"questions": [
				{ "target_field": "ou_payment__c" }
			]
		}
	]
}
