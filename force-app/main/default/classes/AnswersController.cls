/* __________________________________________________________________________________________________________________
   Name:		AnswersController.cls
   Description: Controller class for Answers Visualforce page (rendered as PDF)
					
   Date         Version Author          		Summary of Changes 
   ___________  _______ __________________		_____________________________________________________________________
   2017		    1.0    	Cabinet Office			Initial Release 
   Jan 2018		1.1		M.Witchalls, Westbrook	Child query added
   Feb 2018		1.2		M.Witchalls, Westbrook	Inclusion of Setup Form via layoutMap
   Mar 2018		1.3		M.Witchalls, Westbrook	Provision for multiple child forms per section
__________________________________________________________________________________________________________________ */        
public class AnswersController extends COF_PageController {

	private static final Map<String, String> layoutMap = new Map<String, String>{
		'lcf_full_app_1'=>'Form_LCF_Full_App_1__c-Form LCF Full Application 1%2E0 Layout',
		'lcf_setup_1'=>'Form_LCF_Setup_1__c-Form LCF Full Award Setup 1%2E0 Layout',
		'lcf_test'=>'Form_LCF_Full_App_1__c-Form LCF Full Application 1%2E0 Layout'
	};

	public COF_Form form {get;set;} 
	public List<COF_Field> fields {get;set;}
	public List<PageSection> sections {get;set;}
    public SObject application {get;set;} 
    public SObject targetObject {get;set;}
 
    public AnswersController() {
        this.application = this.getApplication();
    	String identifier = this.getFormIdentifierParam();
        COF_Config config = COF_Config.load(identifier);
        this.form = config.getForm(identifier);
		String layoutName = layoutMap.get(identifier);
		if (layoutName == null) {
			throw new COF_Exception('Could not obtain layout name for form '+identifier);
		}

    	// we should pass through the section > field hierarchy to the view, so we can group

    	// Create a list of fields to display
    	this.fields = new List<COF_Field>();
    	
    	this.sections = new List<PageSection>();    	

    	// Lookup the relevant page layout, so we can display the fields grouped and in an appropriate order
    	List<String> componentNameList = new List<String>{layoutName};
		List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
		Metadata.Layout layout = (Metadata.Layout) components.get(0);
		system.debug('#####layout.layoutSections: '+layout.layoutSections);
		if (layout != null && layout.layoutSections != null) {
			// Loop through the sections
			for (Metadata.LayoutSection section : layout.layoutSections) {
				// Only consider sections that have custom labels, avoiding the mandatory system sections
				if (section.customLabel == true && section.label != 'Custom Links' && section.label != 'Test Section') {
					PageSection newSection = new PageSection(section.label, this.form.sections);
					newSection.fields = new List<COF_Field>();
					
					// Loop through the columns - our layouts are configured with a single column
					for (Metadata.LayoutColumn layoutColumn : section.layoutColumns) {
						// Loop through the layout items
						if (layoutColumn.layoutItems != null) {
							for (Metadata.LayoutItem layoutItem : layoutColumn.layoutItems) {
								if (layoutItem.field != null) {
									// Create a field to represent this layout item
									COF_Field newField = new COF_Field(layoutItem.field, form.target_object);
									this.fields.add(newField);
									newSection.fields.add(newField);
								}
							}
						}
					}
					
					this.sections.add(newSection);
				}
			}
		}

		// Fetch the target object
		this.fetchTargetObject();
    }
    
    public class PageSection {
        public String name {get; set;}
        public List<COF_Field> fields {get; set;}
        public Boolean hasChildren {get; set;}
        public List<COF_QuestionSet.COF_Children> children {get;set;}
        public COF_Section formSection {get; set;}
        
		/**
		 * Returns a form section given a page section label
		 */
        public PageSection(String label, List<COF_Section> sList) {
        	this.name = label.toUpperCase();
        	this.hasChildren = false;
        	this.children = new List<COF_QuestionSet.COF_Children>();
	 		for (COF_Section fs: sList) {
				if (fs.title.equalsIgnoreCase(label)) {
					this.formSection = fs;
				}
			}
		}
        
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
		
		for (COF_Section fs: this.form.sections) {
			COF_QuestionSet questionSet = fs.getQuestionSet();
			for (COF_Page page: questionSet.pages) {
				if (page.children != null) {
            		requiredFieldIdentifiers.add(this.childQuery(page));
            		for (PageSection section: this.sections) {
            			if (section.formSection != null && fs.id == section.formSection.id) {
							section.hasChildren = true;
							COF_QuestionSet.COF_Children children = page.children;
             				children.title = page.children.title.toUpperCase();
            				section.children.add(children);
            			}
            		}				
				}
			} 
		}
        // Fetch the target object
        List<String> requiredFieldIdentifiersArray = new List<String>(requiredFieldIdentifiers);
        this.targetObject = Query.object(form.target_object, requiredFieldIdentifiersArray, 'where ' +  'Application__r.Name = \'' + this.getApplicationIdentifierParam() + '\'');
    }
    
    // M.Witchalls Jan 2018: construct child query 
    public String childQuery(COF_Page page) {    	
    	List<String> fieldIdentifiers = new List<String>();
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
        }
        String fieldsList = Query.fieldListString(fieldIdentifiers);
        
    	return '(SELECT ' + fieldslist + ' FROM ' + page.children.child_relationship + ' ORDER BY CreatedDate ASC)';
    }

}