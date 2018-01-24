/**
 * Sections Controller
 */
public class SectionsController extends COF_PageController {
	public static final Boolean CREATEIFNOTFOUND = true;

	public COF_Form form {get;set;}
    public SObject application {get;set;} 
    public SObject targetObject {get;set;}

    public SectionsController() {
    	COF_Config config = COF_Config.load();
		this.form = config.getForm(this.getFormIdentifierParam());
		system.debug('### this.form: '+this.form);
		// throw exception 

        this.application = this.getApplication();
    }
    
    public PageReference initialAction() {        
        // M.Witchalls Jan 2018 Fetch Status Fields
        //                      and create a new form object if not found
        // (Create has to be done here since no DML allowed in constructor)
        List<String> fieldIdentifiers = new List<String>{'Id','Name'};
        for (COF_Section section : this.form.sections) {
	        fieldIdentifiers.add(section.status_field);        	
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

        PageReference nextPage = Page.questions;
        nextPage.getParameters().put('template', 'lcf_eoi_org_1');
        nextPage.getParameters().put('id', 'a007E000006IpNOQA0');
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.getParameters().put('page', '1');
        nextPage.setRedirect(true);
        return nextPage;
    }

    /**
     * Submit the application
     */
    public PageReference viewAll() {

        PageReference nextPage = Page.answers;
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.setRedirect(true);
        return nextPage;
    }

}