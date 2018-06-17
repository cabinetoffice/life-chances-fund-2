/* __________________________________________________________________________________________________________________
   Name:		StartController.cls
   Description: Controller class for (Section) Start Visualforce page
					
   Date         Version Author          		Summary of Changes 
   ___________  _______ __________________		_____________________________________________________________________
   2017		    1.0    	Cabinet Office			Initial Release 
   Feb 2018		1.1		M.Witchalls, Westbrook	Section text now stored in SIB_SectionText object
__________________________________________________________________________________________________________________ */        
public class StartController extends COF_PageController {

	public SIB_Information__c sibInfo {get;set;}
	public COF_Form form {get;set;}
    public COF_Section section {get;set;} 
    public String buttonLabel {get;set;}

    public SObject application {get;set;} 
	public SIB_Section_Text__c sectionText {get;set;}

    public StartController() {
        COF_Config config = COF_Config.load(this.getFormIdentifierParam());
        this.form = config.getForm(this.getFormIdentifierParam());
        this.section = form.getSection(this.getSectionIdentifierParam());
        this.application = this.getApplication();
        SIB_TemplateController con2 = new SIB_TemplateController();
        this.sibInfo = con2.sibInfo; 
        this.buttonLabel = (this.section.title == 'Declaration') ? 'Confirm' : 'Start section';
    	
    	// M.Witchalls Feb 2018: for section text (true = null return OK)
        this.sectionText = SIB_Utilities.getSectionText(this.form.target_object+':'+this.section.id+' Section', true);
        system.debug('####sectionText: '+sectionText);
    }

    public PageReference start() {

        // Get the form object and update with section status

        PageReference nextPage = Page.Questions;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
        nextPage.getParameters().put('title', this.section.title);
        nextPage.getParameters().put('page', '1');
        return nextPage;
    }
    
    public PageReference summaryPage() {
        PageReference nextPage = Page.Summary;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
		return nextPage; 
    }
    
    public PageReference summaryPdf() {
        PageReference nextPage = Page.SummaryPdf;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
		return nextPage; 
    }

}