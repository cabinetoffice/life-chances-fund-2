public class COF_ApplicationSubmittedController extends COF_PageController {

	public COF_Form form {get;set;}
    public SObject application {get;set;}

    public COF_ApplicationSubmittedController() {
        COF_Config config = COF_Config.load();
        this.form = config.getForm(this.getFormIdentifierParam());
        this.application = this.getApplication();
    }

}