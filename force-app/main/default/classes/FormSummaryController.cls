/* _______________________________________________________________________________________________________________
   Name:		FormSummaryController.cls
   Description: Controller class for Form Summary Visualforce page
					
   Date         Version Author          		Summary of Changes 
   ___________  _______ ______________________	__________________________________________________________________
   May 2018		1.0		M.Witchalls, Westbrook	Initial Release
   Jun 2018		1.1		M.Witchalls, Westbrook	Provision for optional sections
__________________________________________________________________________________________________________________ */        
public class FormSummaryController extends COF_PageController {
	private static final String APPLRELATIONSHIP = 'application__r';
	private static final String GRANTRELATIONSHIP = 'lcf_grant__r';
	private static final String PRIMARYFIELDID = 'primary__c';
	private static final String HISTORY = 'HISTORY';

    // M.Witchalls Mar 2018 
    public Boolean readOnlyMode {get;set;}
    
	public COF_Form form {get;set;} 
    public SObject application {get;set;}
   	public SObject grant {get;set;} 
    public SObject targetObject {get;set;}

	public SIB_Information__c sibInfo {get;set;}
	public String appName {get;set;}
	public String grantName {get;set;}
	
    private String targetIdentifier;

    public FormSummaryController() { 

        COF_Config config = COF_Config.load(this.getFormIdentifierParam());
        this.form = config.getForm(this.getFormIdentifierParam());
        system.debug('###this.form: '+this.form);
        this.targetIdentifier = this.getRecordIdentifierParam();
        this.application = this.getApplication();
        this.appName = (this.application == null) ? null : (String)this.application.get('Name');
        this.grant = this.getGrant();
        this.grantName = (this.grant == null) ? null : (String)this.grant.get('Name');

        // Prepare and fetch target object
        this.fetchTargetObject(); 
    
        // M.Witchalls May 2018: Append special field to title for history
        if (this.form.title != null && this.form.title_append_field != null) {
        	COF_Field f = new COF_Field(this.form.title_append_field, this.form.target_object);
        	this.prepareField(f);
        	if (f.value != null) {
	        	String appendText = (this.form.title_append_text != null) ? this.form.title_append_text : ' ';
	        	this.form.title = this.form.title + appendText + f.value;
        	}
        }
        
        //M.Wichalls Jun 2018: Remove optional sections
		for (Integer i=0; i<this.form.sections.size(); i++) {
			COF_Section section = this.form.sections[i];
			if (section.include_checkbox != null) {
				if ((Boolean)this.targetObject.get(section.include_checkbox) != true) {
					this.form.sections.remove(i);
				}
			}
		}        	
        
        for (COF_Section formSection: this.form.sections) {
        	COF_QuestionSet questionSet = formSection.getQuestionSet();
        	system.debug('###questionSet: '+questionSet);
	
	        // Create holding array for pages to summarise
	        formSection.validPages = new List<COF_Page>();
	
	        // Create a new router object
	        COF_Router router = new COF_Router();
	        router.targetObject = targetObject;
	        router.questionSet = questionSet;
	
	        // Start on the first page
	        COF_Page nextPage = router.questionSet.getPage('1');
	        do {
	            if (nextPage != null) { 
	        
			        // M.Witchalls May 2018: Append special field to title for history 
			        if (nextPage.title != null && nextPage.title_append_field != null) {
			        	COF_Field f = new COF_Field(nextPage.title_append_field, questionSet.target_object);
			        	this.prepareField(f);
	        			if (f.value != null) {
				        	String appendText = (nextPage.title_append_text != null) ? nextPage.title_append_text : ' ';
				        	nextPage.title = nextPage.title + appendText + f.value;
	        			}
			        }
			        
	                formSection.validPages.add(nextPage);
	                System.debug('###nextPage: '+nextPage);
					// M.Witchalls Jan 2018
	                for (COF_Field field: nextPage.fields) { 
	                	
	                	// M.Witchalls Apr 2018 Field Constraints
	                	field.isValid = true;
			        	if (field.constraints != null) {
			                for (COF_QuestionSet.COF_Constraint constraint : field.constraints) {
			                	field.isValid = router.validConstraint(constraint, this.targetObject.get(constraint.field));
			                }
			        	}
	                }
	                // Append files field
			        if (nextPage.files != null) {
			        	System.debug('@@@nextPage.files: '+nextPage.files);
		            	nextPage.fields.add(nextPage.filesField);
			        }
	             }
	            // Use the route to determine the next page
	            nextPage = router.nextFromPage(nextPage);
	        } while (nextPage != null);
	    	
	    	this.checkChildPages(formSection);
	        
        }
        
    }

	public void prepareField(COF_Field f) {
    	f.value = null;
        if (f.isDateField == true) {
            Date currentDate = (Date) this.targetObject.get(f.identifier);
            if (currentDate != null) {
                f.dateDay = String.valueOf(currentDate.day());
                f.dateMonth = String.valueOf(currentDate.month());
                f.dateYear = String.valueOf(currentDate.year());
            	f.value = f.dateDay.leftPad(2,'0')+'/'+f.dateMonth.leftPad(2,'0')+'/'+f.dateYear;
            }
        } else {
    		f.value = String.valueOf(this.targetObject.get(f.identifier));	        	
        }		
	}

    /**
     * Fetches the target object
     */
    public void fetchTargetObject() {
        
        // Generate list of all possible fields we might require on the target object
        Set<String> requiredFieldIdentifiers = new Set<String>{'Id','Name'};
        if (this.form.period_title_field != null) {
        	requiredFieldIdentifiers.add(this.form.period_title_field);
        }
    
        // M.Witchalls May 2018: history field
        if (this.form.title_append_field != null) {
        	requiredFieldIdentifiers.add(this.form.title_append_field);
        }
    
        // M.Witchalls Jun 2018: optional section field
        if (this.form.title_append_field != null) {
        	requiredFieldIdentifiers.add(this.form.title_append_field);
        }
        
        for (COF_Section formSection: this.form.sections) {
        	COF_QuestionSet questionSet = formSection.getQuestionSet();
	        for (COF_Page page : questionSet.pages) {
	            // Loop through the questions
	            if (page.questions != null) {
	                for (COF_QuestionSet.COF_Question question : page.questions) {
	                    requiredFieldIdentifiers.add(question.target_field);
	                }
	            }
	            // Loop through the route constraints
	            if (page.routes != null) {
	                for (COF_QuestionSet.COF_Route route : page.routes) {
	                    if (route.constraints != null) {
	                        for (COF_QuestionSet.COF_Constraint constraint : route.constraints) {
	                            requiredFieldIdentifiers.add(constraint.field);
	                        }
	                    }
	                }
	            }
            
		        if (page.children != null) {
	            	if (page.children.total_field2 != null) requiredFieldIdentifiers.add(page.children.total_field2);
	            	if (page.children.total_field3 != null) requiredFieldIdentifiers.add(page.children.total_field3);
	            	if (page.children.total_field4 != null) requiredFieldIdentifiers.add(page.children.total_field4);
	            	if (page.children.total_field5 != null) requiredFieldIdentifiers.add(page.children.total_field5);
	            	if (page.children.total_field6 != null) requiredFieldIdentifiers.add(page.children.total_field6);
	 	        }
 	            
		        if (page.files != null) {
		        	system.debug('@@@@page.filesField.identifier: '+page.filesField.identifier);
	            	requiredFieldIdentifiers.add(page.files.target_field);
		        }
	        
		        // M.Witchalls May 2018: history field
		        if (page.title_append_field != null) {
		        	requiredFieldIdentifiers.add(page.title_append_field);
		        }
	        }
	        // fetch section status
	        requiredFieldIdentifiers.add(formSection.status_field);
	        
	        // M.Witchalls Jun 2018 - optional section include field
	        if (formSection.include_checkbox != null) {
	        	requiredFieldIdentifiers.add(formSection.include_checkbox);
	        }
        }
        if (this.form.approval_status_field != null) {
        	requiredFieldIdentifiers.add(this.form.approval_status_field);
        }

        // Fetch the target object
        List<String> requiredFieldIdentifiersArray = new List<String>(requiredFieldIdentifiers);
        //system.assert(false, requiredFieldIdentifiersArray);
        if (this.targetIdentifier == null) {
	        if (this.grant == null) {
	        	this.targetObject = Query.object(this.form.target_object, requiredFieldIdentifiersArray, 'WHERE ' + APPLRELATIONSHIP + '.Name = \'' + this.getApplicationIdentifierParam() + '\'');
	        } else {
	        	this.targetObject = Query.object(this.form.target_object, requiredFieldIdentifiersArray, 
						        		'WHERE ' +  GRANTRELATIONSHIP + '.Name = \'' + this.getGrantIdentifierParam()       	
							            + '\' AND '+ this.form.block_status_field + ' != \''+HISTORY+'\'');	        		
	        }
        } else {
        	this.targetObject = Query.object(this.form.target_object, requiredFieldIdentifiersArray, 'WHERE ' + 'Name = \'' + this.targetIdentifier + '\'');  
        }
        system.debug('@@@@this.targetObject: '+this.targetObject);
    }
    

    /**
     * Checks child records for valid pages (and populate child data)
     */
    public void checkChildPages(COF_Section formSection) {
		// M.Witchalls Jan 2018: Check child records for missing fields
	    for (COF_Page page: formSection.validPages) {
			if (page.children != null) {
	    		page.children.childRecs = new List<SObject>();
	    		for (SObject obj: Database.query(this.childQuery(page))) {
	     			page.children.childRecs.add(obj);
	     		}
    			system.debug('@@@@page.children.chidRecs: '+page.children.childRecs);
				Integer childCount = 0;
	        	//for (SObject childObject: this.targetObject.getSObjects(page.children.child_relationship)) {
	        	for (SObject childObject: page.children.childRecs) {
	        		childCount++;
	        		
	        		// M.Witchalls Mar 2018: Corrected this section: include only valid child pages
			        // Create a new router object
			        COF_Router router = new COF_Router();
			        router.targetObject = childObject;
			        router.questionSet = COF_QuestionSet.load(page.children.section);
			        
			        page.children.childPages = new List<COF_Page>();			
			        // Start on the first page
			        COF_Page nextPage = router.questionSet.getPage('1');
			        do {
			            if (nextPage != null) {
                			page.children.childPages.add(nextPage);
			                for (COF_Field field: nextPage.fields) {
			                	
			                	// M.Witchalls Apr 2018 Field Constraints
			                	field.isValid = true;
					        	if (field.constraints != null) {
					                for (COF_QuestionSet.COF_Constraint constraint : field.constraints) {
					                	field.isValid = router.validConstraint(constraint, router.targetObject.get(constraint.field));
					                }
					        	}
			                }
			            }
			            // Use the route to determine the next page
			            nextPage = router.nextFromPage(nextPage);
			        } while (nextPage != null);
	        	}
               	system.debug('@@@@childCount: '+childCount);
	        }
		}
		
    }
    
    // M.Witchalls Jan 2018: construct child query
    public String childQuery(COF_Page page) {    	
    	Set<String> fieldIdentifiers = new Set<String>{'Id','CreatedDate'};
    	system.debug('###page.children.section: '+page.children.section);
		COF_QuestionSet childQuestionSet = COF_QuestionSet.load(page.children.section);
		page.children.childPages = childQuestionSet.pages;
		
        for (COF_Page childPage: page.children.childPages) {
            childPage.prepareFields(childQuestionSet.target_object);
            
        	// Loop through the questions
	        if (childPage.questions != null) {
	            for (COF_QuestionSet.COF_Question question : childPage.questions) {
	                fieldIdentifiers.add(question.target_field);
	            }
	        }
            // Loop through the route constraints
            if (childPage.routes != null) {
                for (COF_QuestionSet.COF_Route route : childPage.routes) {
                    if (route.constraints != null) {
                        for (COF_QuestionSet.COF_Constraint constraint : route.constraints) {
                            fieldIdentifiers.add(constraint.field);
                        }
                    }
                }
            }
            // Child of child display fields
            if (childPage.displayField != null) {
	            fieldIdentifiers.add(childPage.displayField.identifier);
            }
        }
        
        String fieldsList = Query.fieldListString(new List<String>(fieldIdentifiers));
        //String queryString = '(SELECT Name,' + fieldslist + ' FROM ' + page.children.child_relationship;
        String queryString = 'SELECT Name,' + fieldslist + ' FROM ' + page.children.target_object;
        if (this.targetIdentifier == null) {
		    if (this.grant == null) {
	        	queryString += ' WHERE ' + page.children.parent_relationship + '.' + APPLRELATIONSHIP + '.Name = \'' + this.getApplicationIdentifierParam() + '\'';
		    } else {
	        	queryString += ' WHERE ' + page.children.parent_relationship + '.' + GRANTRELATIONSHIP + '.Name = \'' + this.getGrantIdentifierParam() + '\'';	    	
		    }
        } else {
            queryString += ' WHERE ' + page.children.parent_relationship + '.' + 'Name = \'' + this.targetIdentifier + '\'';            
        }
        if (page.children.target_filter != null) {
        	queryString += ' AND '+page.children.target_filter;
        }   
         if (fieldIdentifiers.contains(PRIMARYFIELDID)) {
			queryString += ' ORDER BY '+ PRIMARYFIELDID + ' DESC, Name ASC';       	
        } else {
			queryString += ' ORDER BY Name ASC';
        }
        
    	return queryString;
    }
}