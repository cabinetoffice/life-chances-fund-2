/* __________________________________________________________________________________________________________________
   Name:		LCFGrantHistoryController.cls
   Description: Controller class for LCF Grant History page
					
   Date         Version Author          		Summary of Changes 
   ___________  _______ __________________		_____________________________________________________________________
   May 2018	    1.0    	M.Witchalls,Westbrook	Initial Release 
__________________________________________________________________________________________________________________ */        
public with sharing class LCFGrantHistoryController extends COF_PageController {
	private static final String HISTORY = 'HISTORY';
	private static final String CONFIGIDENTIFIER = 'lcf_grant_1';
	private static final String[] QUERYFIELDS = new List<String>{
		'Id', 'Name', 'Theme__c', 'lcf_grant__r.Name', 'lcf_grant__r.Application_ID__c'
	};

	public SIB_Information__c sibInfo {get;set;}
	public COF_Form form {get;set;}
    public SObject application {get;set;} 
    public SObject grant {get;set;} 
    public SObject targetObject {get;set;}
    public COF_Field historyField {get;set;} 
	public List<RecordWrapper> records {get;set;} 
	public List<String> fieldHeaders {get;set;}    
    public String idString {get;set;}
    
	private String constraint;
	private List<String> fieldIdentifiers;
	private List<COF_Field> fields;
		
	public LCFGrantHistoryController() { 	
        COF_Config config = COF_Config.load(CONFIGIDENTIFIER);
        this.form = config.getForm(this.getFormIdentifierParam());
		this.idString = ApexPages.currentPage().getParameters().get('id');
        this.grant = this.getGrant();
	    
		this.records = new List<RecordWrapper>();   		
		if (this.idString != null && this.form.history_required == 'true') {	
	        // Get the history	
	        this.fields = new List<COF_Field>();
	        this.fieldHeaders = this.form.history_headers.split(',');
	        String[] fidList = this.form.history_fields.split(',');
	        system.debug('@@@@fidList: '+fidList);
	        this.fieldIdentifiers = new List<String>();
	        this.fieldIdentifiers.addAll(QUERYFIELDS);
	        for (String fid: fidList) {
	        	this.fieldIdentifiers.add(fid);
	        	this.fields.add(new COF_Field(fid, this.form.target_object));
	        }
	        List<SObject> recordList = Query.objects(this.form.target_object, fieldIdentifiers,
	        	'WHERE lcf_grant__r.Application__c = \''+idString+'\' AND '+ this.form.block_status_field + ' = \''+HISTORY+'\''
	        ); 
	        for (SObject so: recordList) {
	        	RecordWrapper record = new RecordWrapper(so, fields);
	        	records.add(record);
	        }     
		}
	}
	
	public class RecordWrapper {
		public SObject obj {get; set;}
		public String[] values {get; set;}
		public Integer valueCount {get; set;}
		
		public RecordWrapper(SObject so, List<COF_Field> fields) {
			this.obj = so; 
			this.values = new List<String>();
			this.valueCount = 0;
			for (COF_Field f: fields) {
		    	String val = null;
		        if (f.isDateField == true) {
		            Date currentDate = (Date) so.get(f.identifier);
		            if (currentDate != null) {
		                f.dateDay = String.valueOf(currentDate.day());
		                f.dateMonth = String.valueOf(currentDate.month());
		                f.dateYear = String.valueOf(currentDate.year());
		            	val = f.dateDay.leftPad(2,'0')+'/'+f.dateMonth.leftPad(2,'0')+'/'+f.dateYear;
		            }
		        } else {
		    		val = String.valueOf(so.get(f.identifier));	        	
		        }
		        this.values.add(val);
		        this.valueCount++;
			}
		}
	}

}