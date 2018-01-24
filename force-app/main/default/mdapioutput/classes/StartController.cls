public class StartController extends COF_PageController {

	public COF_Form form {get;set;}
    public COF_Section section {get;set;} 

    public SObject application {get;set;} 

    public StartController() {
        COF_Config config = COF_Config.load();
        this.form = config.getForm(this.getFormIdentifierParam());
        this.section = form.getSection(this.getSectionIdentifierParam());
        this.application = this.getApplication();
    }

    public PageReference start() {

        // Get the form object and update with section status

        PageReference nextPage = Page.Questions;
        nextPage.getParameters().put('form', this.getFormIdentifierParam());
        nextPage.getParameters().put('app', this.getApplicationIdentifierParam());
        nextPage.getParameters().put('section', this.getSectionIdentifierParam());
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

}