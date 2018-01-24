/**
 * COF_QuestionSet
 * Cabinet Office Forms 1.0
 *
 * This class represents a question set (a list of pages, questions and branching logic) in a section.
 */
public class COF_QuestionSet {

	public String id;
	public String target_object;
	public String status_field;
	public String page_status_field;
	public String parent_relationship;
	public List<COF_Page> pages;

	public class COF_Children {
		public String target_field {get;set;}
		public String target_object {get;set;}
		public String child_relationship {get;set;}
		public String section {get;set;}
		public List<COF_Page> childPages {get;set;}
	}

	public class COF_Constraint {
		public String field;
		public String operator;
		public String value;
	}

	public class COF_Question {
		public String target_field {get;set;}
		public String guidance {get;set;}
		public Integer recommended_word_limit {get;set;}
	}

	public class COF_Route {
		public String target_page;
		public List<COF_Constraint> constraints;
	}

	public COF_Page getPage(String pageId) {
		for (COF_Page page : this.pages) {
			if (page.id == pageId) {
				return page;
			}
		}
		throw new COF_Exception('Could not get referenced page');
		return null;
	}

	/**
	 * Instantiates a new COF_QuestionSet object given an identifier, deserializing
	 * the relevant JSON configuration definition
	 */
	public static COF_QuestionSet load(String identifier) {
        try {
		    // Load JSON representation of form
			String questionSetUrl = PageReference.forResource(identifier).getUrl();
        	PageReference questionSetReference = new PageReference(questionSetUrl);
    		String questionSetJson = questionSetReference.getContent().toString();
	    	// Instantiate form from JSON
	        return (COF_QuestionSet) System.JSON.deserialize(questionSetJson, COF_QuestionSet.class);
		} catch(Exception ex) {
		    throw new COF_Exception('Could not deserialize referenced question set from JSON');
		}
	}
}