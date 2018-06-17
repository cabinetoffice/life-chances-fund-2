/* __________________________________________________________________________________________________________________
   Name:		LCFGrantBlockController.cls
   Description: Controller class for LCFGrantBlock Visualforce page
					
   Date         Version Author          		Summary of Changes 
   ___________  _______ ______________________	_____________________________________________________________________
   Apr 2018	    1.0    	M.Witchalls, Westbrook	Initial Release 
   Jun 2018		1.1		M.Witchalls, Westbrook	Provision for optional sections
 __________________________________________________________________________________________________________________ */        
public class LCFGrantBlockController extends COF_PageController {
	private static final String COMPLETE = 'COMPLETE';
	private static final String HISTORY = 'HISTORY';
	private static final String CONFIRM = 'Confirm';
	private static final String STARTSECTION = 'Start section';
	private static final String SUBMITTED = 'Submitted';
	private static final String ISSUED = 'Issued';
	private static final String CONFIGIDENTIFIER = 'lcf_grant_1';
    private static final String STATUSFIELD = 'Status__c';
    private static final String PROJECTLAUNCHED = 'Project Launched';
    private static final String SUBMITFORM = 'Submit ';
    private static final String ISSUEFORM = 'Issue ';
    private static final Boolean CREATEIFNOTFOUND = true;
    private static final String NOCREATEERROR = 'This form has not yet been started.';

	public SIB_Information__c sibInfo {get;set;}
	public COF_Form form {get;set;}
    public COF_Section section {get;set;} 
    public SObject application {get;set;} 
    public SObject targetObject {get;set;} 
    public String formStatus {get;set;}
    public String approvalStatus {get;set;}
    public String issueStatus {get;set;}
    public String buttonLabel {get;set;}

    public SObject grant {get;set;} 
	public SIB_Section_Text__c sectionText {get;set;}
	public Boolean partnerUser {get;set;}
	public Boolean readOnlyMode {get;set;}	
	public List<COF_Field> fields {get; set;}
	public Boolean errorsFound {get; set;}
	public Boolean noCreate {get; set;}
	public String questionsTitle {get; set;}
	public String periodTitle {get; set;}
	public String submitLabel {get; set;}
	public String draftStatus {get; set;}
    public String endWarningText {get;set;}
    public Boolean showWarning {get;set;}
	
	private List<String> fieldIdentifiers;
	private Map<String, COF_Field> fieldMap;	
    private String targetIdentifier;

    public LCFGrantBlockController() {
        COF_Config config = COF_Config.load(CONFIGIDENTIFIER);
        this.form = config.getForm(this.getFormIdentifierParam());
        this.section = this.form.getSection(this.getSectionIdentifierParam());
        this.targetIdentifier = this.getRecordIdentifierParam();
        this.application = this.getApplication();
        this.grant = this.getGrant();
        this.formStatus = this.getformStatus(this.grant, this.form);
    	this.errorsFound = false;
    	this.noCreate = false;
    	this.submitLabel = (this.form.approval_status_field != null ? SUBMITFORM : ISSUEFORM) + this.form.title.toLowerCase();
    	this.endWarningText = '';

        SIB_TemplateController con2 = new SIB_TemplateController();
        this.sibInfo = con2.sibInfo; 
        if (this.section != null) {
         	this.buttonLabel = (this.section.declaration == 'true') ? CONFIRM : STARTSECTION;
        	this.sectionText = SIB_Utilities.getSectionText(this.form.target_object+':'+this.section.id+' Section', true);
        	system.debug('####sectionText: '+sectionText);
        } else {    	
	    	// M.Witchalls Feb 2018: for section text (true = null return OK)
	        this.sectionText = SIB_Utilities.getSectionText(this.form.target_object+':Form', true); 
	        system.debug('####sectionText: '+sectionText);
        }
        this.fields = new List<COF_Field>();
	    this.fieldMap = new Map<String, COF_Field>();
        this.fieldIdentifiers = new List<String>{'Id','Name','Form_Complete__c'};
        this.fieldIdentifiers.add(this.form.block_status_field);
        if (this.form.approval_status_field != null) this.fieldIdentifiers.add(this.form.approval_status_field);
        if (this.form.issue_status_field != null) this.fieldIdentifiers.add(this.form.issue_status_field);
        for (COF_Section section : this.form.sections) {
	        if (section.status_field != null) this.fieldIdentifiers.add(section.status_field);        	
        } 
        if (this.form.period_title_field != null) {
        	this.fieldIdentifiers.add(this.form.period_title_field);
        }
        // M.Witchalls May 2018: history field
        if (this.form.title_append_field != null) {
        	this.fieldIdentifiers.add(this.form.title_append_field);
        }
        
        List<SObject> recordList;
        if (this.targetIdentifier == null) {
	        recordList = Query.objects(this.form.target_object, fieldIdentifiers,
	        	'WHERE lcf_grant__r.Name = \'' + this.getGrantIdentifierParam() + '\' AND '+ this.form.block_status_field + ' != \''+HISTORY+'\''
	        );
        } else {
        	recordList = Query.objects(this.form.target_object, fieldIdentifiers, 'WHERE ' + 'Name = \'' + this.targetIdentifier + '\'');  
        }
        if (recordList.size() > 0) {
        	this.targetObject = recordList[0];
        	if (this.form.period_title_field != null) this.periodTitle = (String)this.targetObject.get(this.form.period_title_field);
        	this.formStatus = (String)this.targetObject.get(this.form.block_status_field);
        }
        if (this.form.questions != null) {
	        for (COF_QuestionSet.COF_Question question : this.form.questions) {
	            this.fieldIdentifiers.add(question.target_field);
	            
	            COF_Field newField = new COF_Field(question.target_field, this.form.target_object);
	                    		
        		if (newField.pageTitle != null) {
        			this.questionsTitle = newField.pageTitle;
        		}
	            
	            if (newField.guidance == null && question.guidance != null) newField.guidance = question.guidance;
	            if (newField.recommendedWordLimit == null && question.recommended_word_limit != null) {
	                newField.recommendedWordLimit = question.recommended_word_limit;
	            }
	            this.fields.add(newField);
		        this.fieldMap.put(newField.identifier, newField);
	        }
        } 
    }
    
    public PageReference initialAction() {        
        // M.Witchalls Jan 2018 Fetch Status Fields
        //                      and create a new form object if not found
        // (Create has to be done here since no DML allowed in constructor)
        this.readOnlyMode = this.getReadOnlyMode(this.application, this.form, this.targetObject);
        String constraint;
        if (this.targetIdentifier == null) {
	        constraint = 'WHERE lcf_grant__r.Name = \'' + this.getGrantIdentifierParam() + '\' AND '+ this.form.block_status_field + ' != \''+HISTORY+'\'';
        } else {
        	constraint = 'WHERE ' + 'Name = \'' + this.targetIdentifier + '\'';  
        }
        if (this.readOnlyMode) {
        	List<SObject> objectList = Query.objects(this.form.target_object, this.fieldIdentifiers, constraint);
        	if (objectList.size() > 0) {
        		this.targetObject = objectList[0];
        	} else {
        		this.noCreate = true;
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, NOCREATEERROR));
				this.errorsFound = true;
        	}
        } else {     
	        this.targetObject = Query.object(this.form.target_object, this.fieldIdentifiers, constraint,
	        	CREATEIFNOTFOUND, this.grant.Id, this.form.reviewer_field, (String)this.grant.get('OwnerId')  // Set reviewer to grant owner
	        );
	        system.debug('@@@@form.sections: '+form.sections);
	        system.debug('@@@@section status: '+this.targetObject.get(form.sections[0].status_field));
	        this.readOnlyMode = this.getReadOnlyMode(this.application, this.form, this.targetObject);   
        }
        if (this.targetObject != null) {
        	this.targetIdentifier = (String)this.targetObject.get('Name');
		        
	        if (this.form.questions != null) {
	            this.prepareQuestions();
	        }
	    	this.formStatus = (String)this.targetObject.get(this.form.block_status_field);
			if (this.form.approval_status_field != null) {
				this.approvalStatus = ((String)this.targetObject.get(this.form.approval_status_field)).toUpperCase();
			} else {
				system.debug('@@@@issue status: '+this.targetObject.get(form.issue_status_field));
				String statusVal = (String)this.targetObject.get(this.form.issue_status_field);
				this.issueStatus = (statusVal == null) ? null : statusVal.toUpperCase();
			}     
	    
	        // M.Witchalls May 2018: Append special field to title for history
	        if (form.title != null && form.title_append_field != null) {
	        	COF_Field f = new COF_Field(form.title_append_field, this.form.target_object);
	        	this.prepareField(f);
	        	if (f.value != null) {
		        	String appendText = (form.title_append_text != null) ? form.title_append_text : ' ';
		        	form.title = form.title + appendText + f.value;
	        	}
	        }
        }
        if (this.section == null) {
			for (Integer i=0; i<this.form.sections.size(); i++) {
				COF_Section section = this.form.sections[i];
				if (section.include_checkbox != null) {
					if ((Boolean)this.targetObject.get(section.include_checkbox) != true) {
						this.form.sections.remove(i);
					}
				}
			}        	
        }
        return SIB_Utilities.checkLoggedInStatus();
    }

    public void prepareQuestions() {
	    
        // Manually handle our custom date fields and multi-select fields
        for (COF_Field field : this.fields) {
        	this.prepareField(field);
        }
    }
    
    public void prepareField(COF_Field field) {
    	field.value = String.valueOf(this.targetObject.get(field.identifier));
    	    	
   		if (field.warningText != null) this.endWarningText += field.warningText + '\n';
    	
        if (field.isDateField == true) {
            Date currentDate = (Date) this.targetObject.get(field.identifier);
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
		
		if (field.warningValue == null && field.warningText != null) {
			this.showWarning = true;
		} else if (field.warningValue != null && field.value == field.warningValue) {
			this.showWarning = true;
		}
    }

    public void saveTargetObject() {
        system.debug('####targetObject: '+this.targetObject);
        this.errorsFound = false;
        
        // Manually handle our custom date fields and multiselect checkbox fields
        for (COF_Field field : this.fields) {
        	if (field.value == null) field.value = String.valueOf(this.targetObject.get(field.identifier));
        	
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
                if (field.ratioPart != null && field.ratioPart != '') {
                	String ratioValue = '1:'+field.ratioPart;
                	this.targetObject.put(field.identifier, ratioValue);
                } 
            }
        	
            if (field.isDateField == true) {
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
            
            if (this.targetObject.get(field.identifier) == null) {
            	// M.Witchalls Apr 2018 '1:XXX' default value indicates a 'ratio' field
            	if (field.defaultValue != null && field.defaultValue != '1:XXX') {
            		this.targetObject.put(field.identifier, field.defaultValue);
            	}
            }
        }
        
        if (!this.errorsFound) {
        	// M.Witchalls Apr 2018 - check for validation errors in Query.cls and return updateResult wrapper
            Query.updateResult result = Query.updateObject(this.targetObject);
            if (result.isError) {
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, result.message));
        		errorsFound = true;      		
            }
        } 
    }
	
    public PageReference showHideStuff() {
    	String fieldId = ApexPages.currentPage().getParameters().get('fieldId');
        String fieldValue = String.valueOf(this.targetObject.get(fieldId));
        COF_Field thisField = this.fieldMap.get(fieldId); 
        system.debug('@@@@@fieldValue: '+fieldValue);
    	
    	this.showWarning = (fieldValue == thisField.warningValue) ? true : false;
    	saveTargetObject();
    	return null;
    }

    public PageReference start() {
    	if (this.section != null && this.form.questions != null) saveTargetObject();
    	if (this.errorsFound) return null;
    	
        PageReference nextPage = Page.Questions;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
	    if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
        nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
        if (this.section.title != this.form.title) nextPage.getParameters().put('title', this.section.title);
        if (this.periodTitle != null) nextPage.getParameters().put('periodtitle', this.periodTitle);
        nextPage.getParameters().put('page', '1');
        return nextPage;
    }
    
    public PageReference summaryPage() {
        PageReference nextPage = Page.Summary;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
	    if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
 		nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
        nextPage.getParameters().put('title', this.section.title);
		return nextPage; 
    }
    
    public PageReference summaryPdf() {
        PageReference nextPage = Page.SummaryPdf;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
	    if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
		nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
        nextPage.getParameters().put('title', this.section.title);
		return nextPage; 
    }

    /**
     * Submit the application
     */
	public PageReference submit() {
		
		if (this.form.issue_status_field != null) {
	    	if (this.grant.get(STATUSFIELD)!=PROJECTLAUNCHED) {
	    		LCF_Grant__c grantUpdate = new LCF_Grant__c(
		    		Id = (String)grant.get('Id')
		    	);
		    	grantUpdate.put(STATUSFIELD, PROJECTLAUNCHED);
		    	Query.updateObject(grantUpdate);
	    	}
	    	this.targetObject.put(this.form.block_status_field, COMPLETE);
	    	this.targetObject.put(this.form.issue_status_field, ISSUED);
	    	Query.updateObject(this.targetObject);
		} else if (this.form.approval_status_field != null) {
	    	this.targetObject.put(this.form.block_status_field, COMPLETE);
	    	this.targetObject.put(this.form.approval_status_field, SUBMITTED);
	    	Query.updateObject(this.targetObject);			
		}
		       
        PageReference nextPage = Page.COF_GrantBlockSubmitted;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
	    if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
        nextPage.setRedirect(true);
        return nextPage;
    }

    /**
     * View the answers
     */
    public PageReference viewAll() {

        PageReference nextPage = Page.FormSummary;
        nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
	    if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
        nextPage.setRedirect(true);
        return nextPage;
    }

    /**
     * View the answers
     */
    public PageReference viewAllPdf() {

        //PageReference nextPage = Page.Answers;
        PageReference nextPage = Page.FormSummaryPdf;
        nextPage.getParameters().put('grant', this.getGrantIdentifierParam());
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
	    if (this.targetIdentifier != null) nextPage.getParameters().put('id', this.targetIdentifier);
        nextPage.setRedirect(true);
        return nextPage;
    }
    
    public PageReference archiveBlock() {
    	this.targetObject.put(this.form.block_status_field, HISTORY);
    	this.targetObject.put('Archive_Date__c', System.today());
    	Query.updateObject(this.targetObject);
	
        PageReference nextPage = Page.LCFGrants;
        nextPage.getParameters().put('id', (String)this.grant.get('Application__c'));
		return nextPage; 
    }

}