/* __________________________________________________________________________________________________________________
   Name:		QuestionsController.cls
   Description: Controller class for Questions Visualforce page
					
   Date         Version Author          		Summary of Changes 
   ___________  _______ __________________		_____________________________________________________________________
   2017		    1.0    	Cabinet Office			Initial Release 
   Jan 2018		1.1		M.Witchalls, Westbrook	Page navigation changes (see page javascript); section status updates
   Feb 2018		1.2		M.Witchalls, Westbrook	Readonly view and reference lookup from Setup form to Full Application
   												Introduction of rich text guidance 
   Mar 2018		1.3		M.Witchalls, Westbrook	Correction to child question check
   												Introduction of file uploads
   												Use of default values to indicate optional fields
   												Use of primary count field to check that primary is present
   Apr 2018		1.4		M.Witchalls, Westbrook	Introduction of EOI form: use of Commissioner/Outcome record types
   												Check for validation errors
   												Copy child records from a previous formFchi
   												Introduction of child arrays with totals
   												Constraints attribute on questions and fields
   												Calculated fields
   May 2018		1.5		M.Witchalls, Westbrook	Grant Management version
___________________________________________________________________________________________________________________ */        
public class QuestionsController extends COF_PageController {
	private static final String INCOMPLETE = 'INCOMPLETE';
	private static final String HISTORY = 'HISTORY';
	private static final String INPROGRESS = 'In Progress';
	private static final String ADDANOTHER = '+ Add another';
    private static final String APPLICATIONFIELD = 'application__c';
    private static final String GRANTFIELD ='lcf_grant__c';
	private static final String PRIMARYFIELDID = 'primary__c';
	private static final String FULLAPPOBJECT = 'Form_LCF_Full_App_1__c';
	private static final String SETUPOBJECT = 'Form_LCF_Setup_1__c';
	private static final String STAKEHOLDEROBJECT = 'Form_LCF_Commissioner_1__c';
	private static final String OUTCOMEOBJECT = 'Form_LCF_Outcome_1__c';
	private static final String INVESTOROBJECT = 'Form_LCF_Setup_Investor_1__c';
	private static final String GRANTOUTCOMEOBJECT = 'Form_LCF_Grant_Outcome_1__c';
	private static final String ORGTYPEFIELD = 'st_organisation_type__c';
	private static final String COMMISSIONERTYPE = 'Commissioner';
	private static final String INTERMEDIARYTYPE = 'Intermediary';
	private static final String FULLAPPRECORDTYPE = 'Full Application';
	private static final String EOIRECORDTYPE = 'EOI';
	private static final String SETUPRECORDTYPE = 'Setup';
	private static final String FULLAPPPARENT = 'full_application__c';
	private static final String EOIPARENT = 'eoi__c';
	private static final String SETUPPARENT = 'full_award_setup__c';
	private static final String BASELINEPARENT = 'grant_baseline__c';
	private static final String ACHIEVEMENTPARENT = 'grant_achievement__c';
	private static final String OUTCOME = 'Outcome';
	private static final String INVESTOR = 'Investor';
 
    // M.Witchalls Feb 2018 
    public Boolean readOnlyMode {get;set;}
    public String fromFormId {get;set;}
	
    public COF_Form form {get;set;}
    public COF_Section section {get;set;} 
    public COF_QuestionSet questionSet {get; set;}
    public COF_Page currentPage {get; set;}
    public List<COF_Field> fields {get; set;}
    public List<String> fieldValueList {get; set;} 
    public String title {get;set;}
    public String subtitle {get;set;}
    public String subtitle2 {get;set;}
    public String index {get;set;}

    public SObject application {get;set;} 
    public SObject grant {get;set;} 
    public SObject targetObject {get;set;} 
    public SObject copyObject {get;set;}
    public List<SObject> targetObjects {get; set;}

	public String targetFieldIdentifier {get;set;}
    public String modifyChildIdentifier {get;set;}
    public String removeChildId {get;set;}
	public Boolean errorsFound {get; set;}
	public Integer errorPageCount {get; set;}
	public String pageId {get; set;}
	public String previousPageId {get; set;}
	public String previousPageErrors {get; set;}
	public String shortTitle {get; set;}
	public String referenceURL {get; set;}
	public String referenceGuidance {get; set;}
	public String copyGuidance {get; set;}
    public String endWarningText {get;set;}
    public Boolean showWarning {get;set;}
    public Boolean saveReqd {get;set;}
    public Boolean childPage {get;set;}
    public Boolean grandchildRelationship {get;set;}
    public String returnPage {get;set;}
	
	public List<String> fileNames {get; set;}
    public List<String> attachedFiles {get;set;}
    public Integer filecount {get;set;}
    public String uploadSuccess {get;set;}
    public List<COF_FileVersion> fileVersionList {get; set;}
    //public List<ContentVersion> fileVersionList {get; set;}
    public COF_Field filesField {get; set;}
    public String filesKey {get; set;}
    public String contentDocId {get; set;}
    public Blob fileBody {get; set;}
    public String fileName {get; set;}
    
	public SIB_Section_Text__c guidanceText {get;set;}
	public String addLabel {get;set;}
	public String copyLabel {get;set;}
	public String countField {get;set;}
	public String primaryCountField {get;set;}
	public Double childCount {get;set;}
    public Double primaryCount {get;set;}
    public String primaryValue {get;set;}
    public String periodTitle {get;set;}
    
    public String widthClass  {get;set;}
    public String fieldWidth1 {get;set;}
    public String fieldWidth2 {get;set;}
    public String fieldWidth3 {get;set;}
    public String fieldWidth4 {get;set;}
    public String fieldWidth5 {get;set;}
    public String fieldWidth6 {get;set;}
    public String primaryWidth{get;set;}
    public Boolean removeReqd {get;set;}
	      
	private Map<String, COF_Field> fieldMap;
    private String statusField;
    private String blockStatusField;
    private SObject targetObjectOriginal;
    private COF_Router router;
    private String targetIdentifier;
    private Map<String,String> childNumberMap;
    
    public QuestionsController() {
        this.router = new COF_Router();
    	this.errorsFound = false;
    	this.errorPageCount = 0;
    	this.readOnlyMode = false;
    	this.endWarningText = '';
    	this.primaryValue = PRIMARYFIELDID;
    	this.primaryCount = 0;
    	this.childCount = 0;
    	this.saveReqd = false;
    	this.childPage = false;
    	this.grandchildRelationship = false;
    	this.widthClass = 'column-two-thirds';
    	this.fieldWidth1 = '60%';
    	this.fieldWidth2 = '20%';
    	this.fieldWidth3 = '0%';
    	this.fieldWidth4 = '0%';
    	this.fieldWidth5 = '0%';
    	this.fieldWidth6 = '0%';
    	this.primaryWidth = '0%';
    	this.title = this.getPageParam('title');
    	this.subtitle = this.getPageParam('subtitle');
    	this.subtitle2 = this.getPageParam('subtitle2');
    	this.periodTitle = this.getPageParam('periodtitle');
    	
    	// M.Witchalls Jan 2018: these parameters required for page navigation javascript
    	this.previousPageErrors = this.getPageParam('errorPageCount');
    	if (this.previousPageErrors == null) this.previousPageErrors = '0';  	
    	this.previousPageId = null;   	
    	this.pageId = this.getPageIdentifierParam();
    	this.previousPageId = this.getPreviousPageIdentifierParam();
    	if (previousPageId == null) previousPageId = '0';
    	system.debug('###previousPageId: '+this.previousPageId);
    	this.returnPage = this.getPageParam('returnPage');
    	
    	this.fromFormId = this.getFromFormIdentifierParam();
        if (String.isNotBlank(this.getFormIdentifierParam())) {    	
        	COF_Config config = COF_Config.load(this.getFormIdentifierParam());
        	this.form = config.getForm(this.getFormIdentifierParam());
        	// M.Witchalls May 2018: Block status for grant management
        	this.blockStatusField = this.form.block_status_field;
        	this.section = this.form.getSection(this.getSectionIdentifierParam());
	         
	        // M.Witchalls Jan 2018: Get section status value 
	        if (this.section != null) { // parent object
	            this.questionSet = this.section.getQuestionSet();
	            this.statusField = this.section.status_field;
	            this.shortTitle = this.section.short_title;
	        } else { // child object 
	            this.questionSet = COF_QuestionSet.load(this.getSectionIdentifierParam());
	            this.statusField = this.questionSet.status_field;
	            this.shortTitle = this.questionSet.short_title;
	        	this.countField = this.questionSet.child_count_field;
	        	this.primaryCountField = this.questionSet.primary_count_field;
	            this.childPage = true;
	        }
    		system.debug('#####this.questionSet.primary_count_field: '+this.questionSet.primary_count_field);
	
	        this.application = this.getApplication(); 
	        this.grant = this.getGrant();
	    	
	        this.currentPage = this.questionSet.getPage(this.getPageIdentifierParam());
	        if (this.currentPage.child_of_child == 'true') this.grandchildRelationship = true;
	        
	        // M.Witchalls Mar 2018 - count fields
            if (this.currentPage.children != null) {
            	this.countField = this.currentPage.children.child_count_field;
	        	this.primaryCountField = this.currentPage.children.primary_count_field;	            	
            }
	        
	        // M.Witchalls Feb 2018: Guidance may be rich text so guidance is not derived from guidance_id (like title and warning are): 
	        //                       guidance_id rich text is displayed directly from the SIB_Section_Text__c object
	        if (this.currentPage.guidance_id != null) this.guidanceText = 
	        	SIB_Utilities.getSectionText(this.questionSet.target_object + ':' + this.currentPage.guidance_id);
	        	
	        if (this.currentPage.end_warning != null) {
	        	this.endWarningText = this.currentPage.end_warning;
	        	this.showWarning = true;
	        }
	        	        
	        // M.Witchalls May 2018: Substitute child index number in title where applicable
	        this.index = this.getPageParam('index');
	        system.debug('@@@@@this.currentPage.title: '+this.currentPage.title);
	        if (this.index != null && this.currentPage.title != null) {
	        	this.currentPage.title = this.currentPage.title.replace('{{index}}', index);
	        }
	        system.debug('@@@@@this.currentPage.title: '+this.currentPage.title);
	        
	        this.fields = new List<COF_Field>(); 
	        this.fieldMap = new Map<String, COF_Field>();
	        
	        List<COF_Field> fields = new List<COF_Field>();
	        Set<String> fieldIdentifierSet = new Set<String>{'Id','Name'};
	        
	        Set<String> copyIdentifierSet = new Set<String>{};
	        if (this.questionSet.parent_relationship != null) fieldIdentifierSet.add(this.questionSet.parent_relationship+'.Id');
	        if (this.questionSet.status_relationship != null) fieldIdentifierSet.add(this.questionSet.status_relationship+'.Id');
	        
	        if (this.statusField != null) {
		        if (!this.childPage) { // parent object
		            fieldIdentifierSet.add(this.statusField);
		            // M.Witchalls May 2018 - block status for grant management
		            if (this.blockStatusField != null) fieldIdentifierSet.add(this.blockStatusField);
		 		} else if (this.questionSet.status_relationship != null) { // child object - get parent status (status_relationship used by grandchildren)
		 			fieldIdentifierSet.add(this.questionSet.status_relationship+'.'+this.statusField);
		        } else {
		            fieldIdentifierSet.add(this.questionSet.parent_relationship+'.'+this.statusField);
		        }
	        }
		    // M.Witchalls May 2018 - approval status for grant management
	        if (this.form.approval_status_field != null) {
		        if (!this.childPage) { // parent object
		            fieldIdentifierSet.add(this.form.approval_status_field);
		 		} else if (this.questionSet.status_relationship != null) { // child object - get parent status (status_relationship used by grandchildren)
		 			fieldIdentifierSet.add(this.questionSet.status_relationship+'.'+this.form.approval_status_field);
		        } else {
		            fieldIdentifierSet.add(this.questionSet.parent_relationship+'.'+this.form.approval_status_field);
		        }
	        }
	        if (this.form.issue_status_field != null) {
		        if (!this.childPage) { // parent object
		            fieldIdentifierSet.add(this.form.issue_status_field);
		 		} else if (this.questionSet.status_relationship != null) { // child object - get parent status (status_relationship used by grandchildren)
		 			fieldIdentifierSet.add(this.questionSet.status_relationship+'.'+this.form.issue_status_field);
		        } else {
		            fieldIdentifierSet.add(this.questionSet.parent_relationship+'.'+this.form.issue_status_field);
		        }
	        }
	        
	        // M.Witchalls Mar 2018 - count fields
	        if (this.countField != null) {
		        if (!this.childPage || this.grandchildRelationship) { // parent object or child object with children
		            fieldIdentifierSet.add(this.countField);
		 		} else { // child object - get count from parent
		            fieldIdentifierSet.add(this.questionSet.parent_relationship+'.'+this.countField);
		        }
	        }
	        if (this.primaryCountField != null) {
		        if (!this.childPage || this.grandchildRelationship) { // parent object or child object with children
		            fieldIdentifierSet.add(this.primaryCountField);
		 		} else { // child object - get count from parent
		            fieldIdentifierSet.add(this.questionSet.parent_relationship+'.'+this.primaryCountField);
		        }
	        }
	        
	        // M.Witchalls May 2018: history fields
			if (this.form.title_append_field != null) {	
	        	fieldIdentifierSet.add(this.form.title_append_field);
			}
	        if (this.currentPage.title_append_field != null) {
	        	fieldIdentifierSet.add(this.currentPage.title_append_field);
	        }
	        
	        // M.Witchalls Apr 2018 - total fields for child arrays
            if (this.currentPage.children != null) {
            	if (this.currentPage.children.total_field2 != null) fieldIdentifierSet.add(this.currentPage.children.total_field2);
             	if (this.currentPage.children.total_field3 != null) fieldIdentifierSet.add(this.currentPage.children.total_field3);
             	if (this.currentPage.children.total_field4 != null) fieldIdentifierSet.add(this.currentPage.children.total_field4);
             	if (this.currentPage.children.total_field5 != null) fieldIdentifierSet.add(this.currentPage.children.total_field5);
             	if (this.currentPage.children.total_field6 != null) fieldIdentifierSet.add(this.currentPage.children.total_field6);
            }
	         
	        // M.Witchalls Feb 2018: reference lookup from Setup form to Full Application form
	        if (this.form.reference_id != null && this.currentPage.reference_section != null && this.currentPage.reference_id != null) { 
	        	this.referenceURL = referencePageURL(this.form.reference_id, this.currentPage.reference_section, this.currentPage.reference_id);
	        	this.referenceGuidance = this.currentPage.reference_guidance;
	        	system.debug('####this.referenceURL: '+this.referenceURL);
	        }
	         
	        // M.Witchalls May 2018: reference copy from Grant form to Setup form
	        if (this.currentPage.copy_guidance != null) { 
	        	this.copyGuidance = this.currentPage.copy_guidance;
	        }
	        
	        if (this.currentPage.questions != null) {
		        for (COF_QuestionSet.COF_Question question : this.currentPage.questions) {
		            fieldIdentifierSet.add(question.target_field);
		            if (question.copy_from_field != null) copyIdentifierSet.add(question.copy_from_field);
		            
		            COF_Field newField = new COF_Field(question.target_field, this.questionSet.target_object);
		            if (newField.guidance == null && question.guidance != null) newField.guidance = question.guidance;
		            if (newField.recommendedWordLimit == null && question.recommended_word_limit != null) {
		                newField.recommendedWordLimit = question.recommended_word_limit;
		            }
		            if (question.application_field != null) newField.applicationField = question.application_field;
		            
	        		// M.Witchalls Apr 2018 - for calculated fields
		            if (question.calculated == 'true') { 
		            	newField.isCalculated = true; 
		            }
		            if (question.is_display == 'true') { 
		            	newField.isDisplay = true;
		            }
		            if (question.add_to != null) {
		            	newField.addToField = question.add_to;
		            }
		            if (question.copy_from_field != null) {
		            	newField.copyFromField = question.copy_from_field;
		            }
		            
		            // M.Witchalls Apr 2018 constraint attribute
		            if (question.constraints != null) {
		            	newField.constraints = question.constraints;
	                    for (COF_QuestionSet.COF_Constraint constraint : question.constraints) {
	                    	if (!fieldIdentifierSet.contains(constraint.field)) {
	                    		fieldIdentifierSet.add(constraint.field);
	                    	}
	                    }
		            }
		            this.fields.add(newField);
		            this.fieldMap.put(newField.identifier, newField);
		        }
	        }
	        if (this.currentPage.routes != null) {
	        	for (COF_QuestionSet.COF_Route route : this.currentPage.routes) {
	                // Determine if constraints apply
	                if (route.constraints != null) {
	                    for (COF_QuestionSet.COF_Constraint constraint : route.constraints) {
	                    	if (!fieldIdentifierSet.contains(constraint.field)) {
	                    		fieldIdentifierSet.add(constraint.field);
	                    	}
	                    }
	                }
	        	}
	        }
	        if (this.currentPage.files != null) { 
            	fieldIdentifierSet.add(this.currentPage.files.target_field);
	        }
	
	        System.debug('###this.questionSet.target_object: '+this.questionSet.target_object);
	        System.debug('###this.questionSet.copy_object: '+this.questionSet.copy_object);
	        System.debug('@@@@this.questionSet.parent_relationship: '+this.questionSet.parent_relationship);
	        this.targetIdentifier = this.getRecordIdentifierParam();
	        system.debug('###targetIdentifier: '+targetIdentifier);
	        if (this.targetIdentifier == null) {
	        	if (this.grant == null) {
	            	this.targetObject = Query.object(this.questionSet.target_object, fieldIdentifierSet, 'WHERE ' +  this.questionSet.parent_relationship + '.Name = \'' + this.getApplicationIdentifierParam() + '\'');
	        	} else {
	            	this.targetObject = Query.object(this.questionSet.target_object, fieldIdentifierSet, 
						            		'WHERE ' +  this.questionSet.parent_relationship + '.Name = \'' + this.getGrantIdentifierParam()
						            		 + '\' AND '+ this.form.block_status_field + ' != \''+HISTORY+'\'');	        		
	        	}
	        } else {
	            this.targetObject = Query.object(this.questionSet.target_object, fieldIdentifierSet, 'WHERE ' +  'Name = \'' + this.targetIdentifier + '\'');            
	        }
	        this.targetObjectOriginal = this.targetObject.clone(true, true, false, false);	// M.Witchalls Jan 2018: deep clone copy
	    
	        // M.Witchalls May 2018: Append special field to title for history
	        if (this.form.title != null && this.form.title_append_field != null) {
	        	COF_Field f = new COF_Field(this.form.title_append_field, this.form.target_object);
	        	this.prepareField(f);
	        	if (f.value != null) {
		        	String appendText = (this.form.title_append_text != null) ? this.form.title_append_text : ' ';
		        	this.form.title = this.form.title + appendText + f.value;
	        	}
	        }
	        
	        // M.Witchalls May 2018: Append special field to title for history
	        if (this.currentPage.title != null && this.currentPage.title_append_field != null) {
	        	COF_Field f = new COF_Field(this.currentPage.title_append_field, this.questionSet.target_object);
	        	this.prepareField(f);
	        	if (f.value != null) {
		        	String appendText = (this.currentPage.title_append_text != null) ? this.currentPage.title_append_text : ' ';
		        	this.currentPage.title = this.currentPage.title + appendText + f.value;
	        	}
	        }
	        
	        if (copyIdentifierSet.size() > 0) {
	        	List<SObject> objectList = Query.objects(this.questionSet.copy_object, copyIdentifierSet, 'WHERE application__c = \'' + this.grant.get('application__c') + '\'');
	        	if (objectList.size() > 0) this.copyObject = objectList[0];
				system.debug('this.copyObject: '+this.copyObject); 
	        } 
     	
	        // M.Witchalls Apr 2018 - ability to set readonly mode
	        if (this.currentPage.readonly != null && this.currentPage.readonly == 'true') {
	        	this.readOnlyMode = true;
	        } else {
	    	// M.Witchalls Apr 2018: for readonly view (if application form not in 'Draft' status, or for grant forms, not submitted for approval or approved)  
	    		String parentRelationship = null;
	    		if (this.childPage) parentRelationship = (this.questionSet.status_relationship != null) ? this.questionSet.status_relationship : this.questionSet.parent_relationship;    
		    	this.readOnlyMode = this.getReadOnlyMode(this.application, this.form, this.targetObject, parentRelationship); 
	        }
		    system.debug('#####this.readOnlyMode: '+this.readOnlyMode);
	
	        // M.Witchalls Feb 2018 - for readonly access
	        for (COF_Field f: this.fields) {
	        	for (SelectOption opt: f.values) {
	        		if (this.readOnlyMode) opt.setDisabled(true);
	        	}
	        }
        }
    }
       
    public PageReference initialAction() {        
        // (Create has to be done here since no DML allowed in constructor)
        
        if (this.currentPage.questions != null) {
        	this.saveReqd = true;
            this.prepareQuestions();
        }

        if (this.currentPage.children != null) {
        	this.saveReqd = true;
            this.prepareChildren();
        }

        if (this.currentPage.files != null) {
        	this.saveReqd = true;
            this.prepareFiles();
        }
        
        return SIB_Utilities.checkLoggedInStatus();
    }
    
    // M.Witchalls Jan 2018: Lookups to Full Application from Setup Form
	public String referencePageURL(String refForm, String refSection, String refPage) {
        PageReference referencePage = Page.questions;
        referencePage.getParameters().put('form', refForm);
        referencePage.getParameters().put('app', this.getApplicationIdentifierParam());
        referencePage.getParameters().put('section', refSection);
        referencePage.getParameters().put('page', refPage);
        referencePage.getParameters().put('fromForm', this.getFormIdentifierParam());
        return referencePage.getUrl();
	}

    public void prepareQuestions() {
    
        // Manually handle our custom date fields and multi-select fields
        for (COF_Field field : this.fields) {
        	prepareField(field);
        }
        
        if (!this.readOnlyMode) calculateTotals();
    }

    public void prepareField(COF_Field field) {

        // Manually handle our custom date fields and multi-select fields
    	system.debug('@@@@@field: '+field);
    	
   		if (field.warningText != null) this.endWarningText += field.warningText + '\n';
   		
    	field.value = String.valueOf(this.targetObject.get(field.identifier));
    	if (field.value == null && field.applicationField != null) this.targetObject.put(field.identifier, this.application.get(field.applicationField));
    	field.value = String.valueOf(this.targetObject.get(field.identifier));
     	
	    // M.Witchalls Apr 2018 constraint attribute
    	field.isValid = true;
    	if (field.constraints != null) {
            for (COF_QuestionSet.COF_Constraint constraint : field.constraints) {
            	field.isValid = this.router.validConstraint(constraint, this.targetObject.get(constraint.field));
            }
            system.debug('@@@@field with constraint: '+field);
    	}
    	if (!field.isValid) this.targetObject.put(field.identifier, null);
    	
        if (field.isDateField == true) {
            Date currentDate = (Date) this.targetObject.get(field.identifier);
            if (!this.readOnlyMode && field.defaultValue == 'TODAY()') currentDate = System.today();
            if (currentDate != null) {
                field.dateDay = String.valueOf(currentDate.day());
                field.dateMonth = String.valueOf(currentDate.month());
                field.dateYear = String.valueOf(currentDate.year());
            	field.value = field.dateDay.leftPad(2,'0')+'/'+field.dateMonth.leftPad(2,'0')+'/'+field.dateYear;
            }
        }
        if (field.isRatio == true && field.value != null) {
        	field.ratioPart = field.value.substring(2);
        }
        if (field.isSelectField == true) {
            if (field.value != null) { 
                Set<String> valueSet = new Set<String>();
                valueSet.addAll(field.value.split(';\\s*'));
                for (COF_Field.CheckBoxOption opt: field.optionList) {
                    if (valueSet.contains(opt.value)) opt.selected = true;
                }
            }
        }
        if (field.identifier == PRIMARYFIELDID) {	// primary Boolean field
         	if (this.countField != null) {         		
        		this.childCount = (Double)this.targetObject.getSObject(this.questionSet.parent_relationship).get(this.countField);
        	}
        	if (this.primaryCountField != null) {         		
        		this.primaryCount = (Double)this.targetObject.getSObject(this.questionSet.parent_relationship).get(this.primaryCountField);
        	}
        	Boolean val = Boolean.valueOf(this.targetObject.get(field.identifier));
        	if (val != true) { // set default value to true for first child, or first primary if no child count    		
        		system.debug('@@@@this.countField: '+this.countField);
        		system.debug('@@@@this.childCount: '+this.childCount);
       			this.targetObject.put(field.identifier, false);
        		if (this.countField != null) {
        			if (this.childCount == 1) this.targetObject.put(field.identifier, true);	// childCount includes current record
        		} else if (this.primaryCountField != null) {
        			if (this.primaryCount == 0) this.targetObject.put(field.identifier, true);
         		}
        	}
        }
		
		if (field.warningValue == null && field.warningText != null) {
			this.showWarning = true;
		} else if (field.warningValue != null && field.value == field.warningValue) {
			this.showWarning = true;
		}
		
		// M.Witchalls Mar 2018 Use of default values to indicate optional fieldss
		if (field.defaultValue != null && field.isTextField && !this.readOnlyMode) {
			String fieldValue = (String) this.targetObject.get(field.identifier);
			system.debug('@@@@field.defaultValue: '+field.defaultValue+' @@@@fieldValue: '+fieldValue);
			if (fieldValue == field.defaultValue) {
				this.targetObject.put(field.identifier, null);
			}
		}
    }

   	// M.Witchalls Apr 2018 - for calculated fields
    public void calculateTotals() {

	    Map<String, Double> addToMap = new Map<String, Double>();	    
        for (COF_Field field : this.fields) {		            
             if (field.addToField != null && !this.readOnlyMode) {
             	Double value = (String.isBlank(field.value)) ? 0 : Double.valueOf(field.value);
            	Double total = addToMap.get(field.addToField);
            	if (total == null) total = 0;
            	addToMap.put(field.addToField, total + value);
            }
        }
		system.debug('@@@@addToMap: '+addToMap);

        if (addToMap.size() > 0) {
	        for (COF_Field field: this.fields) {
	        	if (addToMap.containsKey(field.identifier)) {
	        		field.value = String.valueOf(addToMap.get(field.identifier));
	        		if (field.isCurrency) {
	        			field.value = field.value.replace('.0','.00');
	        		} else {
	        			field.value = field.value.replace('.0','');
	        		}
	        	}
	        }
        }
    }


    public void prepareChildren() { 
    	this.childNumberMap = new Map<String, String>();
        List<String> fields = new List<String>{'Id','Name','CreatedDate'}; 
        fields.add(this.currentPage.children.target_field);
        
        // M.Witchalls Apr 2018 - use of child arrays with totals
		if (this.currentPage.children.target_field2 != null) {
        	fields.add(this.currentPage.children.target_field2);
        }
        if (this.currentPage.children.target_field3 != null) {
        	fields.add(this.currentPage.children.target_field3);
        }
        if (this.currentPage.children.target_field4 != null) {
        	fields.add(this.currentPage.children.target_field4);
        }
        if (this.currentPage.children.target_field5 != null) {
        	fields.add(this.currentPage.children.target_field5);
        }
        if (this.currentPage.children.target_field6 != null) {
        	fields.add(this.currentPage.children.target_field6);
        }
        if (this.currentPage.children.primary_field != null) {
        	fields.add(this.currentPage.children.primary_field);
    		this.primaryWidth = '10%';      		
        }
        if (this.currentPage.children.width_class != null) {
        	this.widthClass = this.currentPage.children.width_class;
        }
		if (this.currentPage.children.field_width != null) {
        	this.fieldWidth1 = this.currentPage.children.field_width;
        }
        if (this.currentPage.children.field_width2 != null) {
        	this.fieldWidth2 = this.currentPage.children.field_width2;
        }
        if (this.currentPage.children.field_width3 != null) {
        	this.fieldWidth3 = this.currentPage.children.field_width3;
        }
        if (this.currentPage.children.field_width4 != null) {
        	this.fieldWidth4 = this.currentPage.children.field_width4;
        }
        if (this.currentPage.children.field_width5 != null) {
        	this.fieldWidth5 = this.currentPage.children.field_width5;
        }
        if (this.currentPage.children.field_width6 != null) {
        	this.fieldWidth6 = this.currentPage.children.field_width6;
        }
        
        String whereString = 'WHERE '+this.currentPage.children.parent_relationship+'.Name = \'' + this.targetObject.get('Name') + '\' ';
        if (this.currentPage.children.target_filter != null) {
        	whereString += ' AND '+this.currentPage.children.target_filter;
        }
        
        // M.Witchalls May2018 optional remove
        this.removeReqd = (this.currentPage.children.remove_reqd != 'false'); 
        
        // M.Witchalls May 2018 Generate child object (e.g. LCF Grant Outcome Achievement) from another child object (e.g. LCF Grant Outcome)
        List<String> childParentIdList = new List<String>();
        String childParentIdString;
        if (this.currentPage.children.child_parent_field != null) {
        	String whString = 'WHERE '+this.questionSet.parent_relationship+'.Id = \'' + (this.grant == null ? this.application.Id : this.grant.Id) + '\' ';
	        if (this.currentPage.children.child_parent_primary != null) {
	        	whString += ' ORDER BY '+this.currentPage.children.child_parent_primary+' DESC, CreatedDate ASC';
	        } else {
	        	whString += ' ORDER BY CreatedDate ASC';
	        }        	
         	for (SObject record: Query.objects(this.currentPage.children.child_parent_object, new List<String>{'Id'}, whString)) {
        		childParentIdList.add(record.Id);
        		if (childParentIdString == null) {
        			childParentIdString = ' AND '+ this.currentPage.children.child_parent_field +' IN (\''+record.Id+'\'';
        		} else {
        			childParentIdString += ',\''+record.Id+'\'';
        		}
        	}
        	whereString += childParentIdString + ')';
        	//system.assert(false, whereString);
        }
        if (this.currentPage.children.primary_field != null) {
        	whereString += ' ORDER BY '+this.currentPage.children.primary_field+' DESC, Name ASC';
        } else {
        	whereString += ' ORDER BY Name ASC';
        }
        if (this.currentPage.children.child_parent_field != null) {
        	this.targetObjects = Query.objects(
        		this.currentPage.children.target_object, fields, whereString, true /*createIfNotFound*/,
        		(this.grant == null) ? APPLICATIONFIELD : GRANTFIELD,         		
        		(this.grant == null) ? this.application.Id : this.grant.Id, 
 	        	this.currentPage.children.parent_field, 
	        	(String)this.targetObject.get('Id'),
        		this.currentPage.children.child_parent_field,
        		childParentIdList
        	);
        } else {
        	this.targetObjects = Query.objects(this.currentPage.children.target_object, fields, whereString);
        }
        system.debug('###this.targetObjects: '+this.targetObjects);
        for (Integer n=0; n<this.targetObjects.size(); n++) {
        	SObject child = this.targetObjects[n];
        	this.childNumberMap.put((String)child.get('Name'), String.valueOf(n+1));
        }
        system.debug('@@@@this.childNumberMap: '+this.childNumberMap);
         
      	// M.Witchalls Mar 2018 - count fields  
    	if (this.countField != null) {         		
    		this.childCount = (Double)this.targetObject.get(this.countField);
    	}
    	if (this.primaryCountField != null) {   
    		this.primaryCount = (Double)this.targetObject.get(this.primaryCountField);
    	}
        if (this.currentPage.children.primary_label != null && this.targetObjects.size() == 0) {
        	this.addLabel = this.currentPage.children.primary_label;
        } else if (this.currentPage.children.add_label != null) {
        	this.addLabel = this.currentPage.children.add_label;
        // M.Witchalls Apr 2018 - need to be able to suppress Add 
        //} else {
        //	this.addLabel = ADDANOTHER;
        } 
        this.copyLabel = this.currentPage.children.copy_label;    	
    } 

	/*
	 *	Purpose: Copy child records from a previous form: e.g. EOI Commissioners to Full Application
	 *	History: 
	 *		Apr 2018: Michael Witchalls: Initial Release
	 *
	 */
    public PageReference copyFromPreviousForm() {   	
    	Boolean warningReqd = true;
    	String oldRecordType, oldParentField, oldChildObject, newChildObject;
    	oldChildObject = this.currentPage.children.target_object;
    	newChildObject = this.currentPage.children.target_object;
    	if (this.currentPage.children.record_type == FULLAPPRECORDTYPE) oldRecordType = EOIRECORDTYPE;
    	if (this.currentPage.children.parent_field == FULLAPPPARENT) oldParentField = EOIPARENT;
    	if (this.currentPage.children.record_type == SETUPRECORDTYPE) oldRecordType = FULLAPPRECORDTYPE;
    	if (this.currentPage.children.parent_field == SETUPPARENT) oldParentField = FULLAPPPARENT;
    	if (this.currentPage.children.parent_field == BASELINEPARENT && newChildObject.contains(OUTCOME)) {
    		oldRecordType = SETUPRECORDTYPE; 
    		oldParentField = SETUPPARENT;
    		oldChildObject = OUTCOMEOBJECT;
    	}
    	if (this.currentPage.children.parent_field == BASELINEPARENT && newChildObject.contains(INVESTOR)) {
    		oldParentField = SETUPPARENT;
    		oldChildObject = INVESTOROBJECT;
    		warningReqd = false;
    	}
    	if ((oldChildObject == STAKEHOLDEROBJECT || oldChildObject == OUTCOMEOBJECT) && oldRecordType == null) return null;
    	
        List<String> fields = new List<String>();
        Schema.SObjectType oldChildObjectType = Schema.getGlobalDescribe().get(oldChildObject);
        Schema.SObjectType newChildObjectType = Schema.getGlobalDescribe().get(newChildObject);
        Map<String, Schema.SObjectField> fieldSchemaMapOld = oldChildObjectType.getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> fieldSchemaMapNew = newChildObjectType.getDescribe().fields.getMap();
        for (String fieldName: fieldSchemaMapOld.keySet()) {
        	Schema.DescribeFieldResult dfr = fieldSchemaMapOld.get(fieldName).getDescribe();
        	if (fieldName != 'Id' && fieldName != 'RecordTypeId' && fieldName != 'key__c' && fieldName != oldParentField && dfr.isCreateable()) {
        		if (fieldSchemaMapNew.containsKey(fieldName)) fields.add(fieldName); 
        	}
        }
        String applicationId = this.getApplicationIdentifierParam();
    	if (applicationId == null && this.grant != null) {
    		applicationId = (String)this.grant.get('Application_ID__c');
    	}
        String whereString = 'WHERE application__r.Name = \'' + applicationId + '\'';
        if (oldRecordType != null) whereString += ' AND RecordType.Name = \''+ oldRecordType + '\'';
        if (this.currentPage.children.primary_field != null) {
        	whereString += ' ORDER BY '+this.currentPage.children.primary_field+' DESC, CreatedDate ASC';
        } else {
        	whereString += ' ORDER BY CreatedDate ASC';
        }
        List<SObject> newObjects = new List<SObject>();
        for (SObject oldRecord: Query.objects(oldChildObject, fields, whereString)) {
        	SObject newRecord = newChildObjectType.newSObject();
        	for (String field: fields) {
        		newRecord.put(field, oldRecord.get(field));
        	}
        	newObjects.add(newRecord);
        }
        system.debug('###newObjects: '+newObjects);
        system.debug('@@@@this.currentPage.children.record_type: '+this.currentPage.children.record_type);
        
        // M.Witchalls Apr 2018 Special treatment of commissioners
        if (this.currentPage.children.target_object == STAKEHOLDEROBJECT) {
        	for (SObject record: newObjects) record.put(ORGTYPEFIELD, COMMISSIONERTYPE);
        	
        	// Extraction of applicant and intermediary stakeholders
        	if (this.currentPage.children.record_type == SETUPRECORDTYPE) {
        		Map<Double, List<SIB_Field_Metadata__c>> fullAppFieldMap = SIB_Utilities.getRelatedObjectMetadata(FULLAPPOBJECT);
        		if (fullAppFieldMap.size() > 0) {
	        		List<Double> keyList = new List<Double>(fullAppFieldMap.keySet());
	        		keyList.sort();
	        		
	        		fields = new List<String>();
	        		for (Double key: keyList) {
		        		for (SIB_Field_Metadata__c field: fullAppFieldMap.get(key)) {
		        			fields.add(field.Field_Name__c);
		        		}
	        		}
	        		
	        		SObject fullApp;
	        		List<SObject> fullAppList = Query.objects(FULLAPPOBJECT, fields, 'WHERE application__r.Name = \'' + this.getApplicationIdentifierParam() + '\'');
	        		if (fullAppList.size() > 0) {
	        			fullApp = fullAppList[0];
	        		
		        		for (Double key: keyList) {
							Schema.SObjectType objectType = Schema.getGlobalDescribe().get(this.currentPage.children.target_object);
							SObject newRecord = objectType.newSObject();
		        			 
		        			for (SIB_Field_Metadata__c field: fullAppFieldMap.get(key)) {
		        				String fieldValue = (String) fullApp.get(field.Field_Name__c);
		        				if (field.Related_Object_Field_Name__c == ORGTYPEFIELD && fieldValue == COMMISSIONERTYPE) continue;	// Exclude commissioner applicants since already included
		        				system.debug('@@@@field.Field_Name__c: '+field.Field_Name__c);
		        				system.debug('@@@@field.Related_Object_Field_Name__c: '+field.Related_Object_Field_Name__c);
		        				system.debug('@@@@fieldValue: '+fieldValue);
		        				newRecord.put(field.Related_Object_Field_Name__c, fieldValue);
		        			}
		        			if (newRecord.get(ORGTYPEFIELD) == null) newRecord.put(ORGTYPEFIELD, INTERMEDIARYTYPE);
		    				newObjects.add(newRecord);
		        		}
	        		} else {
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'No Full Application available'));
						errorsFound = true;	        			
	        		}
       			}
        	}
        }      
        
        if (newObjects.size() > 0) {
	        // M.Witchalls Apr 2018 - check for duplicate errors in Query.cls and return createResult wrapper
 	        Query.createResult createResult = Query.createObjects(
	        	newObjects, 
       			(this.grant == null) ? this.application.Id : this.grant.Id, 
 	        	this.currentPage.children.parent_field, 
	        	(String)this.targetObject.get('Id'),
	        	this.currentPage.children.record_type
	        );

	    	List<SObject> createdObjects = new List<SObject>();
	    	for (Integer n=0; n<createResult.results.size(); n++) {
	    		if (createResult.results[0].isSuccess()) createdObjects.add(newObjects[n]);
	    	}
    		prepareChildren();
	    	this.childCount = createdObjects.size();
	    	system.debug('@@@@this.childCount: '+this.childCount);
	    	if (this.childCount > 0) {
		    	this.primaryCount = 1;
		        if (warningReqd) {
		        	this.endWarningText = System.Label.SIB_Copy_Message;
		        	this.showWarning = true;
		        }
	    	}	    	
            if (createResult.isError) {
            	system.debug('@@@@result.message: '+createResult.message);
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.SIB_Copy_Error));
        		errorsFound = true;      		
            	errorPageCount++; 
            }
        } else {    	
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'No records availabe to copy'));
			errorsFound = true;	        			
        }
        
		return null;
    } 

    public void prepareFiles() {
		filesField = this.currentPage.filesField;
		filesKey = this.questionSet.target_object+'.'+this.currentPage.files.target_field;   
		     
        List<String> idList = new List<String>();
        for (ContentDocumentLink l: [
        	SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :this.targetObject.Id
        ]) {
        	idList.add(l.ContentDocumentId);
        }
        system.debug('#####idList: '+idList);
        this.fileVersionList = new List<COF_FileVersion>();
        for (ContentVersion cv: [
        	SELECT 
        		Id, Title, VersionNumber, ContentDocumentId, SIB_Field_Key__c 
        	FROM 
        		ContentVersion 
        	WHERE 
        		SIB_Field_Key__c = :filesKey
        	AND
        		ContentDocumentId IN :idList
        	AND
        		isLatest = true
        ]) {
        	fileVersionList.add(
        		new COF_FileVersion(false, cv)
        	);
        }
        system.debug('#####fileVersionList: '+fileVersionList);
    }

    public Boolean saveTargetObject() {
     	
        Boolean quickExit = false;
        
        // M.Witchalls Jan 2018: Get section status values
	    String statusValue;	    
		if (this.statusField != null) {	    
	        if (this.section != null) { // parent object
	        	statusValue = (String)this.targetObject.get(this.statusField);
	        } else { // child object
	        	statusValue = (String)this.targetObject.getSObject(this.questionSet.parent_relationship).get(this.statusField);
	        }
		}
        // M.Witchalls Jan 2018: Section status logic: if any change of value, mark as INCOMPLETE
        Boolean isComplete = true;
        
        system.debug('####targetObject: '+this.targetObject);
        system.debug('####targetField: '+this.questionSet.target_field);
        
   		// M.Witchalls Apr 2018 - for calculated fields
        calculateTotals();
        
        // Manually handle our custom date fields and multiselect checkbox fields
        for (COF_Field field : this.fields) {
        	if (field.value == null) field.value = String.valueOf(this.targetObject.get(field.identifier));
	        	
    		// M.Witchalls Feb 2018: remove child object if target_field is not null and value is null
        	if (this.questionSet.target_field != null 
        		&& field.identifier == this.questionSet.target_field 
        		&& String.isBlank(field.value)) 
        	{
        		system.debug('####target_field.value: '+field.value);
		        Database.DeleteResult result = Database.delete(this.targetObject);
		        quickExit = true;
		        break;
        	}
        	
 			if(field.isCurrency == true) {
        		system.debug('####identifier: '+field.identifier);
             	try {
					system.debug('####Currency Value: '+field.value);
					Double value = (String.isBlank(field.value)) ? null : Double.valueOf(field.value);
					if (value < 0) {
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.SIB_Currency_Error));
						errorsFound = true;
					}
					this.targetObject.put(field.identifier, value);
             	} catch(Exception ex) {
            		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.SIB_Currency_Error));
            		errorsFound = true;
            	}
			}
			
			if(field.isNumber == true) {
            	try {
					Double value = (String.isBlank(field.value)) ? null : Double.valueOf(field.value);
					this.targetObject.put(field.identifier, value);
					if (value < 0) {
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.SIB_Currency_Error));
						errorsFound = true;
					}
             	} catch(Exception ex) {
            		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.SIB_Number_Error));
            		errorsFound = true;
            	}
			}
			
			if(field.isPercent == true) {
            	try {
					Double value = (String.isBlank(field.value)) ? null : Double.valueOf(field.value);
					if (value > 100 || value < 0) {
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.SIB_Percent_Error));
						errorsFound = true;
					}
					this.targetObject.put(field.identifier, value);
             	} catch(Exception ex) {
            		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.SIB_Percent_Error));
            		errorsFound = true;
            	}
			}
        	
            if (field.isRatio == true) {
            	try {
					Double value = (String.isBlank(field.ratioPart)) ? null : Double.valueOf(field.ratioPart);
					if (value < 0) {
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.SIB_Currency_Error));
						errorsFound = true;
					} else {
	                	String ratioValue = '1:'+field.ratioPart;
	                	this.targetObject.put(field.identifier, ratioValue);
					}
             	} catch(Exception ex) {
            		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.SIB_Number_Error));
            		errorsFound = true;
            	}
            }
        	
            if (field.isDateField == true) {
                // Error - Should check all fields
                if (field.dateDay != null && field.dateDay != '') {
                	try {
                    	Date datevalue = date.parse(field.dateDay + '/' + field.dateMonth + '/' + field.dateYear);
                    	this.targetObject.put(field.identifier, datevalue);
                	} catch(Exception ex) {
                		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.SIB_Date_Error));
                		errorsFound = true;
                	}
                } 
            }

			if(field.isEmailField == true) {
				String email = (String)this.targetObject.get(field.identifier);
				if(!String.isBlank(email) && !SIB_Utilities.isValidEmail(email)){
					system.debug('#####Email Error: '+email);
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.SIB_Email_Error));
					errorsFound = true;
				}
			}

            if (field.isSelectField == true) {
                String valueString = null;
                for (COF_Field.CheckBoxOption opt: field.optionList) {
                    if (opt.selected) {
                        if (valueString == null) {
                            valueString = opt.value;
                        } else {
                            valueString += ';'+opt.value;
                        }
                    }                   
                }
                this.targetObject.put(field.identifier, valueString);
            }
            
            if (this.targetObject.get(field.identifier) == null && field.isValid && field.identifier != PRIMARYFIELDID) {
            	// M.Witchalls Apr 2018 '1:XXX' default value indicates a 'ratio' field
            	if (field.defaultValue != null && field.defaultValue != '1:XXX' && field.defaultValue != 'TODAY()') {
            		this.targetObject.put(field.identifier, field.defaultValue);
            	} else {
            		isComplete = false;
            	}
            }
            // Has anything changed?
        	if (field.isCheckBox == false && this.targetObject.get(field.identifier) != this.targetObjectOriginal.get(field.identifier)) {
        		isComplete = false;
        	}
        }
        
        // M.Witchalls Mar 2018 Error message if no primary child record
        if (this.currentPage.children != null) {
       		system.debug('@@@@this.countField: '+this.countField);
         	system.debug('@@@@childCount: '+childCount);
        	if (this.countField != null && this.childCount == 0) isComplete = false;
        	
        	system.debug('@@@@this.primaryCountField: '+this.primaryCountField);
        	if (this.primaryCountField != null) {
        		system.debug('@@@@primaryCount: '+primaryCount);
	        	if (this.childCount > 0 && this.primaryCount == 0) {	        		
	        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.SIB_No_Primary_Error));
	        		errorsFound = true;      		
	        	} 
        	}
        }
        
        if (errorsFound) {
        	errorPageCount++;
        } else if (!quickExit) {
        	if (this.statusField != null) {        	
		        // If previously marked as COMPLETE, now INCOMPLETE
			  	if (!isComplete) statusValue = INCOMPLETE; 
		        
		        if (this.section != null) { // parent object  	     	
		            this.targetObject.put(this.statusField, statusValue);
		            if (this.blockStatusField != null) this.targetObject.put(this.blockStatusField, INPROGRESS); // M.Witchalls May 2018 - Grant Management
		        } else if (statusValue == INCOMPLETE){ // child object - update parent status (or grandparent status)
		        	String statusRelationship = (this.questionSet.status_relationship != null) ? this.questionSet.status_relationship : this.questionSet.parent_relationship;
			    	SObject parentRecord = Schema.getGlobalDescribe().get(this.form.target_object).newSObject();
		            String parentId = (String)this.targetObject.getSobject(statusRelationship).get('Id');
					parentRecord.put('Id', parentId);
					parentRecord.put(this.statusField, statusValue);
					Query.updateObject(parentRecord);
		        }
        	}
	        // Attempt to update the target object
	        if (this.targetObject != null) { 
	        	// M.Witchalls Apr 2018 - check for validation errors in Query.cls and return updateResult wrapper
	            Query.updateResult result = Query.updateObject(this.targetObject);
	            if (result.isError) {
	        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, result.message));
	        		errorsFound = true;      		
	            	errorPageCount++;
	            }
	        }
        }
        return quickExit;
    }

    public PageReference saveContinue() {
    	
   		errorsFound = false;
        system.debug('####this.targetObject: '+this.targetObject);
   		
   		Boolean quickExit = false;
        //if (this.targetObject != null && this.saveReqd && !this.readOnlyMode) {
        if (this.targetObject != null && this.saveReqd && !this.readOnlyMode) {
            quickExit = this.saveTargetObject();
        }
        if (errorsFound) return null;       
        String lastCompletionPath = this.getPageParam('zzzcompletion');
        String firstCompletionPath = this.getPageParam('zzcompletion');
        String completionPath = (!String.isBlank(lastCompletionPath)) ? lastCompletionPath : firstCompletionPath;
	    PageReference nextPage = Page.Questions;
	    if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
        
        // M.Witchalls Feb 2018: Provide quick exit when child automatically removed because targetField was left blank
        if (!(quickExit && !String.isBlank(completionPath))) {
	
	        nextPage.getParameters().put('form', this.getFormIdentifierParam());
	        if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
	        if (this.application != null) nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        	if (this.grant != null) nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
	        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
	        nextPage.getParameters().put('title', this.title);
	        if (this.subtitle != null) nextPage.getParameters().put('subtitle', this.subtitle);
	        if (this.subtitle2 != null) nextPage.getParameters().put('subtitle2', this.subtitle2);
	        if (this.periodTitle != null) nextPage.getParameters().put('periodtitle', this.periodTitle);
	        if (this.index != null) nextPage.getParameters().put('index', this.index);
			if (this.errorPageCount > 0) {
				if (this.previousPageErrors != '0') this.errorPageCount += Integer.valueOf(this.previousPageErrors) + 1;
				nextPage.getParameters().put('errorPageCount', String.valueOf(this.errorPageCount));
			}
	        nextPage.getParameters().put('previousPage', this.getPageIdentifierParam());
	        if (this.fromFormId != null) nextPage.getParameters().put('fromForm', this.fromFormId);
	        nextPage.setRedirect(true);
	
	       // If we have a completion path, pass to the next page
	        if (!String.isBlank(completionPath)) {
	            nextPage.getParameters().put('zzcompletion', completionPath);
	        }
	
	        // switch to using the router class 
	
	        // Determine if we have routes
	        if (this.currentPage.routes != null) {
	            // Loop through the routes from this page
	            for (COF_QuestionSet.COF_Route route : this.currentPage.routes) {
	                // Determine if constraints apply
	                if (route.constraints != null) {
	                    for (COF_QuestionSet.COF_Constraint constraint : route.constraints) {
	                    	Object compareValue = this.readOnlyMode ? this.targetObjectOriginal.get(constraint.field) : this.targetObject.get(constraint.field);
	                    	if (this.router.validConstraint(constraint, compareValue)) {
                                if (Integer.valueOf(route.target_page) > 0) {
                                	nextPage.getParameters().put('page', String.valueOf(route.target_page));
                                	return nextPage; 
                                }
	                        }
	                    }
	                } else {
	                    // No constraints - redirect based on this route
	                    if (Integer.valueOf(route.target_page) > 0) {
	                    	nextPage.getParameters().put('page', String.valueOf(route.target_page));
	                    	return nextPage;
	                    }
	                }
	            }
	        }
	        
	        // No valid routes so redirect to summary
	        nextPage = Page.Summary;
	        nextPage.getParameters().put('form', this.getFormIdentifierParam());
	        if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
	        if (this.application != null) nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        	if (this.grant != null) nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
	        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
	        nextPage.getParameters().put('title', this.title);
	        if (this.subtitle != null) nextPage.getParameters().put('subtitle', this.subtitle);
	        if (this.subtitle2 != null) nextPage.getParameters().put('subtitle2', this.subtitle2);
	        if (this.periodTitle != null) nextPage.getParameters().put('periodtitle', this.periodTitle);
	        if (this.index != null) nextPage.getParameters().put('index', this.index);
	        nextPage.getParameters().put('previousPage', this.getPageIdentifierParam());
			if (this.errorPageCount > 0) {
				if (this.previousPageErrors != '0') this.errorPageCount += Integer.valueOf(this.previousPageErrors) + 1;
				nextPage.getParameters().put('errorPageCount', String.valueOf(this.errorPageCount));
			}
        }
        
        // If we have a completion path, navigate to that page
        if (!String.isBlank(completionPath)) {
            //nextPage.getParameters().put('zzcompletion', completionPath);
            nextPage = Page.Questions;
	        nextPage.getParameters().put('form', this.getFormIdentifierParam());
	        if (this.application != null) nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        	if (this.grant != null) nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
	        nextPage.getParameters().put('title', this.title);
	        if (this.periodTitle != null) nextPage.getParameters().put('periodtitle', this.periodTitle);
	        if (completionPath == lastCompletionPath && this.subtitle != null) nextPage.getParameters().put('subtitle', this.subtitle);
	        List<String> urlParts = completionPath.split('&');
            for (String part: urlParts) {
            	if (part.startsWith('section')) {
            		nextPage.getParameters().put('section', part.substringAfter('='));
            	} else if (part.startsWith('page')) {
            		nextPage.getParameters().put('page', part.substringAfter('='));
            	} else if (part.startsWith('id')) {
            		nextPage.getParameters().put('id', part.substringAfter('='));
            	} else if (part.startsWith('index')) {
            		nextPage.getParameters().put('index', part.substringAfter('='));
            	}
            }
            if (this.fromFormId != null) nextPage.getParameters().put('fromForm', this.fromFormId);
            if (!String.isBlank(lastCompletionPath) && !String.isBlank(firstCompletionPath)) nextPage.getParameters().put('zzcompletion', firstCompletionPath);
        }
        nextPage.setRedirect(true);
        system.debug('######nextPage: '+nextPage.getURL());
        return nextPage;
    }

    public PageReference savePageReturn() {
   		
        if (this.targetObject != null && this.saveReqd && !this.readOnlyMode) {
            this.saveTargetObject();
        }
        if (errorsFound) return null;

        PageReference nextPage = new PageReference('/apex/'+this.returnPage);
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
	    if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
	    if (this.application != null) nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        if (this.grant != null) nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
        nextPage.setRedirect(true);
        return nextPage;
        
    }

    public PageReference saveExit() {
    	
   		errorsFound = false;
   		Boolean quickExit = false;
        //if (this.targetObject != null && this.saveReqd && !this.readOnlyMode) {
        if (this.targetObject != null && this.saveReqd && !this.readOnlyMode) {
            quickExit = this.saveTargetObject();
        }
        if (errorsFound) return null;
       
	    PageReference nextPage = (this.grant == null) ? Page.Sections : Page.LCFGrantBlock;
        // M.Witchalls Feb 2018: Provide quick exit when child automatically removed because targetField was left blank
        String lastCompletionPath = this.getPageParam('zzzcompletion');
        String firstCompletionPath = this.getPageParam('zzcompletion');
        String completionPath = !String.isBlank(lastCompletionPath) ? lastCompletionPath : firstCompletionPath;
        
        if (quickExit && !String.isBlank(completionPath)) {   
            nextPage = Page.Questions;
	        nextPage.getParameters().put('form', this.getFormIdentifierParam());
	        if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
	        if (this.application != null) nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        	if (this.grant != null) nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
	        nextPage.getParameters().put('title', this.title);
	        if (this.subtitle != null) nextPage.getParameters().put('subtitle', this.subtitle);
	        if (this.subtitle2 != null) nextPage.getParameters().put('subtitle2', this.subtitle2);
	        if (this.periodTitle != null) nextPage.getParameters().put('periodtitle', this.periodTitle);
	        if (this.index != null) nextPage.getParameters().put('index', this.index);
	        List<String> urlParts = completionPath.split('&');
            for (String part: urlParts) {
            	if (part.startsWith('section')) {
            		nextPage.getParameters().put('section', part.substringAfter('='));
            	} else if (part.startsWith('page')) {
            		nextPage.getParameters().put('page', part.substringAfter('='));
            	} else if (part.startsWith('id')) {
            		nextPage.getParameters().put('id', part.substringAfter('='));
            	}
            }
        } else {
	        nextPage.getParameters().put('form', this.getFormIdentifierParam());
	        if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
	        if (this.application != null) nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        	if (this.grant != null) {
        		nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
        		nextPage.getParameters().put('section', this.getSectionIdentifierParam());
        	}
	        String thisPage = '/apex/questions?app=' + this.getApplicationIdentifierParam();
	        if (this.grant != null) thisPage = '/apex/questions?grant=' + this.getGrantIdentifierParam();
	        thisPage += '&form=' + this.getFormIdentifierParam();
	        thisPage += '&section=' + this.getSectionIdentifierParam();
	        thisPage += '&title='+ this.title;
	        if (this.subtitle != null) thisPage += '&subtitle='+ this.subtitle;
	        if (this.subtitle2 != null) thisPage += '&subtitle2='+ this.subtitle2;
	        if (this.periodTitle != null) thisPage += '&periodtitle='+ this.periodTitle;
	        if (this.index != null) thisPage += '&index'+ this.index;
	        thisPage += '&page=' + this.getPageIdentifierParam();
	        
	        if (this.targetIdentifier != null) thisPage += '&id=' + this.targetIdentifier;
	        
	        if (!String.isBlank(firstCompletionPath)) thisPage += '&zzcompletion=' + EncodingUtil.urlEncode(firstCompletionPath, 'UTF-8');	        
	        if (!String.isBlank(lastCompletionPath)) thisPage += '&zzzcompletion=' + EncodingUtil.urlEncode(lastCompletionPath, 'UTF-8');	        
	        nextPage.getParameters().put('zzzlastPage', thisPage); 
        }
        nextPage.setRedirect(true);
        return nextPage;
    }

    public PageReference addAnother() {

        // Create a new child
        String grandParentFieldName;
        String grandParentId;
        if (this.grandchildRelationship) {
        	grandParentFieldName = this.currentPage.children.grandparent_field;
        	grandParentId = (String)this.targetObject.getSObject(this.questionSet.parent_relationship).get('Id');
        } else if (this.grant == null) {
        	grandParentFieldName = APPLICATIONFIELD;
        	grandParentId = this.application.Id;
        } else {
        	grandParentFieldName = GRANTFIELD;
        	grandParentId = this.grant.Id;
        }
        Database.SaveResult result = Query.createObject( 
        	this.currentPage.children.target_object, 
        	grandParentFieldName,
        	grandParentId, 
        	this.currentPage.children.parent_field, 
        	(String)this.targetObject.get('Id'),
        	this.currentPage.children.record_type
        );
        // Exception will be thrown if insert fails
        
        List<String> fieldIdentifiers = new List<String>();
        fieldIdentifiers.add('Name'); 
        SObject childFetched = Query.object(this.currentPage.children.target_object, fieldIdentifiers, 'WHERE Id = \'' + result.getId() + '\'');
        String childID = (String)childFetched.get('Name');
        Integer n = this.targetObjects.size() + 1;
        this.childNumberMap.put(childID, String.valueOf(n));
        return childPageRedirect(childID, '1');

    }
    
    public PageReference changeChild() {
    	return childPageRedirect(this.modifyChildIdentifier, '1');
    }
    
    public PageReference grandChildrenPage() {
    	return childPageRedirect(this.modifyChildIdentifier, this.currentPage.children.grandchildren_page);
    }

    public PageReference childPageRedirect(String idString, String pageNo) {

        String currentCompletionPath = this.getPageParam('zzcompletion');
        
        PageReference nextPage = Page.questions;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        if (this.application != null) nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        if (this.grant != null) nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
        nextPage.getParameters().put('section', this.currentPage.children.section);
	    nextPage.getParameters().put('title', this.title);
	    if (this.periodTitle != null) nextPage.getParameters().put('periodtitle', this.periodTitle);
	    if (String.isBlank(currentCompletionPath)) {
	    	if (this.currentPage.children.title != null) nextPage.getParameters().put('subtitle', this.currentPage.children.title);
	    } else if (this.subtitle != null) {
    		nextPage.getParameters().put('subtitle', this.subtitle);
    		if (this.currentPage.children.title != null) nextPage.getParameters().put('subtitle2', this.currentPage.children.title);
	    }
        nextPage.getParameters().put('id', idString);
        nextPage.getParameters().put('index', childNumberMap.get(idString));
        nextPage.getParameters().put('page', pageNo);
        if (this.fromFormId != null) {
        	nextPage.getParameters().put('fromForm', this.fromFormId); 
        }
        String newCompletionPath = '/apex/questions?app=' + this.getApplicationIdentifierParam();
        if (this.grant != null) newCompletionPath = '/apex/questions?grant=' + this.getGrantIdentifierParam();
        if (this.targetIdentifier != null) newCompletionPath += '&id=' + this.targetIdentifier;
        newCompletionPath += '&form=' + this.getFormIdentifierParam();
        newCompletionPath += '&section=' + this.getSectionIdentifierParam();
	    newCompletionPath += '&title=' + this.title;
	    if (this.subtitle != null) newCompletionPath += '&subtitle=' + this.subtitle;
	    if (this.periodTitle != null) newCompletionPath += '&periodtitle='+ this.periodTitle;
	    if (this.index != null) newCompletionPath += '&index=' + this.index;
        newCompletionPath += '&page=' + this.getPageIdentifierParam();
        if (currentCompletionPath == null) {
        	nextPage.getParameters().put('zzcompletion', newCompletionPath); 
        } else {
        	nextPage.getParameters().put('zzcompletion', currentCompletionPath); 
        	nextPage.getParameters().put('zzzcompletion', newCompletionPath);         	
        }
        nextPage.setRedirect(true);
        return nextPage;

    }

    public PageReference removeChild() {

        // Construct a new child
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(this.currentPage.children.target_object);
        SObject newChild = targetType.newSObject();
        
        // Set the record id and delete
        newChild.put('id', this.removeChildId);
        system.debug('@@@@this.removeChildId: '+this.removeChildId);
        Database.DeleteResult result = Database.delete(newChild);
        
        // M.Witchalls Mar 2018
    	if (this.primaryCountField != null) this.primaryCount--;
    	if (this.countField != null) this.childCount--;
    
        return returnFromRemove();       
    }

    public PageReference returnFromRemove() {
     
        // M.Witchalls Jan 2018: Had to resort to full page refresh because rerender is not working for some unknown reason
        PageReference nextPage = Page.questions;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
	    if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
		if (this.application != null) nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        if (this.grant != null) nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
        if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
	    nextPage.getParameters().put('title', this.title);
	    if (this.subtitle != null) nextPage.getParameters().put('subtitle', this.subtitle);
	    if (this.periodTitle != null) nextPage.getParameters().put('periodtitle', this.periodTitle);
	    if (this.index != null) nextPage.getParameters().put('index', this.index);
        nextPage.getParameters().put('page', this.getPageIdentifierParam());
        String firstCompletionPath = this.getPageParam('zzcompletion');
        if (!String.isBlank(firstCompletionPath)) nextPage.getParameters().put('zzcompletion', firstCompletionPath);
        String lastCompletionPath = this.getPageParam('zzzcompletion');
        if (!String.isBlank(lastCompletionPath)) nextPage.getParameters().put('zzzcompletion', lastCompletionPath);
        nextPage.setRedirect(true);
        return nextPage;       
    }

	
	/*
	 *	Purpose: Allow upload of ContentDocument file versions
	 *	History: 
	 *		Mar 2018: Michael Witchalls: Initial Release
	 *				  See COF_ContentVersionTriggerHandler for file linkage and sharing
	 */
    public PageReference uploadFileVersion() {      
    	system.debug('####fileName,fileBody: '+fileName+':'+fileBody); 
        ContentVersion cv = new ContentVersion();
        cv.SIB_Form_ID__c = this.targetObject.Id;
    	for (COF_FileVersion f: fileVersionList) {
    		if (f.selectFlag) {
				cv.ContentDocumentId = f.fileVersion.ContentDocumentId;	// new version of existing document
        		cv.SIB_Form_ID__c = null;		// already linked to form, so trigger does not need to link
    			break;
    		} else {
    			cv.ContentDocumentId = null;	// new document
    		}
    	} 
    	system.debug('####contentDocId: '+cv.ContentDocumentId);
        cv.versionData = this.fileBody;
        cv.title = this.fileName;
        cv.pathOnClient ='/'+this.fileName;
        cv.SIB_Field_Key__c = this.filesKey;
        try{
        	insert cv;
        } catch(Exception e) { 
			throw new COF_Exception('Could not load file: '+fileName+' to page '+
				this.getFormIdentifierParam()+':'+this.getSectionIdentifierParam()+':'+this.getPageIdentifierParam()+
				' - field key: '+filesKey);   				 	
        }
        if (cv.SIB_Form_ID__c != null) {		// new document
	        this.targetObject.put(this.currentPage.files.target_field, fileVersionList.size()+1);
	        this.saveTargetObject();
        }
             
        // M.Witchalls Mar 2018: Full page refresh required after file upload since rerender not permitted
        PageReference nextPage = Page.questions;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        if (this.application != null) nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
	    if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
        if (this.grant != null) nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
	    nextPage.getParameters().put('title', this.title);
	    if (this.subtitle != null) nextPage.getParameters().put('subtitle', this.subtitle);
	    if (this.subtitle2 != null) nextPage.getParameters().put('subtitle2', this.subtitle);
	    if (this.periodTitle != null) nextPage.getParameters().put('periodtitle', this.periodTitle);
	    if (this.index != null) nextPage.getParameters().put('index', this.index);
        nextPage.getParameters().put('page', this.getPageIdentifierParam());
        String completionPath = this.getPageParam('zzcompletion');
        if (!String.isBlank(completionPath)) nextPage.getParameters().put('zzcompletion', completionPath);
        nextPage.setRedirect(true);
        return nextPage;
    }

    public PageReference removeFile() {
        ContentDocument newDoc = new ContentDocument(Id = this.contentDocId);
        Database.DeleteResult result = Database.delete(newDoc);
        this.targetObject.put(this.currentPage.files.target_field, fileVersionList.size()-1);
        this.saveTargetObject();
        return returnFromRemove();
    }
	    
    public PageReference showMessage() {
        uploadSuccess = ApexPages.currentPage().getParameters().get('uploadSuccess');
        String attachName = ApexPages.currentPage().getParameters().get('attachName');
        List<String> fileSplit= attachName.split(';\\s*');
        attachedFiles = new List<String>();
        attachedFiles.addAll(fileSplit);
        System.debug('uploadSuccess:'+uploadSuccess);
        return null;
    }
   
	public PageReference copyFieldFromObject() {
        COF_Field thisField = this.fieldMap.get(this.targetFieldIdentifier); 
        system.debug('this.targetFieldIdentifier: '+this.targetFieldIdentifier);
        String copyId = thisField.copyFromField;
        if (copyId != null && this.copyObject != null) {
	        Object fieldValue = this.copyObject.get(copyId);
	        this.targetObject.put(this.targetFieldIdentifier, fieldValue);
		    this.prepareField(thisField);
        }
        return null;
	}
	
    public PageReference showHideStuff() {
    	String fieldId = ApexPages.currentPage().getParameters().get('fieldId');
        String fieldValue = String.valueOf(this.targetObject.get(fieldId));
        COF_Field thisField = this.fieldMap.get(fieldId); 
        if (thisField.isSelectField == true) {
            String valueString = null;
            for (COF_Field.CheckBoxOption opt: thisField.optionList) {
                if (opt.selected) {
                    if (valueString == null) {
                        valueString = opt.value;
                    } else {
                        valueString += ';'+opt.value;
                    }
                }                   
            }
            fieldValue = valueString;
        }
        system.debug('@@@@@fieldValue: '+fieldValue);
    	
    	this.showWarning = (fieldValue == thisField.warningValue) ? true : false;
		
		// M.Witchalls Apr 2018 constraint attribute
        for (COF_Field field : this.fields) {
        	//field.isValid = true;
        	if (field.constraints != null) {
                for (COF_QuestionSet.COF_Constraint constraint : field.constraints) {
                	if (constraint.field == fieldId) {
	                	field.isValid = this.router.validConstraint(constraint, fieldValue);
                	}
                }
                system.debug('@@@@field with constraint, constraint changed: '+field);
        	}
        }
    	return null;
    }
    
	// M.Witchalls Apr 2018 - for calculated fields
    public PageReference doCalculation() {
    	String oldValue = ApexPages.currentPage().getParameters().get('oldValue');
    	String newValue = ApexPages.currentPage().getParameters().get('newValue');
        String addToField = ApexPages.currentPage().getParameters().get('addToField');
     	//try {
			Double oldVal = (String.isBlank(oldValue)) ? 0 : Double.valueOf(oldValue);
			Double newVal = (String.isBlank(newValue)) ? 0 : Double.valueOf(newValue);
        	system.debug('@@@@oldValue: '+oldVal);
        	system.debug('@@@@newValue: '+newVal);
	        for (COF_Field field : this.fields) {
	        	if (field.identifier == addToField) {
	        		Double total = (String.isBlank(field.value)) ? 0 : Double.valueOf(field.value);
        			system.debug('@@@@total: '+total);
	        		field.value = String.valueOf(total + newVal - oldVal).replace('.0','.00');
	        		system.debug('@@@@field.value: '+field.value);
	        	}
	        }
     	//} catch(Exception ex) {
    	//}
    	return null;
    }
    
    public PageReference calculateFieldTotals() {
    	calculateTotals();
    	return null;
    }
    
    public PageReference hideSaveButtons() {
    	this.saveReqd = false;
    	return null;
    }
    
    public PageReference showSaveButtons() {
    	this.saveReqd = true;
    	return null;
    }
}