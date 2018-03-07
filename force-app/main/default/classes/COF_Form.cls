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
	public String target_object {get;set;}
	public String application_status_field {get;set;}
	public List<COF_Section> sections {get;set;} 
	public Boolean readonlyMode {get; set;}
	
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