public with sharing class COF_GrantBlockSubmittedController extends COF_PageController {

	private static final String CONFIGIDENTIFIER = 'lcf_grant_1';
	public COF_Form form {get;set;}
	public SObject application {get;set;}
	public SObject grant {get;set;}
    public SObject targetObject {get;set;}
	public String formTitle {get; set;} 
	public String periodTitle {get; set;} 
	
	private List<String> fieldIdentifiers;

    public COF_GrantBlockSubmittedController() {
        COF_Config config = COF_Config.load(CONFIGIDENTIFIER);
        this.form = config.getForm(this.getFormIdentifierParam());
        this.application = this.getApplication();
        this.grant = this.getGrant();
        
        this.fieldIdentifiers = new List<String>{'Id','Name'};
        if (this.form.period_title_field != null) {
        	this.fieldIdentifiers.add(this.form.period_title_field);
        }
        List<SObject> recordList = Query.objects(this.form.target_object, fieldIdentifiers,
        	'WHERE lcf_grant__r.Name = \'' + this.getGrantIdentifierParam() + '\''
        );
        if (recordList.size() > 0) {
        	this.targetObject = recordList[0];
        	if (this.form.period_title_field != null) this.periodTitle = ((String)this.targetObject.get(this.form.period_title_field)).toLowerCase();
        }
        this.formTitle = this.form.title.toLowerCase();
    }

}