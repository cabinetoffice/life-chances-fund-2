public with sharing class SIB_NewApplicationController {
	private static final String APPRECORDTYPE = 'Expression of Interest';
    public String selectedTheme{get;set;}
    public Map<String, Id> themeNameToIdMap{get;set;}
    
    //As with all the pages where we require a user to be logged in, we check here if the user is logged in, else return the homepage
    public PageReference checkLoggedInStatus(){
        return SIB_Utilities.checkLoggedInStatus();
    }
    /*
        Loading up controller, getting all possible themes. Generating the map so we can display the repeater.
    */
    public SIB_NewApplicationController() {
        themeNameToIdMap = new Map<String, Id>();
        for(Theme__c theme : [
            SELECT Name, Id
            FROM Theme__c
        ]){
            themeNameToIdMap.put(theme.Name, theme.Id);
        }
    }
    // Sets the selected theme.
    public void setValue(){
        selectedTheme = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('valueToSet'), 'UTF-8');
    }

    /*
        Method which creates an application. 
        It finds all application windows for the selected theme, loops through them, then finds one that is live or starts in the future
        and then creates the application, relates it to the contact and makes it a draft.
        It then forwards the user onto the expression of interest form.
    */
    public PageReference startApplication(){
        Application_Window__c applicationWindow = null;
        List<Application_Window__c> appWindows = [
            SELECT Id, Is_Live__c, Start_Date__c, (
                SELECT Id
                FROM Application_Window_Templates__r
            )
            FROM Application_Window__c
            WHERE Theme__c = :selectedTheme
            ORDER BY End_Date__c ASC
        ];
        for(Application_Window__c applicationWindowToCheck : appWindows){
            applicationWindow = applicationWindowToCheck;
            if(applicationWindowToCheck.Is_Live__c || applicationWindowToCheck.Start_Date__c > Date.today()){
                break;
            }
        }
        List<Contact> contactRecords = Database.query('SELECT Id FROM Contact WHERE Email = \'' + UserInfo.getUserEmail() + '\'');
        Application__c applicationToCreate = new Application__c(
			RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get(APPRECORDTYPE).getRecordTypeId(),
            Application_Window_Template__c = applicationWindow.Application_Window_Templates__r[0].Id,
            Status__c = 'Draft',
            Contact__c = contactRecords.isEmpty() ? null : contactRecords[0].Id
        );
        insert applicationToCreate;
        return new PageReference('/apex/SIB_ApplicationForm?id=' + applicationToCreate.Id + '&formType=Financial%20health%20and%20fraud%20prevention');
    }
}