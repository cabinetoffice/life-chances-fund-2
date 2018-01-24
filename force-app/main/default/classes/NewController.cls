/**
 * New Controller
 */
public class NewController {

	  //   public ApplicationsController() {
	  //   	COF_Config config = COF_Config.load();
			// this.form = config.getForm(this.getFormIdentifier());
			// if (this.form != null) {
				
			// }
	  //   }

	public PageReference save() {

        PageReference nextPage = Page.sections;
        nextPage.getParameters().put('form', 'lcf_eoi_1');
        nextPage.getParameters().put('id', 'a027E000004A5isQAC');
        nextPage.setRedirect(true);
        return nextPage;
    }

}