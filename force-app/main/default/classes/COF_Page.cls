/**
 * COF_Page
 * Cabinet Office Forms 1.0
 *
 * This class represents a page in a section.
 */
public class COF_Page {
	
	public String id {get;set;}
	public String title {get;set;}
	public String guidance {get;set;}
	public List<COF_QuestionSet.COF_Question> questions {get;set;}
	public List<COF_QuestionSet.COF_Route> routes;
	public COF_QuestionSet.COF_Children children {get;set;}
	
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
            	newField.guidance = question.guidance;
            	if (question.recommended_word_limit != null) {
            		newField.recommendedWordLimit = question.recommended_word_limit;
        		}
            	this.fields.add(newField);
            }
    	}
	}
}