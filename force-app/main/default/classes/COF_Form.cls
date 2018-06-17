/**
 * COF_Form
 * Cabinet Office Forms 1.0
 *
 * This class represents a form.
 */
public class COF_Form {

	public String id {get;set;}
	public String reference_Id {get;set;}
	public String title {get;set;}
	public String short_title {get;set;}
	public String title_append_text {get;set;}
	public String title_append_field {get;set;}
	public String target_object {get;set;}
	public String users_able_to_edit {get;set;}
	public String application_status_field {get;set;}
	public String block_status_field {get;set;}
	public String approval_status_field {get;set;}
	public String issue_status_field {get;set;}
	public String period_title_field {get;set;}
	public String reviewer_field {get;set;}
	public String history_required {get;set;}
	public String history_fields {get;set;}
	public String history_headers {get;set;}
	public List<COF_QuestionSet.COF_Question> questions {get;set;}
	public List<COF_Section> sections {get;set;} 
	public Boolean readonlyMode {get;set;}
	
	public COF_Form() {
		this.readonlyMode = false;
	}

	/**
	 * Returns a section given an identifier
	 */
	public COF_Section getSection(String identifier) {
		for (COF_Section section : this.sections) {
			if (section.id == identifier) {
				return section;
			}
		}
		return null;
	}
}