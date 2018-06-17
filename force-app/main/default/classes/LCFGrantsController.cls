/* __________________________________________________________________________________________________________________
   Name:		LCFGrantsController.cls
   Description: Controller class for LCF Grants page
					
   Date         Version Author          		Summary of Changes 
   ___________  _______ __________________		_____________________________________________________________________
   Apr 2018	    1.0    	M.Witchalls,Westbrook	Initial Release 
   Jun 2018 	1.1		M.Witchalls,Westbrook	Update Block Status with Approval Status when block has been submitted
   												Update Block Status with Issue Status when block has been issued
__________________________________________________________________________________________________________________ */        
public with sharing class LCFGrantsController extends COF_PageController {
	private static final String GRANTOBJECT = 'LCF_Grant__c';
    private static final String CONTACTEMAILFIELD = 'Contact_Email__c';
	private static final String[] QUERYFIELDS = new List<String>{'Name', 'Theme__c', 'Application__c', 'Application_ID__c'};
	private static final String[] STATUSFIELDS = new List<String>{
		'Status__c', 
		'bb_block_status__c', 
		'pp_block_status__c',
		'ab_block_status__c',
		'am_block_status__c'
	};
	private static final String baselineBlockQuery = '(SELECT bb_block_status__c, bb_issue_status__c FROM Form_LCF_Grant_Baseline_Blocks__r WHERE bb_block_status__c != \'HISTORY\')';
	private static final String paymentProfileQuery = '(SELECT pp_block_status__c, pp_issue_status__c FROM Form_LCF_Grant_Payment_Profiles__r WHERE pp_block_status__c != \'HISTORY\')';
	private static final String achievementQuery = '(SELECT ab_block_status__c, ab_approval_status__c FROM Form_LCF_Grant_Achievement_Blocks__r WHERE ab_block_status__c != \'HISTORY\')';
	private static final String annualBlockQuery = '(SELECT am_block_status__c, am_approval_status__c FROM Form_LCF_Grant_Annual_Blocks__r WHERE am_block_status__c != \'HISTORY\')';
	private static final String COMPLETE = 'COMPLETE';
	private static final String NOTSUBMITTED = 'Not Submitted';
	private static final String DRAFT = 'Draft';
	
	public COF_Form form {get;set;}
	public List<SObject> grants {get;set;} 
	public SObject thisGrant {get;set;}
    private ApexPages.StandardController stdCon;
    public String idString {get;set;}
	private String constraint;
	private List<String> fields;
		
	public LCFGrantsController(ApexPages.StandardController stdController) { 	
		this.idString = ApexPages.currentPage().getParameters().get('id');   		
		if (String.isNotBlank(this.idString)) {
			this.constraint = 'WHERE Application__c = \''+idString+'\'';
		} else {
			User u = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];	
			if (u.ContactId != null) {
				this.constraint = 'WHERE Contact__c = \''+u.ContactId+'\' AND Status__c = \'Project Launched\'';
			}
		}
        // Get the grant(s)	
        this.fields = new List<String>();
        this.fields.addAll(QUERYFIELDS);
        this.fields.addAll(STATUSFIELDS);
        this.fields.add(baselineBlockQuery);
        this.fields.add(paymentProfileQuery);
        this.fields.add(achievementQuery);
        this.fields.add(annualBlockQuery);
        this.grants = Query.objects(GRANTOBJECT, this.fields, constraint);
	}

    public PageReference newGrantAction() {
        if (this.idString != null && this.grants.size() == 0) { 
        	List<Application__c> apps = [SELECT Contact__c, Contact_Email__c FROM Application__c WHERE Id = :this.idString];
        	if (apps.size() > 0) {
        		String contactId = apps[0].Contact__c;
        		String contactEmail = apps[0].Contact_Email__c;
        		Query.createObject(GRANTOBJECT, this.idString, contactId, CONTACTEMAILFIELD, contactEmail);       		
        	}
	        // Get the grant(s)	
	        this.grants = Query.objects(GRANTOBJECT, this.fields, constraint);
        }   
 	    if (this.grants.size() > 0) {
 	    	this.thisGrant = grants[0];
 	    	this.idString = (String)this.thisGrant.get('Application__c');
 	    }
        System.debug('###grants: '+this.grants);
        
        // M.Witchalls June 2018 - Update Block Status with Approval Status when block has been submitted
        // M.Witchalls June 2018 - Update Block Status with Issue Status when block has been issued
        for (SObject obj: this.grants) { 
        	LCF_Grant__c grant = (LCF_Grant__c) obj;
        	if (grant.Form_LCF_Grant_Baseline_Blocks__r.size() > 0) {
        		grant.bb_block_status__c = grant.Form_LCF_Grant_Baseline_Blocks__r[0].bb_block_status__c;
        		if (grant.bb_block_status__c == COMPLETE && grant.Form_LCF_Grant_Baseline_Blocks__r[0].bb_issue_status__c != DRAFT) {
        			grant.bb_block_status__c = grant.Form_LCF_Grant_Baseline_Blocks__r[0].bb_issue_status__c;
        		}
        	}
        	if (grant.Form_LCF_Grant_Payment_Profiles__r.size() > 0) {
        		grant.pp_block_status__c = grant.Form_LCF_Grant_Payment_Profiles__r[0].pp_block_status__c;
        		if (grant.pp_block_status__c == COMPLETE && grant.Form_LCF_Grant_Payment_Profiles__r[0].pp_issue_status__c != DRAFT) {
        			grant.pp_block_status__c = grant.Form_LCF_Grant_Payment_Profiles__r[0].pp_issue_status__c;
        		}
        	}
        	if (grant.Form_LCF_Grant_Achievement_Blocks__r.size() > 0) {
        		grant.ab_block_status__c = grant.Form_LCF_Grant_Achievement_Blocks__r[0].ab_block_status__c;
        		if (grant.ab_block_status__c == COMPLETE && grant.Form_LCF_Grant_Achievement_Blocks__r[0].ab_approval_status__c != NOTSUBMITTED) {
        			grant.ab_block_status__c = grant.Form_LCF_Grant_Achievement_Blocks__r[0].ab_approval_status__c;
        		}
        	}
        	if (grant.Form_LCF_Grant_Annual_Blocks__r.size() > 0) {
        		grant.am_block_status__c = grant.Form_LCF_Grant_Annual_Blocks__r[0].am_block_status__c;
        		if (grant.am_block_status__c == COMPLETE && grant.Form_LCF_Grant_Annual_Blocks__r[0].am_approval_status__c != NOTSUBMITTED) {
        			grant.am_block_status__c = grant.Form_LCF_Grant_Annual_Blocks__r[0].am_approval_status__c;
        		}
        	}
        }
		return SIB_Utilities.checkLoggedInStatus();
    }

}