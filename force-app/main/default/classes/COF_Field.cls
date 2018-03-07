/**
 * COF_Field
 * Cabinet Office Forms 1.0
 *
 * This class represents a field.
 */
public class COF_Field {

    public String identifier {get; set;}
    public String targetObjectIdentifier {get; set;}
    public String label {get; set;}
    public String value {get; set;}
    public String guidance {get; set;}
    public Integer recommendedWordLimit {get; set;}
    public String childRelationship {get; set;}
    public String parentRelationship {get; set;}
    public String warningValue {get; set;}
    public String warningText {get; set;}

    public Boolean isTextField {get; set;}
    public Boolean isTextArea {get; set;}
    public Boolean isEmailField {get; set;}
    public Boolean isRadioField {get; set;}
    public Boolean isSelectField {get; set;}
    public Boolean isDateField {get; set;}
    public Boolean isCheckBox {get; set;}
    public Boolean isCurrency {get; set;}
    public Boolean isNumber {get; set;}
    public Boolean isPercent {get; set;}

    public String dateDay {get; set;}
    public String dateMonth {get; set;}
    public String dateYear {get; set;}

    public List<SelectOption> values {get; set;}
    public List<CheckBoxOption> optionList {get; set;}
    
    public SIB_Field_Metadata__c fieldMetadata {get; set;}

    public COF_Field(String identifier, string targetObjectIdentifier) {
        this.identifier = identifier;
        this.targetObjectIdentifier = targetObjectIdentifier;
        this.parentRelationship = identifier.replace('__c','__r');

        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(targetObjectIdentifier);
        system.debug('###targetType: '+targetType);
        Map<String, Schema.SObjectField> fieldmap = targetType.getDescribe().fields.getMap();
        system.debug('###identifier: '+identifier);
        Schema.SObjectField fieldSchema = fieldmap.get(identifier);
        if (fieldSchema == null) {
		    throw new COF_Exception('Could not find field: '+targetObjectIdentifier+'.'+identifier);        	
        }
        this.label = fieldSchema.getDescribe().getInlineHelpText();
        system.debug('###label: '+this.label);
        
        // M.Witchalls Feb 2018 Get guidance from field description
        fieldMetadata = SIB_Utilities.getFieldMetadata(targetObjectIdentifier, identifier); 
        if (fieldMetadata != null) { 
        	//this.label = fieldMetadata.Help_Text__c;	(Describe information is more up to date)
	        this.guidance = fieldMetadata.Description__c;
	        if (fieldMetadata.Rich_Text__c != null) {
				fieldMetadata.Rich_Text__c = fieldMetadata.Rich_Text__c.replace('target="_blank"','target="_self"');	
	        }
	        if (fieldMetadata.Recommended_Word_Limit__c != null) this.recommendedWordLimit = fieldMetadata.Recommended_Word_Limit__c.intValue();
	        this.childRelationship = fieldMetadata.Relationship_Name__c;
	        this.warningValue = fieldMetadata.Warning_Value__c; 
	        this.warningText = fieldMetadata.Warning_Text__c;
	        system.debug('###guidance: '+this.guidance); 
        }

        Schema.DisplayType fieldType = fieldmap.get(identifier).getDescribe().getType();
        if (fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.TextArea 
        || fieldType == Schema.DisplayType.Currency || fieldType == Schema.DisplayType.Double
        || fieldType == Schema.DisplayType.Email || fieldType == Schema.DisplayType.Percent) {
            this.isTextField = true;
        }
        if (fieldType == Schema.DisplayType.TextArea) {
            this.isTextArea = true;
        }
        if (fieldType == Schema.DisplayType.Email) {
            this.isEmailField = true;
        }
        if (fieldType == Schema.DisplayType.Currency) {
            this.isCurrency = true;
        }
        if (fieldType == Schema.DisplayType.Double) {
            this.isNumber = true;
        }
        if (fieldType == Schema.DisplayType.Boolean) {
            this.isCheckBox = true;
        }
        if (fieldType == Schema.DisplayType.Picklist) {
            this.isRadioField = true;
        }
        if (fieldType == Schema.DisplayType.MultiPicklist) {
            this.isSelectField = true;
        }
        if (fieldType == Schema.DisplayType.Date) {
            this.isDateField = true;
        }
        if (fieldType == Schema.DisplayType.Percent) {
            this.isPercent = true;
        }

        List<Schema.PicklistEntry> picklistValues = fieldmap.get(identifier).getDescribe().getPickListValues();
        this.values = new List<SelectOption>();
        this.optionList = new List<CheckBoxOption>();
        for (Schema.PicklistEntry a : picklistValues) {
            this.values.add(new SelectOption(a.getValue(), a.getLabel()));
            this.optionList.add(
                new CheckBoxOption(
                    false, 
                    a.getValue(),
                    a.getLabel()
                )
            );
        }
    }

    public class CheckBoxOption {
        public Boolean selected {get; set;}
        public String value {get; set;}
        public String label {get; set;}
        
        public CheckBoxOption(Boolean sel, String val, String label) {
            this.selected = sel;
            this.value = val;
            this.label = label;
        }
    }
}