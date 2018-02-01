public class QuestionsController extends COF_PageController {
	public static final String COMPLETE = 'COMPLETE';
	public static final String INCOMPLETE = 'INCOMPLETE';

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
    
    private String statusField;
    private SObject targetObjectOriginal;

    public QuestionsController() {

        COF_Config config = COF_Config.load();
        this.form = config.getForm(this.getFormIdentifierParam());
        this.section = form.getSection(this.getSectionIdentifierParam());
        
        // M.Witchalls Jan 2018: Get section and page status values
        if (this.section != null) { // parent object
            this.questionSet = this.section.getQuestionSet();
            this.statusField = this.section.status_field;
        } else { // child object 
            this.questionSet = COF_QuestionSet.load(this.getSectionIdentifierParam());
            this.statusField = this.questionSet.status_field;
        }

        this.application = this.getApplication(); 
        this.currentPage = this.questionSet.getPage(this.getPageIdentifierParam());
        this.fields = new List<COF_Field>(); 
        
        List<COF_Field> fields = new List<COF_Field>();
        Set<String> fieldIdentifierSet = new Set<String>{'Id','Name'};
        fieldIdentifierSet.add(this.questionSet.parent_relationship+'.Id');
        if (this.section != null) { // parent object
            fieldIdentifierSet.add(this.statusField);
 		} else { // child object - get parent status
            fieldIdentifierSet.add(this.questionSet.parent_relationship+'.'+this.statusField);
        }
        
        if (this.currentPage.questions != null) {
	        for (COF_QuestionSet.COF_Question question : this.currentPage.questions) {
	            fieldIdentifierSet.add(question.target_field);
	            COF_Field newField = new COF_Field(question.target_field, this.questionSet.target_object);
	            newField.guidance = question.guidance;
	            if (question.recommended_word_limit != null) {
	                newField.recommendedWordLimit = question.recommended_word_limit;
	            }
	            fields.add(newField);
	            // Use prepareFields on page instead
	        }
	        this.fields = fields;
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
    }

    public void prepareQuestions() {

        // Manually handle our custom date fields and multi-select fields
        for (COF_Field field : this.fields) {
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
                    valueSet.addAll(fieldValue.split(';'));
                    for (COF_Field.CheckBoxOption opt: field.optionList) {
                        if (valueSet.contains(opt.value)) opt.selected = true;
                    }
                }
            }

        }

    }

    public void prepareChildren() {
        List<String> fields = new List<String>();
        fields.add(this.currentPage.children.target_field);
        fields.add('CreatedDate');
        fields.add('Name');
        String appIdentifier = this.getApplicationIdentifierParam();
        system.debug('###this.targetObject: '+this.targetObject);
        this.targetObjects = Query.objects(this.currentPage.children.target_object, fields, 'WHERE full_application__r.Name = \'' + this.targetObject.get('Name') + '\'ORDER BY CreatedDate asc');
    }

    public void saveTargetObject() {
    	
        // M.Witchalls Jan 2018: Get section and page status values
	    String statusValue;	    
        if (this.section != null) { // parent object
        	statusValue = (String)this.targetObject.get(this.statusField);
        } else { // child object
        	statusValue = (String)this.targetObject.getSObject(this.questionSet.parent_relationship).get(this.statusField);
        }
        
        // M.Witchalls Jan 2018: Section status logic: if any change of value, mark as INCOMPLETE
        Boolean isComplete = true;
        
        // Manually handle our custom date fields and multiselect checkbox fields
        for (COF_Field field : this.fields) {
        	if (this.targetObject.get(field.identifier) != this.targetObjectOriginal.get(field.identifier)) {
        		isComplete = false;
        	}
        	
            if (field.isDateField == true) {
                // Error - Should check all fields
                if (field.dateDay != null && field.dateDay != '') {
                    Date datevalue = date.parse(field.dateDay + '/' + field.dateMonth + '/' + field.dateYear);
                    this.targetObject.put(field.identifier, datevalue);
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
        }
        
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

        // Attempt to update the target object
        if (this.targetObject != null) { 
            Query.updateObject(this.targetObject);
        }
    }

    public PageReference saveContinue() {

        if (this.targetObject != null) {
            this.saveTargetObject();
        }

        PageReference nextPage = Page.Questions;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('id', this.getRecordIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
        nextPage.setRedirect(true);

       // If we have a completion path, pass to the next page
        String completionPath = ApexPages.currentPage().getParameters().get('zzcompletion');
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
                                nextPage.getParameters().put('page', String.valueOf(route.target_page));
                                return nextPage;
                            }
                        }
                        if (constraint.operator == 'contains') {
                            String targetObjectField = (string)this.targetObject.get(constraint.field);
                            if (targetObjectField.contains(constraint.value) == true) {
                                // Valid constraint - redirect based on this route
                                nextPage.getParameters().put('page', String.valueOf(route.target_page));
                                return nextPage;
                            }
                        }
                    }
                } else {
                    // No constraints - redirect based on this route
                    nextPage.getParameters().put('page', String.valueOf(route.target_page));
                    return nextPage;
                }
            }
        }
        
        // No valid routes so redirect to summary
        nextPage = Page.Summary;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());

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
        }
        nextPage.setRedirect(true);
        
        return nextPage;
    }

    public PageReference saveExit() {

        if (this.targetObject != null) {
            this.saveTargetObject();
        }

        PageReference nextPage = Page.Sections;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        return nextPage;
    }

    public PageReference addAnother() {

        // Create a new child
        Database.SaveResult result = Query.createObject(this.currentPage.children.target_object, application.Id, (String)this.targetObject.get('Id'));
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
}