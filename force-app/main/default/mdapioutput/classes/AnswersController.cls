/**
 * Answers Controller
 */
public class AnswersController extends COF_PageController {

	public List<COF_Field> fields {get;set;}
    public SObject targetObject {get;set;}

    public AnswersController() {

    	// we should pass through the section > field hierarchy to the view, so we can group

    	// Create a list of fields to display
    	this.fields = new List<COF_Field>();

    	// Lookup the relevant page layout, so we can display the fields grouped and in an appropriate order
    	List<String> componentNameList = new List<String>{'Form_LCF_Full_App_1__c-Form LCF Full Application 1%2E0 Layout'};
		List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
		Metadata.Layout layout = (Metadata.Layout) components.get(0);
		if (layout != null && layout.layoutSections != null) {
			// Loop through the sections
			for (Metadata.LayoutSection section : layout.layoutSections) {
				// Only consider sections that have custom labels, avoiding the mandatory system sections
				if (section.customLabel == true) {
					// Loop through the columns - our layouts are configured with a single column
					for (Metadata.LayoutColumn layoutColumn : section.layoutColumns) {
						// Loop through the layout items
						if (layoutColumn.layoutItems != null) {
							for (Metadata.LayoutItem layoutItem : layoutColumn.layoutItems) {
								if (layoutItem.field != null) {
									// Create a field to represent this layout item
									COF_Field newField = new COF_Field(layoutItem.field, 'Form_LCF_Full_App_1__c');
									this.fields.add(newField);
								}
							}
						}
					}
				}
			}
		}

		// Fetch the target object
		this.fetchTargetObject();
    }

    /**
     * Fetches the target object
     */
    public void fetchTargetObject() {
        
        // Generate list of all fields we might require on the target object
        Set<String> requiredFieldIdentifiers = new Set<String>();
        for (COF_Field field : this.fields) {
        	requiredFieldIdentifiers.add(field.identifier);
        }

        // Fetch the target object
        List<String> requiredFieldIdentifiersArray = new List<String>(requiredFieldIdentifiers);
        this.targetObject = Query.object('Form_LCF_Full_App_1__c', requiredFieldIdentifiersArray, 'where ' +  'Application__r.Name = \'' + this.getApplicationIdentifierParam() + '\'');
    }

}