/* __________________________________________________________________________________________________________________
   Name:		SectionsController.cls
   Description: Controller class for Sections Visualforce page
					
   Date         Version Author          		Summary of Changes 
   ___________  _______ __________________		_____________________________________________________________________
   2017		    1.0    	Cabinet Office			Initial Release 
   Jan 2018		1.1		M.Witchalls, Westbrook	initalAction: Fetch Status fields, create new form object if none found
   Feb 2018		1.2		M.Witchalls, Westbrook	Section text now stored in SIB_SectionText object
__________________________________________________________________________________________________________________ */        
public class SectionsController extends COF_PageController {
	private static final Boolean CREATEIFNOTFOUND = true;
	private static final String SUBMITTED = 'Submitted';

	public COF_Form form {get;set;}
    public SObject application {get;set;} 
    public SObject targetObject {get;set;}
    public String formStatus {get;set;}
	public SIB_Section_Text__c sectionText {get;set;}

    public SectionsController() { 
        
    	COF_Config config = COF_Config.load(this.getFormIdentifierParam());
		this.form = config.getForm(this.getFormIdentifierParam());
		system.debug('### this.form: '+this.form);
		// throws exception if form not found 

        this.application = this.getApplication();
        this.formStatus = this.getformStatus(this.application, this.form);
    	
    	// M.Witchalls Feb 2018: for section text (true = null return OK)
        this.sectionText = SIB_Utilities.getSectionText(this.form.target_object+':Form', true); 
        system.debug('####sectionText: '+sectionText);
    }
    
    public PageReference initialAction() {        
        // M.Witchalls Jan 2018 Fetch Status Fields
        //                      and create a new form object if not found
        // (Create has to be done here since no DML allowed in constructor)
        List<String> fieldIdentifiers = new List<String>{'Id','Name','Form_Complete__c'};
        for (COF_Section section : this.form.sections) {
	        if (section.status_field != null) fieldIdentifiers.add(section.status_field);        	
        }  
        this.targetObject = Query.object(this.form.target_object, fieldIdentifiers, 
        	'WHERE application__r.Name = \'' + this.getApplicationIdentifierParam() + '\'',
        	CREATEIFNOTFOUND, this.application.Id
        );
        return SIB_Utilities.checkLoggedInStatus();
    }

    /**
     * Submit the application
     */
	public PageReference submit() {

    	Application__c appUpdate = new Application__c(
    		Id = (String)application.get('Id'),
    		Full_Application_Status__c = SUBMITTED
    	);
    	Query.updateObject(appUpdate);
        
        PageReference nextPage = Page.COF_ApplicationSubmitted;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.setRedirect(true);
        return nextPage;
    }

    /**
     * View the answers
     */
    public PageReference viewAll() {

        PageReference nextPage = Page.answers;
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.setRedirect(true);
        return nextPage;
    }

}