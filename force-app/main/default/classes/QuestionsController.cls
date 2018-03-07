/* __________________________________________________________________________________________________________________
   Name:		QuestionsController.cls
   Description: Controller class for Questions Visualforce page
					
   Date         Version Author          		Summary of Changes 
   ___________  _______ __________________		_____________________________________________________________________
   2017		    1.0    	Cabinet Office			Initial Release 
   Jan 2018		1.1		M.Witchalls, Westbrook	Page navigation changes (see page javascript); section status updates
   Feb 2018		1.2		M.Witchalls, Westbrook	Readonly view and reference lookup from Setup form to Full Application
   												Introduction of rich text guidance and 
   Mar 2018		1.3		M.Witchalls, Westbrook	Correction to child question check
__________________________________________________________________________________________________________________ */        
public class QuestionsController extends COF_PageController {
	private static final String COMPLETE = 'COMPLETE';
	private static final String INCOMPLETE = 'INCOMPLETE';
	private static final String ADDANOTHER = '+ Add another';
 
    // M.Witchalls Feb 2018 
    public Boolean readOnlyMode {get;set;}
    public String fromFormId {get;set;}
	public SIB_Information__c sibInfo {get;set;}
	
    public COF_Form form {get;set;}
    public COF_Section section {get;set;} 
    public COF_QuestionSet questionSet {get; set;}
    public COF_Page currentPage {get; set;}
    public List<COF_Field> fields {get; set;}
    public List<String> fieldValueList {get; set;} 

    public SObject application {get;set;} 
    public SObject targetObject {get;set;} 
    public List<SObject> targetObjects {get; set;}

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
    public String endWarningText {get;set;}
    public Boolean showWarning {get;set;}
    public Boolean saveReqd {get;set;}
    public Boolean childPage {get;set;}
	
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
	      
    private String statusField;
    private SObject targetObjectOriginal;
    
    public QuestionsController() {
    	this.errorsFound = false;
    	this.errorPageCount = 0;
    	this.endWarningText = '';
    	this.saveReqd = false;
    	this.childPage = false;
    	
    	// M.Witchalls Feb 2018: for readonly view (if form not in 'Draft' status)
    	this.readOnlyMode = this.getReadOnlyMode();
    	system.debug('#####this.readOnlyMode: '+this.readOnlyMode);
    	
    	// M.Witchalls Jan 2018: these parameters required for page navigation javascript
    	this.previousPageErrors = this.getPageParam('errorPageCount');
    	if (this.previousPageErrors == null) this.previousPageErrors = '0';  	
    	this.previousPageId = null;   	
    	this.pageId = this.getPageIdentifierParam();
    	this.previousPageId = this.getPreviousPageIdentifierParam();
    	if (previousPageId == null) previousPageId = '0';
    	system.debug('###previousPageId: '+this.previousPageId);
    	
    	this.fromFormId = this.getFromFormIdentifierParam();
        if (this.getFormIdentifierParam()!= null) {    	
        	COF_Config config = COF_Config.load(this.getFormIdentifierParam());
        	this.form = config.getForm(this.getFormIdentifierParam());
        	this.section = this.form.getSection(this.getSectionIdentifierParam());
	        
	        // M.Witchalls Jan 2018: Get section and page status values
	        if (this.section != null) { // parent object
	            this.questionSet = this.section.getQuestionSet();
	            this.statusField = this.section.status_field;
	            this.shortTitle = this.section.short_title;
	        } else { // child object 
	            this.questionSet = COF_QuestionSet.load(this.getSectionIdentifierParam());
	            this.statusField = this.questionSet.status_field;
	            this.shortTitle = this.questionSet.short_title;
	            this.childPage = true;
	        }
	
	        this.application = this.getApplication(); 
	        this.currentPage = this.questionSet.getPage(this.getPageIdentifierParam());
	        
	        // M.Witchalls Feb 2018: Guidance may be rich text so guidance is not derived from guidance_id (like title and warning are): 
	        //                       guidance_id rich text is displayed directly from the SIB_Section_Text__c object
	        if (this.currentPage.guidance_id != null) this.guidanceText = 
	        	SIB_Utilities.getSectionText(this.questionSet.target_object + ':' + this.currentPage.guidance_id);
	        
	        this.fields = new List<COF_Field>(); 
	        
	        List<COF_Field> fields = new List<COF_Field>();
	        Set<String> fieldIdentifierSet = new Set<String>{'Id','Name'};
	        fieldIdentifierSet.add(this.questionSet.parent_relationship+'.Id');
	        if (this.questionSet.child_count_field != null) fieldIdentifierSet.add(this.questionSet.child_count_field);
	        if (this.statusField != null) {
		        if (!this.childPage) { // parent object
		            fieldIdentifierSet.add(this.statusField);
		 		} else { // child object - get parent status
		            fieldIdentifierSet.add(this.questionSet.parent_relationship+'.'+this.statusField);
		        }
	        }
	        
	        // M.Witchalls Feb 2018: reference lookup from Setup form to Full Application form
	        if (this.form.reference_id != null && this.currentPage.reference_section != null && this.currentPage.reference_id != null) { 
	        	this.referenceURL = referencePageURL(this.form.reference_id, this.currentPage.reference_section, this.currentPage.reference_id);
	        	this.referenceGuidance = this.currentPage.reference_guidance;
	        	system.debug('####this.referenceURL: '+this.referenceURL);
	        }
	        
	        if (this.currentPage.questions != null) {
	        	this.saveReqd = true;
		        for (COF_QuestionSet.COF_Question question : this.currentPage.questions) {
		            fieldIdentifierSet.add(question.target_field);
		            COF_Field newField = new COF_Field(question.target_field, this.questionSet.target_object);
		            if (newField.guidance == null && question.guidance != null) newField.guidance = question.guidance;
		            if (newField.recommendedWordLimit == null && question.recommended_word_limit != null) {
		                newField.recommendedWordLimit = question.recommended_word_limit;
		            }
		            fields.add(newField);
		        }
		        this.fields = fields;
	        }
	        // M.Witchalls Feb 2018 - for readonly access
	        for (COF_Field f: this.fields) {
	        	for (SelectOption opt: f.values) {
	        		if (this.readOnlyMode) opt.setDisabled(true);
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
	        	this.saveReqd = true;
            	fieldIdentifierSet.add(this.currentPage.files.target_field);
	        }
	
	        System.debug('###this.questionSet.target_object: '+this.questionSet.target_object);
	        String targetIdentifier = this.getRecordIdentifierParam();
	        system.debug('###targetIdentifier: '+targetIdentifier);
	        if (targetIdentifier == null) {
	            this.targetObject = Query.object(this.questionSet.target_object, fieldIdentifierSet, 'WHERE ' +  this.questionSet.parent_relationship + '.Name = \'' + this.getApplicationIdentifierParam() + '\'');
	        } else {
	            this.targetObject = Query.object(this.questionSet.target_object, fieldIdentifierSet, 'WHERE ' +  'Name = \'' + targetIdentifier + '\'');            
	        }
	        this.targetObjectOriginal = this.targetObject.clone(true, true, false, false);	// M.Witchalls Jan 2018: deep clone copy
	
	        if (this.currentPage.questions != null) {
	            this.prepareQuestions();
	        }
	
	        if (this.currentPage.children != null) {
	            this.prepareChildren();
	        }
	
	        if (this.currentPage.files != null) {
	            this.prepareFiles();
	        }
        }
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
       		if (field.warningText != null) this.endWarningText += field.warningText + '\n';
       		
        	field.value = String.valueOf(this.targetObject.get(field.identifier));
            if (field.isDateField == true) {
                Date currentDate = (Date) this.targetObject.get(field.identifier);
                if (currentDate != null) {
                    field.dateDay = String.valueOf(currentDate.day());
                    field.dateMonth = String.valueOf(currentDate.month());
                    field.dateYear = String.valueOf(currentDate.year());
                }
            }
            if (field.isSelectField == true) {
                String fieldValue = (String) this.targetObject.get(field.identifier);
                if (fieldValue != null) {
                    Set<String> valueSet = new Set<String>();
                    valueSet.addAll(fieldValue.split(';\\s*'));
                    for (COF_Field.CheckBoxOption opt: field.optionList) {
                        if (valueSet.contains(opt.value)) opt.selected = true;
                    }
                }
            }
			
			if (field.warningValue == null && field.warningText != null) {
				this.showWarning = true;
			} else if (field.warningValue != null && field.value == field.warningValue) {
				this.showWarning = true;
			}
        }

    }

    public void prepareChildren() { 
        List<String> fields = new List<String>();
        fields.add(this.currentPage.children.target_field);
        if (this.currentPage.children.target_field2 != null) fields.add(this.currentPage.children.target_field2);
        fields.add('CreatedDate');
        fields.add('Name');
        String appIdentifier = this.getApplicationIdentifierParam(); 
        system.debug('###this.targetObject: '+this.targetObject);
        this.targetObjects = Query.objects(this.currentPage.children.target_object, fields, 
        	'WHERE '+this.currentPage.children.parent_relationship+'.Name = \'' + this.targetObject.get('Name') + '\'ORDER BY CreatedDate ASC');
        if (this.currentPage.children.primary_label != null && this.targetObjects.size() == 0) {
        	this.addLabel = this.currentPage.children.primary_label;
        } else if (this.currentPage.children.add_label != null) {
        	this.addLabel = this.currentPage.children.add_label;
        } else {
        	this.addLabel = ADDANOTHER;
        }
    } 

    public void prepareFiles() {
		filesField = new COF_Field(this.currentPage.files.target_field, this.questionSet.target_object);
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
        
        // M.Witchalls Jan 2018: Get section and page status values
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
        
        // Manually handle our custom date fields and multiselect checkbox fields
        for (COF_Field field : this.fields) {
        	if (field.value == null) field.value = (String)this.targetObject.get(field.identifier);
	        	
    		// M.Witchalls Feb 2018: remove child object if targetField is null
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
            if (this.targetObject.get(field.identifier) == null) isComplete = false;
        	if (this.targetObject.get(field.identifier) != this.targetObjectOriginal.get(field.identifier)) {
        		isComplete = false;
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
		        } else if (statusValue == INCOMPLETE){ // child object - update parent status
			    	SObject parentRecord = Schema.getGlobalDescribe().get(this.form.target_object).newSObject();
		            String parentId = (String)this.targetObject.getSobject(this.questionSet.parent_relationship).get('Id');
					parentRecord.put('Id', parentId);
					parentRecord.put(this.statusField, statusValue);
					Query.updateObject(parentRecord);
		        }
        	}
	        // Attempt to update the target object
	        if (this.targetObject != null) { 
	            Query.updateObject(this.targetObject);
	        }
        }
        return quickExit;
    }

    public PageReference saveContinue() {
    	
   		errorsFound = false;
        system.debug('####this.targetObject: '+this.targetObject);
   		
   		Boolean quickExit = false;
        if (this.targetObject != null && this.saveReqd && !this.readOnlyMode) {
            quickExit = this.saveTargetObject();
        }
        if (errorsFound) return null;
        String completionPath = ApexPages.currentPage().getParameters().get('zzcompletion');
	    PageReference nextPage = Page.Questions;
        
        // M.Witchalls Feb 2018: Provide quick exit when child automatically removed because targetField was left blank
        if (!(completionPath != null && quickExit)) {
	
	        nextPage.getParameters().put('form', this.getFormIdentifierParam());
	        nextPage.getParameters().put('id', this.getRecordIdentifierParam());
	        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
	        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
			if (this.errorPageCount > 0) {
				if (this.previousPageErrors != '0') this.errorPageCount += Integer.valueOf(this.previousPageErrors) + 1;
				nextPage.getParameters().put('errorPageCount', String.valueOf(this.errorPageCount));
			}
	        nextPage.getParameters().put('previousPage', this.getPageIdentifierParam());
	        if (this.fromFormId != null) nextPage.getParameters().put('fromForm', this.fromFormId);
	        nextPage.setRedirect(true);
	
	       // If we have a completion path, pass to the next page
	        if (completionPath != null) {
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
	                        if (constraint.operator == 'equals') {
	                            if (this.targetObject.get(constraint.field) == constraint.value) {
	                                // Valid constraint - redirect based on this route
	                                if (Integer.valueOf(route.target_page) > 0) {
	                                	nextPage.getParameters().put('page', String.valueOf(route.target_page));
	                                	return nextPage;
	                                }
	                            }
	                        }
	                        if (constraint.operator == 'greater') {
	                            if (Double.valueOf(this.targetObject.get(constraint.field)) > Double.valueOf(constraint.value)) {
	                                // Valid constraint - redirect based on this route
	                                if (Integer.valueOf(route.target_page) > 0) {
	                                	nextPage.getParameters().put('page', String.valueOf(route.target_page));
	                                	return nextPage;
	                                }
	                            }
	                        }
	                        if (constraint.operator == 'contains') {
	                            String targetObjectField = (string)this.targetObject.get(constraint.field);
	                            if (targetObjectField.contains(constraint.value) == true) {
	                                // Valid constraint - redirect based on this route
	                                if (Integer.valueOf(route.target_page) > 0) {
	                                	nextPage.getParameters().put('page', String.valueOf(route.target_page));
	                                	return nextPage;
	                                }
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
	        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
	        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
	        nextPage.getParameters().put('previousPage', this.getPageIdentifierParam());
			if (this.errorPageCount > 0) {
				if (this.previousPageErrors != '0') this.errorPageCount += Integer.valueOf(this.previousPageErrors) + 1;
				nextPage.getParameters().put('errorPageCount', String.valueOf(this.errorPageCount));
			}
        }
        
        // If we have a completion path, navigate to that page
        if (completionPath != null) {
            //nextPage.getParameters().put('zzcompletion', completionPath);
            nextPage = Page.Questions;
	        nextPage.getParameters().put('form', this.getFormIdentifierParam());
	        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
	        List<String> urlParts = completionPath.split('&');
            for (String part: urlParts) {
            	if (part.startsWith('section')) {
            		nextPage.getParameters().put('section', part.substringAfter('='));
            	} else if (part.startsWith('page')) {
            		nextPage.getParameters().put('page', part.substringAfter('='));
            	}
            }
            if (this.fromFormId != null) nextPage.getParameters().put('fromForm', this.fromFormId);
        }
        nextPage.setRedirect(true);
        system.debug('######nextPage: '+nextPage.getURL());
        return nextPage;
    }

    public PageReference saveExit() {
    	
   		errorsFound = false;
        if (this.targetObject != null) {
            this.saveTargetObject();
        }
        if (errorsFound) return null;

        PageReference nextPage = Page.Sections;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        String thisPage = '/apex/questions?app=' + this.getApplicationIdentifierParam();
        thisPage += '&form=' + this.getFormIdentifierParam();
        thisPage += '&section=' + this.getSectionIdentifierParam();
        thisPage += '&page=' + this.getPageIdentifierParam();
        nextPage.getParameters().put('zzzlastPage', thisPage); 
        nextPage.setRedirect(true);
        return nextPage;
    }

    public PageReference addAnother() {

        // Create a new child
        Database.SaveResult result = Query.createObject(this.currentPage.children.target_object, this.application.Id, this.currentPage.children.parent_field, (String)this.targetObject.get('Id'));
        // Exception will be thrown if insert fails
        
        List<String> fieldIdentifiers = new List<String>();
        fieldIdentifiers.add('Name'); 
        SObject childFetched = Query.object(this.currentPage.children.target_object, fieldIdentifiers, 'WHERE Id = \'' + result.getId() + '\'');

        PageReference nextPage = Page.questions;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.getParameters().put('section', this.currentPage.children.section);
        nextPage.getParameters().put('id', (String)childFetched.get('Name'));
        nextPage.getParameters().put('page', '1');
        String completion = '/apex/questions?app=' + this.getApplicationIdentifierParam();
        completion += '&form=' + this.getFormIdentifierParam();
        completion += '&section=' + this.getSectionIdentifierParam();
        completion += '&page=' + this.getPageIdentifierParam();
        nextPage.getParameters().put('zzcompletion', completion); 
        nextPage.setRedirect(true);
        return nextPage;

    }

    public PageReference changeChild() {

        PageReference nextPage = Page.questions;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.getParameters().put('section', this.currentPage.children.section);
        nextPage.getParameters().put('id', this.modifyChildIdentifier);
        nextPage.getParameters().put('page', '1');
        if (this.fromFormId != null) {
        	nextPage.getParameters().put('fromForm', this.fromFormId);
        }
        String completion = '/apex/questions?app=' + this.getApplicationIdentifierParam();
        completion += '&form=' + this.getFormIdentifierParam();
        completion += '&section=' + this.getSectionIdentifierParam();
        completion += '&page=' + this.getPageIdentifierParam();
        nextPage.getParameters().put('zzcompletion', completion); 
        nextPage.setRedirect(true);
        return nextPage;

    }

    public PageReference removeChild() {

        // Construct a new child
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(this.currentPage.children.target_object);
        SObject newChild = targetType.newSObject();
        
        // Set the record id and delete
        newChild.put('id', this.removeChildId);
        Database.DeleteResult result = Database.delete(newChild);
        
        // M.Witchalls Jan 2018: Had to resort to full page refresh because rerender is not working for some unknown reason
        PageReference nextPage = Page.questions;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
        nextPage.getParameters().put('page', this.getPageIdentifierParam());
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
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
        nextPage.getParameters().put('page', this.getPageIdentifierParam());
        nextPage.setRedirect(true);
        return nextPage;
    }

    public PageReference removeFile() {
        ContentDocument newDoc = new ContentDocument(Id = this.contentDocId);
        Database.DeleteResult result = Database.delete(newDoc);
        this.targetObject.put(this.currentPage.files.target_field, fileVersionList.size()-1);
        this.saveTargetObject();
        
        // M.Witchalls Jan 2018: Had to resort to full page refresh because rerender is not working for some unknown reason
        PageReference nextPage = Page.questions;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
        nextPage.getParameters().put('page', this.getPageIdentifierParam());
        nextPage.setRedirect(true);
        return nextPage;
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
    
    public PageReference showHideWarning() {
    	String fieldId = ApexPages.currentPage().getParameters().get('fieldId');
        String fieldValue = String.valueOf(this.targetObject.get(fieldId));
        COF_Field field = new COF_Field(fieldId, this.questionSet.target_object);  
    	
    	//system.assert(false, fieldValue+':'+field.warningValue);
    	this.showWarning = (fieldValue == field.warningValue) ? true : false;
    	return null;
    }
   
}