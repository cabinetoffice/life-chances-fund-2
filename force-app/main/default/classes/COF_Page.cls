/**
 * COF_Page
 * Cabinet Office Forms 1.0
 *
 * This class represents a page in a section.
 */
public class COF_Page {
	
	public String id {get;set;} 
	public String reference_section {get;set;}
	public String reference_id {get;set;}
	public String reference_guidance {get;set;}
	public String copy_guidance {get;set;}
	public String title {get;set;}
	public String title_id {get;set;}
	public String title_append_text {get;set;}
	public String title_append_field {get;set;}
	public String guidance {get;set;}
	public String guidance_id {get;set;}
	public String warning {get;set;}
	public String warning_id {get;set;}
	public String end_warning {get;set;}
	public String end_warning_id {get;set;}
	public String readonly {get;set;}
	public String child_of_child {get;set;}
	public List<COF_QuestionSet.COF_Question> questions {get;set;}
	public List<COF_QuestionSet.COF_Route> routes;
	public COF_QuestionSet.COF_Children children {get;set;}
	public COF_QuestionSet.COF_Files files {get;set;}
	public COF_Field filesField {get;set;}
	public COF_Field displayField {get;set;}
	public SIB_Section_Text__c sectionText {get;set;}
	
	public List<COF_Field> fields {get;set;}
    
    //As with all the pages where we require a user to be logged in, we check here if the user is logged in, else return the homepage
    public PageReference checkLoggedInStatus(){
        return SIB_Utilities.checkLoggedInStatus();
    }

	public void prepareFields(String targetObjectType) {
		this.fields = new List<COF_Field>();
		if (this.questions != null) {
	        for (COF_QuestionSet.COF_Question question : this.questions) {
				COF_Field newField = new COF_Field(question.target_field, targetObjectType);
            	if (question.guidance != null) newField.guidance = question.guidance;
            	if (question.recommended_word_limit != null) {
            		newField.recommendedWordLimit = question.recommended_word_limit;
        		}
        		
        		// M.Witchals Mar 2018: Optionally set Page Title from field via fieldMetadata.Page_Title__c
        		if (this.title_id == null && newField.pageTitle != null) {
        			this.title = newField.pageTitle;
        		}
        		
        		// M.Witchalls Apr 2018
        		if (question.constraints != null) newField.constraints = question.constraints;
        		
            	this.fields.add(newField);
            }
    	}
    	if (this.children != null) {
	        if (this.children.target_object != null && this.children.parent_field != null) {
	        	COF_Field field = new COF_Field(this.children.parent_field, this.children.target_object);
	        	if (this.children.child_relationship == null) this.children.child_relationship = field.childRelationship;
	        	if (this.children.parent_relationship == null) this.children.parent_relationship = field.parentRelationship;
	        } 	
	        if (this.children.display_field != null) {
	        	this.displayField = new COF_Field(this.children.display_field, targetObjectType);
	        }	
    	} 
    	if (this.files != null) {
    		this.filesField = new COF_Field(this.files.target_field, targetObjectType);  		
    	}
    	
    	// Get title from title_id and warning from warning_id
    	system.debug('#####key: '+targetObjectType+':'+this.title_id);
    	if (this.title_id != null && this.title == null) {
    		this.title = SIB_Utilities.getSectionText(targetObjectType+':'+this.title_id).Text__c;
	    	if (this.title != null) this.title = this.title.stripHtmlTags();
    	}
	    if (this.warning_id != null) {
	    	this.warning = SIB_Utilities.getSectionText(targetObjectType+':'+this.warning_id).Text__c;
	    	if (this.warning != null) this.warning = this.warning.stripHtmlTags();
	    }
	    if (this.end_warning_id != null) {
	    	this.end_warning = SIB_Utilities.getSectionText(targetObjectType+':'+this.end_warning_id).Text__c;
	    	if (this.end_warning != null) this.end_warning = this.end_warning.stripHtmlTags();
	    }
    	
	}
}