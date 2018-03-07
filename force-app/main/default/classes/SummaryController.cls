/* _______________________________________________________________________________________________________________
   Name:		SummaryController.cls
   Description: Controller class for Summary Visualforce page
					
   Date         Version Author          		Summary of Changes 
   ___________  _______ __________________		__________________________________________________________________
   2017		    1.0    	Cabinet Office			Initial Release 
   Jan 2018		1.1		M.Witchalls, Westbrook	Test for all questions answered
   Mar 2018		1.2		M.Witchalls, Westbrook	Correction to child question check
__________________________________________________________________________________________________________________ */        
public class SummaryController extends COF_PageController {
	private static final String COMPLETE = 'COMPLETE';
	private static final String INCOMPLETE = 'INCOMPLETE';

	public COF_Form form {get;set;} 
    public COF_Section section {get;set;}
    public COF_QuestionSet questionSet {get;set;}
    public SObject application {get;set;}
    public SObject targetObject {get;set;}

    public List<COF_Page> validPages {get;set;}
	public SIB_Information__c sibInfo {get;set;}

    public SummaryController() { 

        COF_Config config = COF_Config.load(this.getFormIdentifierParam());
        this.form = config.getForm(this.getFormIdentifierParam());
        system.debug('###this.form: '+this.form);
        this.section = form.getSection(this.getSectionIdentifierParam());
        system.debug('###this.getSectionIdentifierParam(): '+this.getSectionIdentifierParam());
        system.debug('###this.section: '+this.section);
        this.questionSet = this.section.getQuestionSet();
        this.application = this.getApplication();
        
		// M.Witchalls Jan 2018
        this.section.questionsComplete = true;
		
        // Validate these mandatory variables are present and throw exception otherwise

        // Prepare and fetch target object
        this.fetchTargetObject();

        // Create holding array for pages to summarise
        this.validPages = new List<COF_Page>();

        // Create a new router object
        COF_Router router = new COF_Router();
        router.targetObject = targetObject;
        router.questionSet = questionSet;

        // Start on the first page
        COF_Page nextPage = router.questionSet.getPage('1');
        do {
            if (nextPage != null) {
                validPages.add(nextPage);
                System.debug('###nextPage: '+nextPage);
                // M.Witchalls Jan 2018
                for (COF_Field field: nextPage.fields) {
                	if (router.targetObject.get(field.identifier) == null) {
                		this.section.questionsComplete = false;
                	}
                }
            }
            // Use the route to determine the next page
            nextPage = router.nextFromPage(nextPage);
        } while (nextPage != null);

    }

    /**
     * Fetches the target object
     */
    public void fetchTargetObject() {
        
        // Generate list of all possible fields we might require on the target object
        Set<String> requiredFieldIdentifiers = new Set<String>();
        for (COF_Page page : this.questionSet.pages) {
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
            // Loop through the children
            if (page.children != null) {
            	requiredFieldIdentifiers.add(this.childQuery(page));
            }
            
            // fetch section status
            requiredFieldIdentifiers.add(this.section.status_field);
        }

        // Fetch the target object
        List<String> requiredFieldIdentifiersArray = new List<String>(requiredFieldIdentifiers);
        this.targetObject = Query.object(this.questionSet.target_object, requiredFieldIdentifiersArray, 'WHERE ' +  this.questionSet.parent_relationship + '.Name = \'' + this.getApplicationIdentifierParam() + '\'');

		// M.Witchalls Jan 2018: Check child records for missing fields
	    for (COF_Page page: this.questionSet.pages) {
			if (page.children != null) {
	        	for (SObject childObject: this.targetObject.getSObjects(page.children.child_relationship)) {
	        		
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
			                	if (router.targetObject.get(field.identifier) == null) {
			                		this.section.questionsComplete = false;
			                	}
			                }
			            }
			            // Use the route to determine the next page
			            nextPage = router.nextFromPage(nextPage);
			        } while (nextPage != null);
	        	}
	        }
		}
		
    }
    
    // M.Witchalls Jan 2018: construct child query
    public String childQuery(COF_Page page) {    	
    	Set<String> fieldIdentifiers = new Set<String>();
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
        }
        String fieldsList = Query.fieldListString(new List<String>(fieldIdentifiers));
        
    	return '(SELECT ' + fieldslist + ' FROM ' + page.children.child_relationship + ' ORDER BY CreatedDate ASC)';
    }

    public PageReference complete() {

    	// update ov_section_status__c
        if (this.targetObject != null) { 
        	this.targetObject.put(this.section.status_field, COMPLETE);
            Query.updateObject(this.targetObject);
        }
    	
       	PageReference nextPage = Page.Sections;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        return nextPage;
    }

    public PageReference saveExit() {

        PageReference nextPage = Page.Sections;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        return nextPage;
    }

}